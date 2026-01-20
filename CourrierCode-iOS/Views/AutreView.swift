import SwiftUI

struct AutreView: View {
    @State private var showCarnet = false
    @State private var showAide = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // En-tête
                    VStack(spacing: 8) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Plus d'options")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Boutons
                    VStack(spacing: 16) {
                        // Bouton Carnet
                        NavigationLink(destination: CarnetView()) {
                            AutreButtonCard(
                                icon: "person.2.fill",
                                title: "Carnet de codes",
                                subtitle: "Gérez vos correspondants et leurs codes",
                                gradientColors: [Color(hex: "667eea"), Color(hex: "764ba2")]
                            )
                        }
                        
                        // Bouton Aide
                        NavigationLink(destination: DocumentationView()) {
                            AutreButtonCard(
                                icon: "book.fill",
                                title: "Aide & Documentation",
                                subtitle: "Apprenez à utiliser Courrier Codé",
                                gradientColors: [Color(hex: "11998e"), Color(hex: "38ef7d")]
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Autre")
                        .font(.headline)
                }
            }
        }
    }
}

// Composant bouton stylisé
struct AutreButtonCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradientColors: [Color]
    
    var body: some View {
        HStack(spacing: 16) {
            // Icône avec fond gradient
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // Textes
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }
}

#Preview {
    AutreView()
}
