import Foundation
import LocalAuthentication
import Security

class BiometricManager: ObservableObject {
    static let shared = BiometricManager()
    
    @Published var isBiometricEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBiometricEnabled, forKey: "biometricEnabled")
        }
    }
    
    @Published var isAuthenticated = false
    
    private let keychainServiceCodeSecret = "com.courriercode.codeSecret"
    private let keychainServiceCodeTable = "com.courriercode.codeTable"
    
    private init() {
        self.isBiometricEnabled = UserDefaults.standard.bool(forKey: "biometricEnabled")
    }
    
    // MARK: - Vérification disponibilité biométrie
    
    var biometricType: LABiometryType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        return context.biometryType
    }
    
    var biometricTypeString: String {
        switch biometricType {
        case .none:
            return "Non disponible"
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        @unknown default:
            return "Biométrie"
        }
    }
    
    var biometricIcon: String {
        switch biometricType {
        case .none:
            return "lock.fill"
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        @unknown default:
            return "lock.fill"
        }
    }
    
    var isBiometricAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    // MARK: - Authentification biométrique
    
    func authenticate(reason: String, completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(false, error)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
            DispatchQueue.main.async {
                self.isAuthenticated = success
                completion(success, authError)
            }
        }
    }
    
    // MARK: - Stockage sécurisé Keychain
    
    func saveCodeSecret(_ code: String) -> Bool {
        return saveToKeychain(code, service: keychainServiceCodeSecret)
    }
    
    func saveCodeTable(_ code: String) -> Bool {
        return saveToKeychain(code, service: keychainServiceCodeTable)
    }
    
    func getCodeSecret(completion: @escaping (String?) -> Void) {
        guard isBiometricEnabled else {
            completion(nil)
            return
        }
        
        authenticate(reason: "Remplir automatiquement votre code secret") { success, _ in
            if success {
                completion(self.getFromKeychain(service: self.keychainServiceCodeSecret))
            } else {
                completion(nil)
            }
        }
    }
    
    func getCodeTable(completion: @escaping (String?) -> Void) {
        guard isBiometricEnabled else {
            completion(nil)
            return
        }
        
        authenticate(reason: "Remplir automatiquement votre code table") { success, _ in
            if success {
                completion(self.getFromKeychain(service: self.keychainServiceCodeTable))
            } else {
                completion(nil)
            }
        }
    }
    
    /// Récupère les deux codes en une seule authentification
    func getCodes(completion: @escaping (_ codeSecret: String?, _ codeTable: String?) -> Void) {
        guard isBiometricEnabled else {
            completion(nil, nil)
            return
        }
        
        authenticate(reason: "Remplir automatiquement vos codes") { success, _ in
            if success {
                let codeSecret = self.getFromKeychain(service: self.keychainServiceCodeSecret)
                let codeTable = self.getFromKeychain(service: self.keychainServiceCodeTable)
                completion(codeSecret, codeTable)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    /// Authentifie et récupère les codes en une seule opération (pour l'ouverture automatique)
    func authenticateAndGetCodes(completion: @escaping (_ success: Bool, _ codeSecret: String?, _ codeTable: String?) -> Void) {
        guard hasSavedCodes() else {
            completion(false, nil, nil)
            return
        }
        
        authenticate(reason: "Déverrouiller vos codes pour décoder") { success, _ in
            if success {
                let codeSecret = self.getFromKeychain(service: self.keychainServiceCodeSecret)
                let codeTable = self.getFromKeychain(service: self.keychainServiceCodeTable)
                completion(true, codeSecret, codeTable)
            } else {
                completion(false, nil, nil)
            }
        }
    }
    
    func hasSavedCodes() -> Bool {
        let hasSecret = getFromKeychain(service: keychainServiceCodeSecret) != nil
        let hasTable = getFromKeychain(service: keychainServiceCodeTable) != nil
        return hasSecret || hasTable
    }
    
    func clearSavedCodes() {
        deleteFromKeychain(service: keychainServiceCodeSecret)
        deleteFromKeychain(service: keychainServiceCodeTable)
    }
    
    // MARK: - Keychain privé
    
    private func saveToKeychain(_ value: String, service: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // Supprimer l'ancienne valeur si elle existe
        deleteFromKeychain(service: service)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func getFromKeychain(service: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    private func deleteFromKeychain(service: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        SecItemDelete(query as CFDictionary)
    }
}
