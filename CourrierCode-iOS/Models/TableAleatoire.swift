import Foundation

class TableAleatoire {
    static let shared = TableAleatoire()
    
    // Table par défaut : A=01, B=02, ..., Z=26
    private var tableEncodage: [Character: Int] = [:]
    private var tableDecodage: [Int: Character] = [:]
    private var codeTableActuel: String? = nil
    
    private init() {
        reinitialiserTableParDefaut()
    }
    
    // MARK: - Table par défaut
    
    func reinitialiserTableParDefaut() {
        tableEncodage.removeAll()
        tableDecodage.removeAll()
        
        // Lettres A-Z → 01-26
        for i in 1...26 {
            let char = Character(UnicodeScalar(64 + i)!)
            tableEncodage[char] = i
            tableDecodage[i] = char
        }
        
        codeTableActuel = nil
    }
    
    // MARK: - Génération d'une table aléatoire à partir d'un code à 6 chiffres
    
    func genererTable(avecCode code: String) {
        guard code.count == 6, let seed = Int(code) else {
            reinitialiserTableParDefaut()
            return
        }
        
        // Utiliser le code comme graine pour un générateur pseudo-aléatoire
        var rng = SeededRandomNumberGenerator(seed: UInt64(seed))
        
        // Créer un tableau de 1 à 26 et le mélanger
        var numeros = Array(1...26)
        numeros.shuffle(using: &rng)
        
        tableEncodage.removeAll()
        tableDecodage.removeAll()
        
        // Assigner les numéros mélangés aux lettres
        for i in 0..<26 {
            let char = Character(UnicodeScalar(65 + i)!) // A, B, C, ...
            let numero = numeros[i]
            tableEncodage[char] = numero
            tableDecodage[numero] = char
        }
        
        codeTableActuel = code
    }
    
    // MARK: - Accesseurs
    
    func getCodeTable() -> String? {
        return codeTableActuel
    }
    
    func estPersonnalisee() -> Bool {
        return codeTableActuel != nil
    }
    
    func encoderLettre(_ char: Character) -> Int? {
        return tableEncodage[char]
    }
    
    func decoderNumero(_ numero: Int) -> Character? {
        return tableDecodage[numero]
    }
    
    func getTableEncodage() -> [Character: Int] {
        return tableEncodage
    }
    
    func getTableDecodage() -> [Int: Character] {
        return tableDecodage
    }
    
    // MARK: - Génération d'un nouveau code aléatoire
    
    func genererNouveauCode() -> String {
        let code = String(format: "%06d", Int.random(in: 0...999999))
        genererTable(avecCode: code)
        return code
    }
}

// MARK: - Générateur pseudo-aléatoire avec graine (seed)

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        // Algorithme xorshift64
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
