import Foundation
import SwiftUI

/// Gestionnaire des utilisations quotidiennes (modèle freemium)
class UsageManager: ObservableObject {
    static let shared = UsageManager()
    
    // MARK: - Configuration
    
    /// Nombre d'utilisations gratuites par jour
    static let limiteFreeParJour = 5
    
    // MARK: - Clés UserDefaults
    
    private let usageCountKey = "usageCount"
    private let lastUsageDateKey = "lastUsageDate"
    private let isPremiumKey = "isPremium"
    
    // MARK: - Propriétés publiées
    
    @Published var usageCount: Int {
        didSet {
            UserDefaults.standard.set(usageCount, forKey: usageCountKey)
        }
    }
    
    @Published var isPremium: Bool {
        didSet {
            UserDefaults.standard.set(isPremium, forKey: isPremiumKey)
        }
    }
    
    // MARK: - Initialisation
    
    private init() {
        self.usageCount = UserDefaults.standard.integer(forKey: usageCountKey)
        self.isPremium = UserDefaults.standard.bool(forKey: isPremiumKey)
        
        // Vérifier si on doit réinitialiser le compteur (nouveau jour)
        checkAndResetIfNewDay()
    }
    
    // MARK: - Gestion du compteur
    
    /// Vérifie si c'est un nouveau jour et réinitialise le compteur
    private func checkAndResetIfNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = UserDefaults.standard.object(forKey: lastUsageDateKey) as? Date {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            
            if today > lastDay {
                // Nouveau jour, réinitialiser le compteur
                usageCount = 0
            }
        }
        
        UserDefaults.standard.set(today, forKey: lastUsageDateKey)
    }
    
    /// Vérifie si l'utilisateur peut encore utiliser l'app
    var canUse: Bool {
        if isPremium { return true }
        checkAndResetIfNewDay()
        return usageCount < UsageManager.limiteFreeParJour
    }
    
    /// Nombre d'utilisations restantes
    var remainingUses: Int {
        if isPremium { return .max }
        checkAndResetIfNewDay()
        return max(0, UsageManager.limiteFreeParJour - usageCount)
    }
    
    /// Incrémente le compteur d'utilisation
    func recordUsage() {
        guard !isPremium else { return }
        checkAndResetIfNewDay()
        usageCount += 1
    }
    
    /// Active le mode Premium (après achat)
    func activatePremium() {
        isPremium = true
    }
    
    /// Restaure les achats (vérifie si Premium était déjà acheté)
    func restorePremium() {
        // Cette fonction sera appelée après la vérification StoreKit
        // Le statut sera mis à jour par StoreManager
    }
    
    // MARK: - Debug (à supprimer en production)
    
    #if DEBUG
    func resetForTesting() {
        usageCount = 0
        isPremium = false
    }
    
    func simulatePremium() {
        isPremium = true
    }
    #endif
}
