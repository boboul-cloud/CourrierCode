import Foundation
import UIKit

// MARK: - Structures de données pour l'export JSON

/// Représente un pixel encodé avec les valeurs RGB en codes CourrierCode
struct EncodedPixel: Codable, Equatable {
    let r: String  // Rouge encodé (ex: "0515" pour 165)
    let g: String  // Vert encodé
    let b: String  // Bleu encodé
    let a: String  // Alpha encodé
}

/// Représente une image encodée complète
struct EncodedImage: Codable, Equatable {
    let version: String
    let width: Int
    let height: Int
    let encodingDate: String
    let dayOffset: Int?
    let secretCode: Bool
    let tableCode: Bool
    let pixels: [[EncodedPixel]]
    
    /// Calcule la taille estimée du JSON en Ko
    var estimatedSize: Int {
        // Approximation : chaque pixel = ~50 caractères
        return (width * height * 50) / 1024
    }
}

/// Métadonnées d'une image encodée (pour preview rapide)
struct EncodedImageMetadata: Codable {
    let version: String
    let width: Int
    let height: Int
    let encodingDate: String
    let pixelCount: Int
}

// MARK: - ImageEncoder

class ImageEncoder {
    
    static let shared = ImageEncoder()
    private let codeur = CourrierCodeur()
    
    // Version du format d'encodage
    private let formatVersion = "1.0"
    
    // Taille maximale recommandée pour l'encodage (pour éviter les fichiers trop volumineux)
    let maxRecommendedSize: CGFloat = 100
    let maxAbsoluteSize: CGFloat = 200
    
    private init() {}
    
    // MARK: - Encodage d'un nombre (0-255) vers le format CourrierCode
    
    /// Encode un nombre de 0 à 255 en format CourrierCode (4 chiffres)
    /// Par exemple: 165 -> "0115" (01 pour 1, 65 encodé)
    func encodeNumber(_ number: Int, decalage: Int = 0) -> String {
        // Diviser en dizaines et unités
        let centaines = number / 100
        let reste = number % 100
        let dizaines = reste / 10
        let unites = reste % 10
        
        // Encoder chaque chiffre selon le système CourrierCode
        // Les chiffres 0-9 deviennent 27-36
        var result = ""
        
        // Encoder les centaines (0, 1 ou 2)
        let centainesCode = 27 + ((centaines + decalage) % 10)
        result += String(centainesCode)
        
        // Encoder les dizaines
        let dizainesCode = 27 + ((dizaines + decalage) % 10)
        result += String(dizainesCode)
        
        // Encoder les unités
        let unitesCode = 27 + ((unites + decalage) % 10)
        result += String(unitesCode)
        
        return result
    }
    
    /// Décode un nombre depuis le format CourrierCode
    func decodeNumber(_ code: String, decalage: Int = 0) -> Int? {
        guard code.count >= 3 else { return nil }
        
        var result = 0
        var multiplier = 1
        
        // Parcourir de droite à gauche
        for i in stride(from: code.count - 2, through: 0, by: -2) {
            let startIndex = code.index(code.startIndex, offsetBy: i)
            let endIndex = code.index(startIndex, offsetBy: 2)
            let paire = String(code[startIndex..<endIndex])
            
            if let num = Int(paire), num >= 27 && num <= 36 {
                let chiffre = (num - 27 - (decalage % 10) + 10) % 10
                result += chiffre * multiplier
                multiplier *= 10
            }
        }
        
        return result
    }
    
    // MARK: - Encodage d'image
    
    /// Encode une image UIImage en structure EncodedImage
    func encodeImage(_ image: UIImage, 
                     withDayOffset: Bool = false,
                     secretCode: String = "",
                     tableCode: String = "",
                     targetSize: CGSize? = nil) -> EncodedImage? {
        
        // Redimensionner si nécessaire
        let processedImage: UIImage
        if let size = targetSize {
            processedImage = resizeImage(image, to: size)
        } else {
            processedImage = image
        }
        
        guard let cgImage = processedImage.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        // Calculer le décalage
        let jour = codeur.getJourActuel()
        let decalageJour = withDayOffset ? codeur.getDecalageJour(jour: jour) : 0
        let decalageSecret = codeur.calculerDecalageSecret(secretCode)
        let decalage = decalageJour + decalageSecret
        
        // Activer la table personnalisée si fournie
        if tableCode.count == 6 {
            TableAleatoire.shared.genererTable(avecCode: tableCode)
        }
        
        // Obtenir les données des pixels
        guard let pixelData = getPixelData(from: cgImage) else { return nil }
        
        // Encoder chaque pixel
        var encodedPixels: [[EncodedPixel]] = []
        
        for y in 0..<height {
            var row: [EncodedPixel] = []
            for x in 0..<width {
                let offset = (y * width + x) * 4
                
                let r = Int(pixelData[offset])
                let g = Int(pixelData[offset + 1])
                let b = Int(pixelData[offset + 2])
                let a = Int(pixelData[offset + 3])
                
                let encodedPixel = EncodedPixel(
                    r: encodeNumber(r, decalage: decalage),
                    g: encodeNumber(g, decalage: decalage),
                    b: encodeNumber(b, decalage: decalage),
                    a: encodeNumber(a, decalage: decalage)
                )
                row.append(encodedPixel)
            }
            encodedPixels.append(row)
        }
        
        // Formater la date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        
        return EncodedImage(
            version: formatVersion,
            width: width,
            height: height,
            encodingDate: dateString,
            dayOffset: withDayOffset ? jour : nil,
            secretCode: !secretCode.isEmpty,
            tableCode: tableCode.count == 6,
            pixels: encodedPixels
        )
    }
    
    /// Convertit une EncodedImage en données JSON
    func exportToJSON(_ encodedImage: EncodedImage) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(encodedImage)
    }
    
    /// Exporte une image en chaîne JSON
    func exportToJSONString(_ encodedImage: EncodedImage) -> String? {
        guard let data = exportToJSON(encodedImage) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Décodage d'image
    
    /// Importe une EncodedImage depuis des données JSON
    func importFromJSON(_ data: Data) -> EncodedImage? {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(EncodedImage.self, from: data)
        } catch {
            print("Erreur décodage JSON: \(error)")
            return nil
        }
    }
    
    /// Importe depuis une chaîne JSON
    func importFromJSONString(_ jsonString: String) -> EncodedImage? {
        // Nettoyer le JSON (enlever espaces/retours au début/fin)
        let cleanedJSON = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = cleanedJSON.data(using: .utf8) else { 
            print("Erreur conversion string -> data")
            return nil 
        }
        return importFromJSON(data)
    }
    
    /// Décode une EncodedImage en UIImage
    func decodeImage(_ encodedImage: EncodedImage,
                     secretCode: String = "",
                     tableCode: String = "") -> UIImage? {
        
        let width = encodedImage.width
        let height = encodedImage.height
        
        // Calculer le décalage
        var decalage = 0
        if let jour = encodedImage.dayOffset {
            decalage += codeur.getDecalageJour(jour: jour)
        }
        if encodedImage.secretCode {
            decalage += codeur.calculerDecalageSecret(secretCode)
        }
        
        // Activer la table personnalisée si nécessaire
        if encodedImage.tableCode && tableCode.count == 6 {
            TableAleatoire.shared.genererTable(avecCode: tableCode)
        }
        
        // Créer les données pixels
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        
        for y in 0..<min(height, encodedImage.pixels.count) {
            let row = encodedImage.pixels[y]
            for x in 0..<min(width, row.count) {
                let pixel = row[x]
                let offset = (y * width + x) * 4
                
                if let r = decodeNumber(pixel.r, decalage: decalage),
                   let g = decodeNumber(pixel.g, decalage: decalage),
                   let b = decodeNumber(pixel.b, decalage: decalage),
                   let a = decodeNumber(pixel.a, decalage: decalage) {
                    pixelData[offset] = UInt8(min(255, max(0, r)))
                    pixelData[offset + 1] = UInt8(min(255, max(0, g)))
                    pixelData[offset + 2] = UInt8(min(255, max(0, b)))
                    pixelData[offset + 3] = UInt8(min(255, max(0, a)))
                }
            }
        }
        
        // Créer l'image
        return createImage(from: pixelData, width: width, height: height)
    }
    
    // MARK: - Utilitaires
    
    /// Redimensionne une image
    func resizeImage(_ image: UIImage, to targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    /// Obtient les données pixels d'un CGImage
    private func getPixelData(from cgImage: CGImage) -> [UInt8]? {
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return pixelData
    }
    
    /// Crée une UIImage à partir de données pixels
    private func createImage(from pixelData: [UInt8], width: Int, height: Int) -> UIImage? {
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        
        var mutablePixelData = pixelData
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: &mutablePixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }
        
        guard let cgImage = context.makeImage() else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// Estime la taille du fichier JSON pour une image donnée
    func estimateJSONSize(width: Int, height: Int) -> String {
        // Chaque pixel = environ 60 caractères en JSON
        let bytes = width * height * 60
        if bytes < 1024 {
            return "\(bytes) o"
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f Ko", Double(bytes) / 1024)
        } else {
            return String(format: "%.1f Mo", Double(bytes) / (1024 * 1024))
        }
    }
    
    /// Extrait les métadonnées d'un JSON sans charger tous les pixels
    func extractMetadata(from jsonString: String) -> EncodedImageMetadata? {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let version = json["version"] as? String,
              let width = json["width"] as? Int,
              let height = json["height"] as? Int,
              let encodingDate = json["encodingDate"] as? String else {
            return nil
        }
        
        return EncodedImageMetadata(
            version: version,
            width: width,
            height: height,
            encodingDate: encodingDate,
            pixelCount: width * height
        )
    }
}
