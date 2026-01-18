import SwiftUI

struct DocumentationView: View {
    @State private var expandedSections: Set<String> = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerView
                    
                    // Sections
                    docSection(
                        id: "principe",
                        title: "Principe de base",
                        icon: "info.circle.fill",
                        color: AppColors.decode
                    ) {
                        principeSectionContent
                    }
                    
                    docSection(
                        id: "decalage",
                        title: "Décalage journalier",
                        icon: "calendar",
                        color: AppColors.secret
                    ) {
                        decalageSectionContent
                    }
                    
                    docSection(
                        id: "secret",
                        title: "Code secret",
                        icon: "key.fill",
                        color: AppColors.random
                    ) {
                        secretSectionContent
                    }
                    
                    docSection(
                        id: "table",
                        title: "Table aléatoire",
                        icon: "shuffle",
                        color: Color.pink
                    ) {
                        tableSectionContent
                    }
                    
                    docSection(
                        id: "encoder",
                        title: "Encoder un message",
                        icon: "pencil.circle.fill",
                        color: AppColors.encode
                    ) {
                        encoderSectionContent
                    }
                    
                    docSection(
                        id: "decoder",
                        title: "Décoder un message",
                        icon: "magnifyingglass.circle.fill",
                        color: AppColors.decode
                    ) {
                        decoderSectionContent
                    }
                    
                    docSection(
                        id: "securite",
                        title: "Conseils de sécurité",
                        icon: "shield.checkered",
                        color: .red
                    ) {
                        securiteSectionContent
                    }
                    
                    footerView
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Documentation")
                        .font(.headline)
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryGradient)
                    .frame(width: 90, height: 90)
                    .shadow(color: AppColors.decode.opacity(0.4), radius: 15, x: 0, y: 8)
                
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Text("CourrierCode")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Guide d'utilisation complet")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // MARK: - Section Builder
    private func docSection<Content: View>(
        id: String,
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    if expandedSections.contains(id) {
                        expandedSections.remove(id)
                    } else {
                        expandedSections.insert(id)
                    }
                }
            }) {
                HStack(spacing: 14) {
                    IconBadge(icon: icon, color: color, size: 38)
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: expandedSections.contains(id) ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .font(.title3)
                        .foregroundColor(color)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
            }
            
            if expandedSections.contains(id) {
                content()
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.top, -8)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95, anchor: .top).combined(with: .opacity),
                        removal: .scale(scale: 0.95, anchor: .top).combined(with: .opacity)
                    ))
            }
        }
    }
    
    // MARK: - Section Contents
    private var principeSectionContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("CourrierCode transforme vos messages en séquences de chiffres impossibles à lire sans connaître les règles de décodage.")
                .foregroundColor(.secondary)
            
            Text("Conversion des lettres")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(["A=01", "B=02", "C=03", "...", "Z=26"], id: \.self) { item in
                        Text(item)
                            .font(.system(.caption, design: .monospaced))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.decode.opacity(0.15))
                            .foregroundColor(AppColors.decode)
                            .cornerRadius(8)
                    }
                }
            }
            
            Text("Conversion des chiffres")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(["0=27", "1=28", "2=29", "...", "9=36"], id: \.self) { item in
                        Text(item)
                            .font(.system(.caption, design: .monospaced))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.secret.opacity(0.15))
                            .foregroundColor(AppColors.secret)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var decalageSectionContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Un décalage différent est appliqué selon le jour, rendant le code unique chaque jour.")
                .foregroundColor(.secondary)
            
            VStack(spacing: 6) {
                ForEach([
                    ("Lundi", "+3"),
                    ("Mardi", "+11"),
                    ("Mercredi", "+5"),
                    ("Jeudi", "+9"),
                    ("Vendredi", "+2"),
                    ("Samedi", "+13"),
                    ("Dimanche", "+7")
                ], id: \.0) { jour, decalage in
                    HStack {
                        Text(jour)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(decalage)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.secret)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }
            }
            
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Le jour d'encodage est inséré au milieu du message.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
    }
    
    private var secretSectionContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Le code secret ajoute une couche de sécurité supplémentaire au message.")
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                DocBullet(text: "Chaque lettre du code a une valeur (A=1, B=2...)")
                DocBullet(text: "Les chiffres sont ajoutés directement")
                DocBullet(text: "La somme totale devient un décalage supplémentaire")
            }
            
            HStack {
                Image(systemName: "function")
                    .foregroundColor(AppColors.random)
                Text("Exemple : Code \"ABC\" = 1+2+3 = décalage de 6")
                    .font(.callout)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.random.opacity(0.1))
            .cornerRadius(10)
            
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Le destinataire doit connaître le même code secret.")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
    
    private var tableSectionContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("La table aléatoire mélange l'ordre des lettres pour une sécurité maximale.")
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                DocStep(number: 1, text: "Générez un code à 6 chiffres dans l'onglet Table")
                DocStep(number: 2, text: "Partagez ce code avec vos correspondants")
                DocStep(number: 3, text: "Activez la même table des deux côtés")
            }
            
            HStack(spacing: 8) {
                Image(systemName: "shield.fill")
                    .foregroundColor(.green)
                Text("Sans le code de la table, le décodage est impossible !")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .padding(.top, 4)
        }
    }
    
    private var encoderSectionContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Suivez ces étapes pour encoder un message :")
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                DocStep(number: 1, text: "Allez dans l'onglet Encoder")
                DocStep(number: 2, text: "Entrez votre code secret (optionnel)")
                DocStep(number: 3, text: "Tapez votre message")
                DocStep(number: 4, text: "Copiez le résultat codé")
                DocStep(number: 5, text: "Envoyez à votre destinataire")
            }
            
            HStack(spacing: 8) {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundColor(AppColors.encode)
                Text("Le message inversé est aussi disponible pour plus de discrétion.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var decoderSectionContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Suivez ces étapes pour décoder un message :")
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                DocStep(number: 1, text: "Allez dans l'onglet Décoder")
                DocStep(number: 2, text: "Collez le message codé")
                DocStep(number: 3, text: "Entrez le code secret (si utilisé)")
                DocStep(number: 4, text: "Le jour est détecté automatiquement")
                DocStep(number: 5, text: "Lisez le message décodé")
            }
            
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Utilisez \"Inverser\" si le message a été envoyé à l'envers.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var securiteSectionContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            DocSecurityTip(icon: "checkmark.circle.fill", text: "Changez régulièrement votre code secret", isPositive: true)
            DocSecurityTip(icon: "checkmark.circle.fill", text: "Utilisez une table aléatoire pour les messages sensibles", isPositive: true)
            DocSecurityTip(icon: "checkmark.circle.fill", text: "Ne partagez jamais le code dans le même canal que le message", isPositive: true)
            DocSecurityTip(icon: "xmark.circle.fill", text: "N'utilisez pas de codes évidents (1234, 0000...)", isPositive: false)
            DocSecurityTip(icon: "xmark.circle.fill", text: "Ne laissez pas l'app déverrouillée sans surveillance", isPositive: false)
        }
    }
    
    private var footerView: some View {
        VStack(spacing: 6) {
            Text("CourrierCode v1.0")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("© 2026 - Tous droits réservés")
                .font(.caption2)
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 30)
    }
}

// MARK: - Helper Views
struct DocBullet: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(AppColors.decode)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            Text(text)
                .foregroundColor(.secondary)
        }
    }
}

struct DocStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(AppColors.primaryGradient)
                .clipShape(Circle())
            
            Text(text)
                .foregroundColor(.secondary)
        }
    }
}

struct DocSecurityTip: View {
    let icon: String
    let text: String
    let isPositive: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(isPositive ? .green : .red)
            Text(text)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill((isPositive ? Color.green : Color.red).opacity(0.1))
        )
    }
}

#Preview {
    DocumentationView()
}
