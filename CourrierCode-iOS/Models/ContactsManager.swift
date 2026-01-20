import Foundation
import Security

/// Représente un correspondant avec ses codes
struct Correspondant: Codable, Identifiable {
    var id = UUID()
    var nom: String
    var codeSecret: String
    var codeTable: String
    
    var description: String {
        var parts: [String] = []
        if !codeSecret.isEmpty { parts.append("Code secret") }
        if !codeTable.isEmpty { parts.append("Table: \(codeTable)") }
        return parts.isEmpty ? "Aucun code" : parts.joined(separator: " + ")
    }
}

/// Gestionnaire du carnet de correspondants
class ContactsManager: ObservableObject {
    static let shared = ContactsManager()
    
    @Published var correspondants: [Correspondant] = []
    
    private let keychainService = "com.courriercode.correspondants"
    
    private init() {
        chargerCorrespondants()
    }
    
    // MARK: - CRUD
    
    func ajouter(_ correspondant: Correspondant) {
        correspondants.append(correspondant)
        sauvegarder()
    }
    
    func modifier(_ correspondant: Correspondant) {
        if let index = correspondants.firstIndex(where: { $0.id == correspondant.id }) {
            correspondants[index] = correspondant
            sauvegarder()
        }
    }
    
    func supprimer(_ correspondant: Correspondant) {
        correspondants.removeAll { $0.id == correspondant.id }
        sauvegarder()
    }
    
    func supprimerTout() {
        correspondants.removeAll()
        sauvegarder()
    }
    
    // MARK: - Décodage automatique
    
    struct ResultatDecodage {
        let correspondant: Correspondant
        let messageDecod: String
        let score: Int
        let jourDetecte: String?
    }
    
    /// Teste tous les correspondants et retourne le meilleur résultat
    func decoderAvecCarnet(texte: String, codeur: CourrierCodeur) -> ResultatDecodage? {
        guard !correspondants.isEmpty else { return nil }
        
        var meilleurResultat: ResultatDecodage? = nil
        var meilleurScore = 0
        
        for correspondant in correspondants {
            // Tester avec ce correspondant
            let resultat = codeur.decoderIntelligent(
                texte: texte,
                modeJour: true,
                codeSecret: correspondant.codeSecret,
                codeTable: correspondant.codeTable
            )
            
            let score = codeur.compterMotsReconnus(resultat.texte)
            
            if score > meilleurScore {
                meilleurScore = score
                
                // Détecter le jour
                var jourDetecte: String? = nil
                let codeNettoye = texte.replacingOccurrences(of: " ", with: "")
                if let info = codeur.extraireJourDuCode(codeNettoye) {
                    jourDetecte = codeur.nomsJours[info.jour]
                } else if let info = codeur.extraireJourDuCode(String(codeNettoye.reversed())) {
                    jourDetecte = codeur.nomsJours[info.jour]
                }
                
                meilleurResultat = ResultatDecodage(
                    correspondant: correspondant,
                    messageDecod: resultat.texte,
                    score: score,
                    jourDetecte: jourDetecte
                )
            }
        }
        
        // Retourner seulement si le score est significatif (au moins 2 mots reconnus)
        if let resultat = meilleurResultat, resultat.score >= 2 {
            return resultat
        }
        
        return nil
    }
    
    /// Teste tous les correspondants en mode ABC (sans espaces) et retourne le meilleur résultat
    func decoderABCAvecCarnet(texte: String, codeur: CourrierCodeur) -> ResultatDecodage? {
        guard !correspondants.isEmpty else { return nil }
        
        let code = texte.replacingOccurrences(of: " ", with: "")
        let codeInverse = String(code.reversed())
        
        var meilleurResultat: ResultatDecodage? = nil
        var meilleurScore = -1
        
        // Chercher d'abord si un marqueur de jour existe
        let infoJourNormal = codeur.extraireJourDuCode(code)
        let infoJourInverse = codeur.extraireJourDuCode(codeInverse)
        
        for correspondant in correspondants {
            let decalageSecret = codeur.calculerDecalageSecret(correspondant.codeSecret)
            
            // Tester avec marqueur de jour trouvé dans le code normal
            if let info = infoJourNormal {
                let codeSansMarqueur = codeur.retirerMarqueurJour(code, position: info.position)
                let decalage = codeur.getDecalageJour(jour: info.jour) + decalageSecret
                let decode = codeur.decoder(texte: codeSansMarqueur, decalage: decalage, codeTable: correspondant.codeTable)
                let segmente = codeur.segmenterEnMots(decode)
                let score = codeur.compterMotsReconnus(segmente)
                
                if score > meilleurScore {
                    meilleurScore = score
                    meilleurResultat = ResultatDecodage(
                        correspondant: correspondant,
                        messageDecod: segmente,
                        score: score,
                        jourDetecte: codeur.nomsJours[info.jour]
                    )
                }
            }
            
            // Tester avec marqueur de jour trouvé dans le code inversé
            if let info = infoJourInverse {
                let codeSansMarqueur = codeur.retirerMarqueurJour(codeInverse, position: info.position)
                let decalage = codeur.getDecalageJour(jour: info.jour) + decalageSecret
                let decode = codeur.decoder(texte: codeSansMarqueur, decalage: decalage, codeTable: correspondant.codeTable)
                let segmente = codeur.segmenterEnMots(decode)
                let score = codeur.compterMotsReconnus(segmente)
                
                if score > meilleurScore {
                    meilleurScore = score
                    meilleurResultat = ResultatDecodage(
                        correspondant: correspondant,
                        messageDecod: segmente,
                        score: score,
                        jourDetecte: codeur.nomsJours[info.jour]
                    )
                }
            }
            
            // Si pas de marqueur, tester tous les jours
            if infoJourNormal == nil && infoJourInverse == nil {
                for jour in 0..<7 {
                    let decalage = codeur.getDecalageJour(jour: jour) + decalageSecret
                    
                    // Tester le code normal
                    let decode1 = codeur.decoder(texte: code, decalage: decalage, codeTable: correspondant.codeTable)
                    let segmente1 = codeur.segmenterEnMots(decode1)
                    let score1 = codeur.compterMotsReconnus(segmente1)
                    if score1 > meilleurScore {
                        meilleurScore = score1
                        meilleurResultat = ResultatDecodage(
                            correspondant: correspondant,
                            messageDecod: segmente1,
                            score: score1,
                            jourDetecte: codeur.nomsJours[jour]
                        )
                    }
                    
                    // Tester le code inversé
                    let decode2 = codeur.decoder(texte: codeInverse, decalage: decalage, codeTable: correspondant.codeTable)
                    let segmente2 = codeur.segmenterEnMots(decode2)
                    let score2 = codeur.compterMotsReconnus(segmente2)
                    if score2 > meilleurScore {
                        meilleurScore = score2
                        meilleurResultat = ResultatDecodage(
                            correspondant: correspondant,
                            messageDecod: segmente2,
                            score: score2,
                            jourDetecte: codeur.nomsJours[jour]
                        )
                    }
                }
            }
        }
        
        // Retourner le meilleur résultat s'il existe
        return meilleurResultat
    }
    
    // MARK: - Persistance Keychain
    
    private func sauvegarder() {
        guard let data = try? JSONEncoder().encode(correspondants) else { return }
        
        // Supprimer l'ancienne valeur
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Ajouter la nouvelle
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }
    
    private func chargerCorrespondants() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let decoded = try? JSONDecoder().decode([Correspondant].self, from: data) else {
            return
        }
        
        correspondants = decoded
    }
    
    // MARK: - Utilitaires
    
    var hasCorrespondants: Bool {
        !correspondants.isEmpty
    }
    
    var count: Int {
        correspondants.count
    }
}
