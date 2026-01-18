import SwiftUI
import StoreKit

struct PremiumView: View {
    @StateObject private var storeManager = StoreManager.shared
    @ObservedObject private var usageManager = UsageManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    if !usageManager.isPremium {
                        usageStatusSection
                        featuresSection
                        purchaseSection
                        restoreSection
                    } else {
                        premiumActiveSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "667eea").opacity(0.1), Color(hex: "764ba2").opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .task {
                await storeManager.loadProducts()
            }
            .alert("Achat réussi ! 🎉", isPresented: $showSuccessAlert) {
                Button("Super !") {
                    dismiss()
                }
            } message: {
                Text("Vous êtes maintenant Premium ! Profitez d'un accès illimité.")
            }
            .alert("Erreur", isPresented: $showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(storeManager.errorMessage ?? "Une erreur est survenue")
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "f5576c").opacity(0.5), radius: 20, x: 0, y: 10)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
            }
            
            Text("CourrierCode Premium")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Débloquez tout le potentiel de l'application")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Usage Status
    
    private var usageStatusSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.orange)
                Text("Utilisations aujourd'hui")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(0..<UsageManager.limiteFreeParJour, id: \.self) { index in
                    Circle()
                        .fill(index < usageManager.usageCount ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text("\(index + 1)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(index < usageManager.usageCount ? .white : .gray)
                        )
                }
                Spacer()
            }
            
            Text("\(usageManager.remainingUses) utilisation\(usageManager.remainingUses > 1 ? "s" : "") restante\(usageManager.remainingUses > 1 ? "s" : "") aujourd'hui")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Features
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Avantages Premium")
                .font(.headline)
            
            FeatureRow(icon: "infinity", title: "Encodages illimités", subtitle: "Plus de limite quotidienne", color: .purple)
            FeatureRow(icon: "bolt.fill", title: "Décodages illimités", subtitle: "Déchiffrez autant que vous voulez", color: .blue)
            FeatureRow(icon: "star.fill", title: "Achat unique", subtitle: "Payez une fois, profitez pour toujours", color: .orange)
            FeatureRow(icon: "heart.fill", title: "Soutenez le développeur", subtitle: "Aidez à créer de nouvelles fonctionnalités", color: .red)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Purchase
    
    private var purchaseSection: some View {
        VStack(spacing: 16) {
            if storeManager.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .padding()
            } else if let product = storeManager.premiumProduct {
                Button(action: {
                    Task {
                        let success = await storeManager.purchase(product)
                        if success {
                            showSuccessAlert = true
                        } else if storeManager.errorMessage != nil {
                            showErrorAlert = true
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Passer Premium")
                            .fontWeight(.bold)
                        Spacer()
                        Text(product.displayPrice)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(hex: "f5576c").opacity(0.4), radius: 10, x: 0, y: 5)
                }
            } else {
                Text("Produit non disponible")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
    
    // MARK: - Restore
    
    private var restoreSection: some View {
        Button(action: {
            Task {
                await storeManager.restorePurchases()
                if usageManager.isPremium {
                    showSuccessAlert = true
                }
            }
        }) {
            Text("Restaurer mes achats")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .disabled(storeManager.isLoading)
    }
    
    // MARK: - Premium Active
    
    private var premiumActiveSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Vous êtes Premium ! 🎉")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Profitez d'un accès illimité à toutes les fonctionnalités de CourrierCode.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}

// MARK: - Limite Atteinte View (Overlay)

struct LimiteAtteinteView: View {
    @Binding var showPremiumView: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                
                Text("Limite quotidienne atteinte")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Vous avez utilisé vos \(UsageManager.limiteFreeParJour) encodages/décodages gratuits du jour.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    showPremiumView = true
                }) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Passer Premium")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                
                Text("Ou revenez demain pour \(UsageManager.limiteFreeParJour) nouvelles utilisations gratuites !")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(30)
            .background(Color(.systemBackground))
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color.black.opacity(0.4).ignoresSafeArea())
    }
}

#Preview {
    PremiumView()
}
