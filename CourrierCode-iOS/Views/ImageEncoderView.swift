import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ImageEncoderView: View {
    // MARK: - États
    @State private var selectedImage: UIImage?
    @State private var encodedImage: EncodedImage?
    @State private var decodedImage: UIImage?
    @State private var isShowingPhotoPicker = false
    @State private var isShowingFilePicker = false
    @State private var isShowingExportSheet = false
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var codeSecret = ""
    @State private var showPremiumView = false
    @State private var showLimiteAtteinte = false
    @State private var jsonPreview = ""
    @State private var showJSONPreview = false
    @State private var exportFileURL: URL?
    @State private var showSaveSuccess = false
    @State private var imageSaver = ImageSaver()
    
    // Mode: encodage ou décodage
    @State private var mode: ImageMode = .encode
    
    // Options d'encodage
    @State private var targetWidth: Double = 50
    @State private var useResize = true
    
    @AppStorage("codeTableSauvegarde") private var codeTable = ""
    @ObservedObject private var usageManager = UsageManager.shared
    @EnvironmentObject var appState: AppState
    
    private let imageEncoder = ImageEncoder.shared
    
    enum ImageMode: String, CaseIterable {
        case encode = "Encoder"
        case decode = "Décoder"
    }
    
    var tableAleatoireActive: Bool {
        codeTable.count == 6
    }
    
    var estimatedSize: String {
        if useResize {
            let w = Int(targetWidth)
            let h = selectedImage != nil ? Int(Double(selectedImage!.size.height) / Double(selectedImage!.size.width) * targetWidth) : w
            return imageEncoder.estimateJSONSize(width: w, height: h)
        } else if let img = selectedImage {
            return imageEncoder.estimateJSONSize(width: Int(img.size.width), height: Int(img.size.height))
        }
        return "0 Ko"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                        usageBadge
                        modeSelector
                        statusIndicators
                        
                        if mode == .encode {
                            encodeSection
                        } else {
                            decodeSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .background(Color(.systemGroupedBackground))
                
                if showLimiteAtteinte {
                    LimiteAtteinteView(showPremiumView: $showPremiumView)
                        .transition(.opacity)
                }
                
                if isProcessing {
                    processingOverlay
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Image")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showPremiumView = true }) {
                        Image(systemName: usageManager.isPremium ? "crown.fill" : "crown")
                            .foregroundColor(usageManager.isPremium ? .yellow : .gray)
                    }
                }
            }
            .sheet(isPresented: $showPremiumView) {
                PremiumView()
            }
            .sheet(isPresented: $isShowingPhotoPicker) {
                PhotoPicker(image: $selectedImage)
            }
            .sheet(isPresented: $isShowingFilePicker) {
                DocumentPicker(jsonContent: Binding(
                    get: { "" },
                    set: { content in
                        importJSON(content)
                    }
                ))
            }
            .sheet(isPresented: $isShowingExportSheet, onDismiss: {
                // Nettoyer le fichier temporaire après fermeture
                cleanupExportFile()
            }) {
                ShareSheetView(fileURL: exportFileURL)
            }
            .alert("Erreur", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert("Sauvegardé !", isPresented: $showSaveSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("L'image a été enregistrée dans votre photothèque.")
            }
            .onAppear {
                checkForImportedImage()
            }
            .onChange(of: appState.importedEncodedImage) { _, newImage in
                if newImage != nil {
                    checkForImportedImage()
                }
            }
        }
    }
    
    // Vérifie si une image a été importée depuis une autre app
    private func checkForImportedImage() {
        if let imported = appState.importedEncodedImage {
            print("📥 Image importée détectée: \(imported.width)x\(imported.height)")
            self.encodedImage = imported
            self.mode = .decode
            appState.importedEncodedImage = nil  // Réinitialiser
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                    .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 15, x: 0, y: 8)
                
                Image(systemName: "photo.badge.checkmark.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Text("Codage d'image")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Transformez vos images en code secret JSON")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 10)
        .padding(.bottom, 5)
    }
    
    // MARK: - Usage Badge
    
    private var usageBadge: some View {
        Group {
            if !usageManager.isPremium {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.orange)
                    Text("\(usageManager.remainingUses)/\(UsageManager.limiteFreeParJour) utilisations restantes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Premium") {
                        showPremiumView = true
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(LinearGradient(colors: [Color(hex: "f093fb"), Color(hex: "f5576c")], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(8)
                }
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5)
            }
        }
    }
    
    // MARK: - Mode Selector
    
    private var modeSelector: some View {
        Picker("Mode", selection: $mode) {
            ForEach(ImageMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 4)
    }
    
    // MARK: - Status Indicators
    
    private var statusIndicators: some View {
        HStack(spacing: 10) {
            if tableAleatoireActive {
                StatusPill(text: "Table: \(codeTable)", icon: "shuffle", color: AppColors.random)
            }
            if !codeSecret.isEmpty {
                StatusPill(text: "Code secret actif", icon: "key.fill", color: AppColors.secret)
            }
            Spacer()
        }
    }
    
    // MARK: - Encode Section
    
    private var encodeSection: some View {
        VStack(spacing: 16) {
            // Code secret
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Code secret", icon: "key.fill", color: AppColors.secret, subtitle: "Optionnel - Pour sécuriser l'image")
                    ModernTextField(placeholder: "Entrez un code partagé...", text: $codeSecret, icon: "lock.fill", isSecure: true, accentColor: AppColors.secret)
                }
            }
            
            // Sélection d'image
            GlassCard {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Image source", icon: "photo.on.rectangle", color: AppColors.decode)
                    
                    if let image = selectedImage {
                        VStack(spacing: 12) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.decode.opacity(0.3), lineWidth: 2)
                                )
                            
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.secondary)
                                Text("\(Int(image.size.width)) × \(Int(image.size.height)) pixels")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button(action: { selectedImage = nil; encodedImage = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    } else {
                        importImageButton
                    }
                }
            }
            
            // Options de redimensionnement
            if selectedImage != nil {
                GlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Options", icon: "slider.horizontal.3", color: AppColors.random)
                        
                        Toggle(isOn: $useResize) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Redimensionner")
                                    .font(.subheadline)
                                Text("Recommandé pour réduire la taille du fichier")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .tint(AppColors.random)
                        
                        if useResize {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Largeur cible:")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(Int(targetWidth)) px")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.random)
                                }
                                
                                Slider(value: $targetWidth, in: 10...200, step: 10)
                                    .tint(AppColors.random)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.secondary)
                            Text("Taille estimée: ")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(estimatedSize)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.encode)
                        }
                    }
                }
            }
            
            // Bouton d'encodage
            if selectedImage != nil {
                GradientButton(
                    title: "Encoder l'image",
                    icon: "lock.shield.fill",
                    gradient: AppColors.successGradient,
                    action: encodeCurrentImage,
                    fullWidth: true
                )
            }
            
            // Résultat
            if let encoded = encodedImage {
                resultSection(encoded)
            }
        }
    }
    
    // MARK: - Decode Section
    
    private var decodeSection: some View {
        VStack(spacing: 16) {
            // Code secret
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Code secret", icon: "key.fill", color: AppColors.secret, subtitle: "Si l'image a été encodée avec un code")
                    ModernTextField(placeholder: "Entrez le code secret...", text: $codeSecret, icon: "lock.fill", isSecure: true, accentColor: AppColors.secret)
                }
            }
            
            // Import JSON
            GlassCard {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Fichier JSON", icon: "doc.badge.gearshape", color: AppColors.decode)
                    
                    if encodedImage != nil {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Image encodée chargée")
                                    .font(.subheadline)
                                Spacer()
                                Button(action: { encodedImage = nil; decodedImage = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            
                            if let encoded = encodedImage {
                                HStack {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.secondary)
                                    Text("\(encoded.width) × \(encoded.height) pixels")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                        }
                    } else {
                        importJSONButton
                    }
                }
            }
            
            // Bouton de décodage
            if encodedImage != nil {
                GradientButton(
                    title: "Décoder l'image",
                    icon: "lock.open.fill",
                    gradient: AppColors.primaryGradient,
                    action: decodeCurrentImage,
                    fullWidth: true
                )
            }
            
            // Image décodée
            if let decoded = decodedImage {
                GlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            SectionHeader(title: "Image décodée", icon: "photo.fill", color: AppColors.encode)
                            Spacer()
                            Button(action: saveDecodedImage) {
                                HStack(spacing: 4) {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Sauver")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(AppColors.encode)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppColors.encode.opacity(0.15))
                                .cornerRadius(8)
                            }
                        }
                        
                        Image(uiImage: decoded)
                            .resizable()
                            .interpolation(.none) // Pour garder les pixels nets
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.encode.opacity(0.3), lineWidth: 2)
                            )
                    }
                }
            }
        }
    }
    
    // MARK: - Import Buttons
    
    private var importImageButton: some View {
        Button(action: { isShowingPhotoPicker = true }) {
            VStack(spacing: 16) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.decode)
                
                Text("Sélectionner une image")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.decode)
                
                Text("Formats: JPEG, PNG, HEIC")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                    .foregroundColor(AppColors.decode.opacity(0.3))
            )
        }
    }
    
    private var importJSONButton: some View {
        VStack(spacing: 16) {
            // Bouton Importer fichier
            Button(action: { isShowingFilePicker = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 24))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Importer un fichier")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Fichier .json depuis Fichiers")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .foregroundColor(AppColors.decode)
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.decode.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.decode.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Result Section
    
    private func resultSection(_ encoded: EncodedImage) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    SectionHeader(title: "Image encodée", icon: "checkmark.shield.fill", color: AppColors.encode)
                    Spacer()
                }
                
                // Infos
                VStack(alignment: .leading, spacing: 8) {
                    infoRow(icon: "square.grid.2x2", label: "Dimensions", value: "\(encoded.width) × \(encoded.height)")
                    infoRow(icon: "calendar", label: "Date", value: encoded.encodingDate)
                    if let day = encoded.dayOffset {
                        infoRow(icon: "sun.max", label: "Jour", value: CourrierCodeur().nomsJours[day])
                    }
                    infoRow(icon: "doc.text", label: "Taille estimée", value: imageEncoder.estimateJSONSize(width: encoded.width, height: encoded.height))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                // Actions
                HStack(spacing: 12) {
                    Button(action: { showJSONPreview = true }) {
                        HStack {
                            Image(systemName: "eye")
                            Text("Aperçu")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.decode)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.decode.opacity(0.15))
                        .cornerRadius(12)
                    }
                    
                    Button(action: exportJSON) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Exporter")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.encode)
                        .cornerRadius(12)
                    }
                }
            }
        }
        .sheet(isPresented: $showJSONPreview) {
            JSONPreviewView(encodedImage: encoded)
        }
    }
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Processing Overlay
    
    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Traitement en cours...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    // MARK: - Actions
    
    private func encodeCurrentImage() {
        guard let image = selectedImage else { return }
        
        // Vérifier l'utilisation
        guard usageManager.canUse else {
            withAnimation { showLimiteAtteinte = true }
            return
        }
        
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let targetSize: CGSize? = useResize ? CGSize(width: targetWidth, height: targetWidth) : nil
            
            let encoded = imageEncoder.encodeImage(
                image,
                withDayOffset: true,
                secretCode: codeSecret,
                tableCode: codeTable,
                targetSize: targetSize
            )
            
            DispatchQueue.main.async {
                isProcessing = false
                
                if let encoded = encoded {
                    usageManager.recordUsage()
                    self.encodedImage = encoded
                } else {
                    errorMessage = "Impossible d'encoder l'image. Veuillez réessayer."
                    showError = true
                }
            }
        }
    }
    
    private func decodeCurrentImage() {
        guard let encoded = encodedImage else { return }
        
        // Vérifier l'utilisation
        guard usageManager.canUse else {
            withAnimation { showLimiteAtteinte = true }
            return
        }
        
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let decoded = imageEncoder.decodeImage(
                encoded,
                secretCode: codeSecret,
                tableCode: codeTable
            )
            
            DispatchQueue.main.async {
                isProcessing = false
                
                if let decoded = decoded {
                    usageManager.recordUsage()
                    self.decodedImage = decoded
                } else {
                    errorMessage = "Impossible de décoder l'image. Vérifiez le code secret."
                    showError = true
                }
            }
        }
    }
    
    private func exportJSON() {
        guard let encoded = encodedImage else { return }
        guard usageManager.canUse else {
            withAnimation { showLimiteAtteinte = true }
            return
        }
        
        // Créer un fichier temporaire pour le partage
        guard let jsonData = imageEncoder.exportToJSON(encoded) else {
            errorMessage = "Impossible de générer le fichier JSON."
            showError = true
            return
        }
        
        let fileName = "CourrierCode_Image_\(Int(Date().timeIntervalSince1970)).json"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try jsonData.write(to: tempURL)
            self.exportFileURL = tempURL
            usageManager.recordUsage()
            // Petit délai pour s'assurer que le fichier est prêt
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isShowingExportSheet = true
            }
        } catch {
            errorMessage = "Impossible de créer le fichier: \(error.localizedDescription)"
            showError = true
        }
    }
    
    private func importJSON(_ content: String) {
        print("📥 importJSON appelé, contenu: \(content.prefix(200))...")
        print("📥 Longueur du contenu: \(content.count) caractères")
        
        if let encoded = imageEncoder.importFromJSONString(content) {
            print("✅ JSON décodé avec succès: \(encoded.width)x\(encoded.height)")
            self.encodedImage = encoded
            self.mode = .decode
        } else {
            print("❌ Échec du décodage JSON")
            errorMessage = "Format JSON invalide. Assurez-vous que le fichier a été créé par CourrierCode."
            showError = true
        }
    }
    
    private func pasteFromClipboard() {
        print("📋 pasteFromClipboard appelé")
        
        // Vérifier si c'est une URL de fichier
        if let url = UIPasteboard.general.url {
            print("📋 URL détectée: \(url)")
            loadJSONFromURL(url)
            return
        }
        
        // Vérifier si c'est un chemin de fichier sous forme de string
        if let clipboardString = UIPasteboard.general.string {
            print("📋 Contenu presse-papier: \(clipboardString.prefix(200))...")
            print("📋 Longueur: \(clipboardString.count) caractères")
            
            // Si ça ressemble à une URL de fichier
            if clipboardString.hasPrefix("file://") {
                if let url = URL(string: clipboardString) {
                    print("📋 Converti en URL: \(url)")
                    loadJSONFromURL(url)
                    return
                }
            }
            
            // Sinon, essayer de parser comme JSON directement
            if let encoded = imageEncoder.importFromJSONString(clipboardString) {
                print("✅ JSON collé décodé avec succès")
                self.encodedImage = encoded
            } else {
                print("❌ Échec du décodage du JSON collé")
                errorMessage = "Le contenu du presse-papier n'est pas un JSON CourrierCode valide."
                showError = true
            }
            return
        }
        
        // Rien trouvé
        print("❌ Presse-papier vide")
        errorMessage = "Le presse-papier est vide ou ne contient pas de texte."
        showError = true
    }
    
    private func loadJSONFromURL(_ url: URL) {
        print("📂 Lecture du fichier: \(url)")
        
        // Vérifier si c'est un fichier dans le sandbox d'une autre app
        let path = url.path
        if path.contains("/Library/SMS/") || path.contains("/Attachments/") {
            print("❌ Fichier dans sandbox Messages - accès refusé")
            errorMessage = "Impossible d'accéder au fichier depuis Messages.\n\nAstuce : Dans Messages, faites un appui long sur le fichier → Partager → Enregistrer dans Fichiers.\n\nPuis utilisez \"Importer un fichier\" ci-dessous."
            showError = true
            return
        }
        
        // Accéder au fichier sécurisé
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            print("📂 Contenu lu: \(content.count) caractères")
            
            if let encoded = imageEncoder.importFromJSONString(content) {
                print("✅ JSON depuis fichier décodé avec succès")
                self.encodedImage = encoded
            } else {
                print("❌ Échec du décodage du fichier JSON")
                errorMessage = "Le fichier JSON n'est pas valide."
                showError = true
            }
        } catch {
            print("❌ Erreur lecture fichier: \(error)")
            errorMessage = "Impossible de lire le fichier.\n\nAstuce : Enregistrez d'abord le fichier dans l'app Fichiers, puis utilisez \"Importer un fichier\"."
            showError = true
        }
    }
    
    private func saveDecodedImage() {
        guard let image = decodedImage else { return }
        
        imageSaver.successHandler = {
            DispatchQueue.main.async {
                self.showSaveSuccess = true
            }
        }
        
        imageSaver.errorHandler = { error in
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
        
        imageSaver.writeToPhotoAlbum(image: image)
    }
    
    private func cleanupExportFile() {
        if let url = exportFileURL {
            try? FileManager.default.removeItem(at: url)
            exportFileURL = nil
        }
    }
}

// MARK: - Share Sheet View (wrapper sécurisé)

struct ShareSheetView: View {
    let fileURL: URL?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Group {
            if let url = fileURL, FileManager.default.fileExists(atPath: url.path) {
                ShareSheet(items: [url])
            } else {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Préparation du fichier...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .onAppear {
                    // Fermer si toujours pas de fichier après 2 secondes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        if fileURL == nil {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Image Saver Helper

class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}

// MARK: - Photo Picker

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var jsonContent: String
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Accepter JSON et texte brut
        let supportedTypes: [UTType] = [.json, .plainText, .data]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("📂 DocumentPicker: fichier sélectionné")
            guard let url = urls.first else { 
                print("❌ Aucune URL")
                return 
            }
            
            print("📂 URL: \(url)")
            
            // Accéder au fichier sécurisé
            let accessing = url.startAccessingSecurityScopedResource()
            print("📂 Accès sécurisé: \(accessing)")
            defer { 
                if accessing {
                    url.stopAccessingSecurityScopedResource() 
                }
            }
            
            do {
                // Essayer de lire comme texte
                let content = try String(contentsOf: url, encoding: .utf8)
                print("📂 Contenu lu: \(content.count) caractères")
                print("📂 Début: \(content.prefix(200))")
                DispatchQueue.main.async {
                    self.parent.jsonContent = content
                    self.parent.dismiss()
                }
            } catch {
                print("❌ Erreur lecture texte: \(error)")
                // Si ça échoue, essayer de lire comme data
                do {
                    let data = try Data(contentsOf: url)
                    print("📂 Data lue: \(data.count) bytes")
                    if let content = String(data: data, encoding: .utf8) {
                        print("📂 Converti en string: \(content.count) caractères")
                        DispatchQueue.main.async {
                            self.parent.jsonContent = content
                            self.parent.dismiss()
                        }
                    }
                } catch {
                    print("❌ Erreur lecture data: \(error)")
                }
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - JSON Preview View

struct JSONPreviewView: View {
    let encodedImage: EncodedImage
    @Environment(\.dismiss) var dismiss
    
    var jsonPreview: String {
        guard let data = ImageEncoder.shared.exportToJSON(encodedImage),
              let string = String(data: data, encoding: .utf8) else {
            return "Erreur de génération"
        }
        // Limiter à 5000 caractères pour la preview
        if string.count > 5000 {
            return String(string.prefix(5000)) + "\n\n... (tronqué pour la prévisualisation)"
        }
        return string
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(jsonPreview)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(.systemGray6))
            .navigationTitle("Aperçu JSON")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ImageEncoderView()
        .environmentObject(AppState.shared)
}
