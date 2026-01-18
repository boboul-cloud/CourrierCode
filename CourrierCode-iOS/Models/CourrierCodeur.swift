import Foundation

class CourrierCodeur {
    
    // Décalages par jour de la semaine
    let decalagesJours: [Int: Int] = [
        0: 7,   // Dimanche
        1: 3,   // Lundi
        2: 11,  // Mardi
        3: 5,   // Mercredi
        4: 9,   // Jeudi
        5: 2,   // Vendredi
        6: 13   // Samedi
    ]
    
    let nomsJours = ["Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"]
    
    // MARK: - Fonctions de base
    
    func getJourActuel() -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        // En Swift, dimanche = 1, donc on ajuste
        return weekday - 1
    }
    
    func getDecalageJour(jour: Int) -> Int {
        return decalagesJours[jour] ?? 0
    }
    
    // MARK: - Code secret
    
    func calculerDecalageSecret(_ codeSecret: String) -> Int {
        guard !codeSecret.isEmpty else { return 0 }
        
        let texteNormalise = supprimerAccents(codeSecret).uppercased()
        var somme = 0
        
        for char in texteNormalise {
            if char.isLetter, let ascii = char.asciiValue {
                somme += Int(ascii) - 64  // A=1, B=2, etc.
            } else if char.isNumber, let digit = char.wholeNumberValue {
                somme += digit
            }
        }
        
        return somme
    }
    
    // MARK: - Table aléatoire
    
    func activerTableAleatoire(code: String) {
        TableAleatoire.shared.genererTable(avecCode: code)
    }
    
    func desactiverTableAleatoire() {
        TableAleatoire.shared.reinitialiserTableParDefaut()
    }
    
    func genererNouvelleTable() -> String {
        return TableAleatoire.shared.genererNouveauCode()
    }
    
    // MARK: - Suppression des accents
    
    func supprimerAccents(_ texte: String) -> String {
        return texte.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    // MARK: - Encodage
    
    func encoder(texte: String, avecDecalage: Bool = false, codeSecret: String = "", codeTable: String = "") -> String {
        var output = ""
        let jour = getJourActuel()
        let decalageJour = avecDecalage ? getDecalageJour(jour: jour) : 0
        let decalageSecret = calculerDecalageSecret(codeSecret)
        let decalage = decalageJour + decalageSecret
        
        // Activer la table personnalisée si un code est fourni
        let utiliseTablePerso = codeTable.count == 6
        if utiliseTablePerso {
            TableAleatoire.shared.genererTable(avecCode: codeTable)
        }
        
        let texteNormalise = supprimerAccents(texte).uppercased()
        
        for char in texteNormalise {
            if char.isLetter {
                var numero: Int
                if utiliseTablePerso, let num = TableAleatoire.shared.encoderLettre(char) {
                    // Utiliser la table personnalisée
                    numero = num
                } else if let ascii = char.asciiValue {
                    // Table par défaut : A=1, B=2, etc.
                    numero = Int(ascii) - 64
                } else {
                    continue
                }
                // Appliquer le décalage
                numero = ((numero - 1 + decalage) % 26) + 1
                output += String(format: "%02d", numero)
            } else if char.isNumber, let digit = char.wholeNumberValue {
                // 0=27, 1=28, ..., 9=36
                var numero = digit + 27
                numero = 27 + ((numero - 27 + decalage) % 10)
                output += String(numero)
            }
            // Ignorer les autres caractères
        }
        
        // Insérer le marqueur du jour au milieu
        if avecDecalage && output.count >= 4 {
            let milieu = output.count / 2
            let positionInsertion = milieu - (milieu % 2)
            let marqueurJour = "00" + String(format: "%02d", jour)
            let index = output.index(output.startIndex, offsetBy: positionInsertion)
            output.insert(contentsOf: marqueurJour, at: index)
        }
        
        return output
    }
    
    // MARK: - Décodage
    
    func decoder(texte: String, decalage: Int = 0, codeTable: String = "") -> String {
        var resultat = ""
        let code = texte.replacingOccurrences(of: " ", with: "")
        
        // Activer la table personnalisée si un code est fourni
        let utiliseTablePerso = codeTable.count == 6
        if utiliseTablePerso {
            TableAleatoire.shared.genererTable(avecCode: codeTable)
        }
        
        var i = 0
        while i < code.count - 1 {
            let startIndex = code.index(code.startIndex, offsetBy: i)
            let endIndex = code.index(startIndex, offsetBy: 2)
            let paire = String(code[startIndex..<endIndex])
            
            if let num = Int(paire) {
                if num >= 1 && num <= 26 {
                    // Lettre - d'abord annuler le décalage
                    let adjusted = ((num - 1 - (decalage % 26) + 26) % 26) + 1
                    
                    if utiliseTablePerso, let char = TableAleatoire.shared.decoderNumero(adjusted) {
                        // Utiliser la table personnalisée
                        resultat += String(char)
                    } else if let scalar = UnicodeScalar(64 + adjusted) {
                        // Table par défaut
                        resultat += String(Character(scalar))
                    }
                } else if num >= 27 && num <= 36 {
                    // Chiffre
                    let chiffre = (num - 27 - (decalage % 10) + 10) % 10
                    resultat += String(chiffre)
                }
            }
            
            i += 2
        }
        
        return resultat
    }
    
    // MARK: - Extraction du jour encodé
    
    func extraireJourDuCode(_ code: String) -> (jour: Int, position: Int)? {
        // Chercher le pattern "000X" où X est 0-6
        // Le marqueur est "00" (séparateur) + "0X" (jour sur 2 chiffres: 00 à 06)
        
        let cleanCode = code.replacingOccurrences(of: " ", with: "")
        
        // Parcourir le code par paires pour trouver "00" suivi de "0X"
        var i = 0
        while i <= cleanCode.count - 4 {
            let startIndex = cleanCode.index(cleanCode.startIndex, offsetBy: i)
            let endIndex = cleanCode.index(startIndex, offsetBy: 4)
            let segment = String(cleanCode[startIndex..<endIndex])
            
            // Vérifier si c'est un marqueur valide: 0000 à 0006
            if segment.hasPrefix("000") {
                if let lastChar = segment.last,
                   let digit = lastChar.wholeNumberValue,
                   digit >= 0 && digit <= 6 {
                    return (jour: digit, position: i)
                }
            }
            
            i += 2 // Avancer par paires
        }
        
        return nil
    }
    
    func retirerMarqueurJour(_ code: String, position: Int) -> String {
        var result = code
        let start = result.index(result.startIndex, offsetBy: position)
        let end = result.index(start, offsetBy: 4)
        result.removeSubrange(start..<end)
        return result
    }
    
    // MARK: - Segmentation en mots
    
    // Déterminants pluriels qui indiquent que le mot suivant est probablement au pluriel
    let determinantsPluriels: Set<String> = [
        "les", "des", "ces", "mes", "tes", "ses", "nos", "vos", "leurs",
        "aux", "quelques", "plusieurs", "certains", "certaines",
        "tous", "toutes", "quels", "quelles", "differents", "differentes"
    ]
    
    func estMotPluriel(_ mot: String) -> Bool {
        let m = mot.lowercased()
        return m.hasSuffix("s") || m.hasSuffix("x")
    }
    
    func segmenterEnMots(_ texte: String) -> String {
        let texteMin = texte.lowercased()
        let n = texteMin.count
        
        if n == 0 { return "" }
        
        // Programmation dynamique - parcours de droite à gauche pour privilégier les mots longs
        // dp[i] = meilleure segmentation de texte[i...n-1]
        var dp: [(score: Int, segmentation: [String])?] = Array(repeating: nil, count: n + 1)
        dp[n] = (score: 0, segmentation: [])
        
        let maxLen = 25
        
        // Parcourir de la fin vers le début
        for i in stride(from: n - 1, through: 0, by: -1) {
            var meilleur: (score: Int, segmentation: [String])? = nil
            let endMax = min(n, i + maxLen)
            
            // Essayer les mots les plus longs d'abord
            for j in stride(from: endMax, to: i, by: -1) {
                guard let next = dp[j] else { continue }
                
                let startIndex = texteMin.index(texteMin.startIndex, offsetBy: i)
                let endIndex = texteMin.index(texteMin.startIndex, offsetBy: j)
                let mot = String(texteMin[startIndex..<endIndex])
                let longueur = mot.count
                
                var score: Int
                var bonus = 0
                
                if Dictionnaire.shared.contient(mot) {
                    // Bonus exponentiel pour les mots longs reconnus
                    // longueur^4 pour vraiment privilégier les mots longs
                    score = next.score + (longueur * longueur * longueur * longueur)
                    // Bonus supplémentaire pour les mots de 5+ lettres
                    if longueur >= 5 {
                        bonus = longueur * 100
                    } else if longueur >= 4 {
                        bonus = longueur * 50
                    }
                    score += bonus
                    
                    // Bonus contextuel: si c'est un déterminant pluriel et le mot suivant est au pluriel
                    if determinantsPluriels.contains(mot) && !next.segmentation.isEmpty {
                        let motSuivant = next.segmentation[0].lowercased()
                        if estMotPluriel(motSuivant) && Dictionnaire.shared.contient(motSuivant) {
                            // Bonus de cohérence grammaticale
                            score += 200
                        }
                    }
                } else if longueur == 1 {
                    score = next.score - 200
                } else if longueur == 2 {
                    score = next.score - 100
                } else if longueur == 3 {
                    score = next.score - 50
                } else {
                    // Mots non reconnus: pénalité
                    score = next.score - (longueur * 10)
                }
                
                if meilleur == nil || score > meilleur!.score {
                    meilleur = (score: score, segmentation: [mot.uppercased()] + next.segmentation)
                }
            }
            
            dp[i] = meilleur
        }
        
        if let result = dp[0], !result.segmentation.isEmpty {
            return result.segmentation.joined(separator: " ")
        }
        
        return texte
    }
    
    // MARK: - Comptage des mots reconnus
    
    func compterMotsReconnus(_ phrase: String) -> Int {
        let mots = phrase.lowercased().split(separator: " ")
        var score = 0
        for mot in mots {
            if Dictionnaire.shared.contient(String(mot)) {
                score += mot.count * mot.count
            }
        }
        return score
    }
    
    // MARK: - Décodage intelligent
    
    struct ResultatDecodage {
        let texte: String
        let indication: String
    }
    
    func decoderIntelligent(texte: String, modeJour: Bool, codeSecret: String = "", codeTable: String = "") -> ResultatDecodage {
        var meilleurResultat = ""
        var meilleurScore = -1
        var meilleurJour: Int? = nil
        var estInverse = false
        var jourDetecte = false
        
        let decalageSecret = calculerDecalageSecret(codeSecret)
        let code = texte.replacingOccurrences(of: " ", with: "")
        let codeInverse = String(code.reversed())
        
        if modeJour {
            // Chercher le marqueur du jour
            if let info = extraireJourDuCode(code) {
                let codeSansMarqueur = retirerMarqueurJour(code, position: info.position)
                let decalage = getDecalageJour(jour: info.jour) + decalageSecret
                let decode = decoder(texte: codeSansMarqueur, decalage: decalage, codeTable: codeTable)
                let seg = segmenterEnMots(decode)
                let score = compterMotsReconnus(seg)
                
                if score > meilleurScore {
                    meilleurScore = score
                    meilleurResultat = seg
                    meilleurJour = info.jour
                    jourDetecte = true
                    estInverse = false
                }
            }
            
            if let info = extraireJourDuCode(codeInverse) {
                let codeSansMarqueur = retirerMarqueurJour(codeInverse, position: info.position)
                let decalage = getDecalageJour(jour: info.jour) + decalageSecret
                let decode = decoder(texte: codeSansMarqueur, decalage: decalage, codeTable: codeTable)
                let seg = segmenterEnMots(decode)
                let score = compterMotsReconnus(seg)
                
                if score > meilleurScore {
                    meilleurScore = score
                    meilleurResultat = seg
                    meilleurJour = info.jour
                    jourDetecte = true
                    estInverse = true
                }
            }
            
            // Si pas de marqueur, tester tous les jours
            if !jourDetecte {
                for jour in 0..<7 {
                    let decalage = getDecalageJour(jour: jour) + decalageSecret
                    
                    // Normal
                    let decode1 = decoder(texte: code, decalage: decalage, codeTable: codeTable)
                    let seg1 = segmenterEnMots(decode1)
                    let score1 = compterMotsReconnus(seg1)
                    
                    if score1 > meilleurScore {
                        meilleurScore = score1
                        meilleurResultat = seg1
                        meilleurJour = jour
                        estInverse = false
                    }
                    
                    // Inversé
                    let decode2 = decoder(texte: codeInverse, decalage: decalage, codeTable: codeTable)
                    let seg2 = segmenterEnMots(decode2)
                    let score2 = compterMotsReconnus(seg2)
                    
                    if score2 > meilleurScore {
                        meilleurScore = score2
                        meilleurResultat = seg2
                        meilleurJour = jour
                        estInverse = true
                    }
                }
            }
        } else {
            // Mode sans décalage
            let decode1 = decoder(texte: code, decalage: 0, codeTable: codeTable)
            let decode2 = decoder(texte: codeInverse, decalage: 0, codeTable: codeTable)
            
            let seg1 = segmenterEnMots(decode1)
            let seg2 = segmenterEnMots(decode2)
            
            let score1 = compterMotsReconnus(seg1)
            let score2 = compterMotsReconnus(seg2)
            
            if score2 > score1 {
                meilleurResultat = seg2
                estInverse = true
            } else {
                meilleurResultat = seg1
            }
        }
        
        // Construire l'indication
        var indication = ""
        if let jour = meilleurJour {
            let emoji = jourDetecte ? "🔓" : "📅"
            indication = "\(emoji) \(nomsJours[jour])"
        }
        if estInverse {
            indication += (indication.isEmpty ? "" : " ") + "🔄"
        }
        
        return ResultatDecodage(texte: meilleurResultat, indication: indication)
    }
}
