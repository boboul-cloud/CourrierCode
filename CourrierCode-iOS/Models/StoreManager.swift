import Foundation
import StoreKit

/// Gestionnaire des achats in-app (StoreKit 2)
@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    // MARK: - Product IDs
    
    /// ID du produit Premium (à configurer dans App Store Connect)
    static let premiumProductID = "com.courriercode.premium"
    
    // MARK: - Propriétés publiées
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Computed properties
    
    var premiumProduct: Product? {
        products.first { $0.id == StoreManager.premiumProductID }
    }
    
    var isPremiumPurchased: Bool {
        purchasedProductIDs.contains(StoreManager.premiumProductID)
    }
    
    // MARK: - Initialisation
    
    private init() {
        // Écouter les transactions en arrière-plan
        Task {
            await listenForTransactions()
        }
    }
    
    // MARK: - Chargement des produits
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let productIDs: Set<String> = [StoreManager.premiumProductID]
            products = try await Product.products(for: productIDs)
            
            // Vérifier les achats existants
            await updatePurchasedProducts()
            
        } catch {
            errorMessage = "Impossible de charger les produits: \(error.localizedDescription)"
            print("Erreur chargement produits: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Achat
    
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Vérifier la transaction
                let transaction = try checkVerified(verification)
                
                // Ajouter aux achats
                purchasedProductIDs.insert(transaction.productID)
                
                // Activer Premium
                UsageManager.shared.activatePremium()
                
                // Finaliser la transaction
                await transaction.finish()
                
                isLoading = false
                return true
                
            case .userCancelled:
                errorMessage = nil
                isLoading = false
                return false
                
            case .pending:
                errorMessage = "Achat en attente d'approbation"
                isLoading = false
                return false
                
            @unknown default:
                errorMessage = "Erreur inconnue"
                isLoading = false
                return false
            }
            
        } catch {
            errorMessage = "Erreur d'achat: \(error.localizedDescription)"
            print("Erreur achat: \(error)")
            isLoading = false
            return false
        }
    }
    
    // MARK: - Restauration des achats
    
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            
            if isPremiumPurchased {
                UsageManager.shared.activatePremium()
            }
            
        } catch {
            errorMessage = "Impossible de restaurer: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Mise à jour des achats
    
    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchased.insert(transaction.productID)
            }
        }
        
        purchasedProductIDs = purchased
        
        // Synchroniser avec UsageManager
        if isPremiumPurchased {
            UsageManager.shared.activatePremium()
        }
    }
    
    // MARK: - Écoute des transactions
    
    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
                
                if transaction.productID == StoreManager.premiumProductID {
                    UsageManager.shared.activatePremium()
                }
                
                await transaction.finish()
            }
        }
    }
    
    // MARK: - Vérification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Erreurs

enum StoreError: Error {
    case failedVerification
    case productNotFound
}
