import SwiftUI

// Wrapper pour rendre String identifiable
struct ImageItem: Identifiable {
    let id = UUID()
    let name: String
}

struct DocumentationView: View {
    @State private var expandedSections: Set<String> = []
    @State private var selectedImageItem: ImageItem? = nil
    
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
                        id: "acces",
                        title: "Accès à la table",
                        icon: "lock.fill",
                        color: .orange
                    ) {
                        accesTableSectionContent
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
                        id: "carnet",
                        title: "Carnet & Face ID",
                        icon: "faceid",
                        color: Color(hex: "667eea")
                    ) {
                        carnetFaceIDSectionContent
                    }
                    
                    docSection(
                        id: "image",
                        title: "Codage d'images",
                        icon: "photo.circle.fill",
                        color: Color(hex: "667eea")
                    ) {
                        imageSectionContent
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
        .sheet(item: $selectedImageItem) { item in
            FullScreenImageView(imageName: item.name)
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
    
    private var accesTableSectionContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("La table de correspondance est protégée par un code d'accès pour empêcher les regards indiscrets.")
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.orange)
                Text("Code par défaut : 1234")
                    .font(.callout)
                    .fontWeight(.semibold)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 8) {
                DocBullet(text: "Ce code protège l'accès à la table, pas vos messages")
                DocBullet(text: "Vous pouvez le modifier à tout moment")
                DocBullet(text: "Pensez à le changer dès la première utilisation")
            }
            
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Changez ce code par défaut pour plus de sécurité !")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .padding(.top, 4)
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
    
    // MARK: - Section Carnet & Face ID
    private var carnetFaceIDSectionContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Simplifiez le décodage grâce à Face ID et votre carnet de correspondants.")
                .foregroundColor(.secondary)
            
            // Concept
            Divider()
            Text("Le concept")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                DocBullet(text: "Vous êtes le propriétaire du téléphone (Face ID vous authentifie)")
                DocBullet(text: "Votre carnet contient vos correspondants et leurs codes")
                DocBullet(text: "Quand vous recevez un message, l'app trouve automatiquement l'expéditeur")
            }
            
            // Ajouter un correspondant
            Divider()
            Text("Ajouter un correspondant")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                DocStep(number: 1, text: "Aller dans Autre → Carnet de codes")
                DocStep(number: 2, text: "S'authentifier avec Face ID")
                DocStep(number: 3, text: "Appuyer sur + pour ajouter")
                DocStep(number: 4, text: "Entrer le nom du correspondant")
                DocStep(number: 5, text: "Entrer son code secret (celui que vous avez convenu ensemble)")
                DocStep(number: 6, text: "Entrer son code table (6 chiffres, si utilisé)")
            }
            
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Chaque correspondant peut avoir des codes différents.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Décoder avec Face ID
            Divider()
            Text("Décoder avec Face ID")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                DocStep(number: 1, text: "Aller dans l'onglet Décoder")
                DocStep(number: 2, text: "Activer \"Décodage automatique\"")
                DocStep(number: 3, text: "Coller le message codé")
                DocStep(number: 4, text: "Appuyer sur \"Décoder avec Face ID\"")
                DocStep(number: 5, text: "L'app teste tous vos correspondants")
                DocStep(number: 6, text: "Le nom de l'expéditeur s'affiche avec le message")
            }
            
            HStack(spacing: 8) {
                Image(systemName: "abc")
                    .foregroundColor(Color(hex: "667eea"))
                Text("Mode ABC : pour les messages sans espaces, utilisez \"Décoder ABC\"")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Encoder pour un correspondant
            Divider()
            Text("Encoder pour un correspondant")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                DocStep(number: 1, text: "Aller dans l'onglet Encoder")
                DocStep(number: 2, text: "Si vous avez des correspondants, ils apparaissent en haut")
                DocStep(number: 3, text: "Sélectionner le destinataire")
                DocStep(number: 4, text: "Ses codes sont utilisés automatiquement")
                DocStep(number: 5, text: "Écrire et encoder votre message")
            }
            
            // Table protégée
            Divider()
            Text("Protéger la table de référence")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("La table de correspondance des lettres peut être déverrouillée par Face ID ou par code (1234 par défaut).")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.green)
                Text("Face ID protège vos codes - même si quelqu'un prend votre téléphone, il ne peut pas décoder sans votre visage.")
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
    
    // MARK: - Section Image
    private var imageSectionContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Transformez vos images en fichiers JSON codés, illisibles sans l'application.")
                .foregroundColor(.secondary)
            
            // Principe
            Text("Principe")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                DocBullet(text: "Chaque pixel (couleur RGB) est converti en codes numériques")
                DocBullet(text: "Le décalage du jour et le code secret s'appliquent")
                DocBullet(text: "L'image est exportée en fichier JSON")
            }
            
            Divider()
            
            // Encoder une image
            Text("Encoder une image")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                DocStep(number: 1, text: "Aller dans l'onglet Image → Encoder")
                DocStep(number: 2, text: "Sélectionner une image depuis votre photothèque")
                DocStep(number: 3, text: "Ajuster la taille (plus petit = fichier plus léger)")
                DocStep(number: 4, text: "Optionnel : ajouter un code secret")
                DocStep(number: 5, text: "Appuyer sur \"Encoder l'image\"")
                DocStep(number: 6, text: "Exporter le fichier JSON via Messages, Mail, AirDrop...")
            }
            
            Divider()
            
            // Décoder une image
            Text("Décoder une image")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("Vous avez reçu un fichier JSON mystérieux ? Voici comment révéler l'image cachée :")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            VStack(alignment: .leading, spacing: 12) {
                DocStep(number: 1, text: "Ouvrez le message contenant la pièce jointe JSON")
                DocStep(number: 2, text: "Touchez la pièce jointe pour l'ouvrir")
                
                // Image tutoriel 1 - Aperçu JSON
                ZoomableTutorialImage(imageName: "TutorialJSONPreview", selectedImageItem: $selectedImageItem)
                
                DocStep(number: 3, text: "Appuyez sur le bouton de partage (en bas à droite)")
                DocStep(number: 4, text: "Sélectionnez \"Courrier Codé\" dans la liste des apps")
                
                // Image tutoriel 2 - Share Sheet
                ZoomableTutorialImage(imageName: "TutorialShareSheet", selectedImageItem: $selectedImageItem)
                
                DocStep(number: 5, text: "Entrez le code secret si l'image en nécessite un")
                DocStep(number: 6, text: "Appuyez sur \"Décoder\" et admirez le résultat !")
                DocStep(number: 7, text: "Sauvegardez l'image dans votre photothèque")
            }
            
            // Astuce favori
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Astuce")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("Pour un accès rapide, maintenez l'icône \"Courrier Codé\" dans la feuille de partage et choisissez \"Ajouter aux favoris\". L'app apparaîtra toujours en première ligne !")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.yellow.opacity(0.1))
            )
            
            Divider()
            
            // Info importante
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Color(hex: "667eea"))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Taille recommandée")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("Pour des fichiers légers, utilisez 30-50 pixels de largeur. L'image sera pixelisée mais parfaitement reconnaissable.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "667eea").opacity(0.1))
            )
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

// MARK: - Zoomable Tutorial Image
struct ZoomableTutorialImage: View {
    let imageName: String
    @Binding var selectedImageItem: ImageItem?
    
    var body: some View {
        Button(action: {
            selectedImageItem = ImageItem(name: imageName)
        }) {
            ZStack(alignment: .bottomTrailing) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                // Icône de zoom
                Image(systemName: "plus.magnifyingglass")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .padding(8)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 8)
    }
}

// MARK: - Full Screen Image View
struct FullScreenImageView: View {
    let imageName: String
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .onTapGesture(count: 2) {
                        withAnimation(.spring()) {
                            scale = scale > 1 ? 1 : 2.5
                        }
                    }
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = min(max(value, 1), 4)
                            }
                    )
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    DocumentationView()
}
