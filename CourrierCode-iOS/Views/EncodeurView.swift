import SwiftUI
import CoreImage.CIFilterBuiltins

// Structure identifiable pour passer le message au QRCodeView
struct QRCodeItem: Identifiable {
    let id = UUID()
    let message: String
}

struct EncodeurView: View {
    @State private var texteOriginal = ""
    @State private var codeSecret = ""
    @State private var showCopiedAlert = false
    @State private var showInverse = false
    @State private var showMelange = false
    @State private var texteMelange = ""
    @State private var showPremiumView = false
    @State private var showLimiteAtteinte = false
    @State private var correspondantSelectionne: Correspondant? = nil
    @State private var isShowingExportSheet = false
    @State private var exportFileURL: URL?
    @State private var qrCodeItem: QRCodeItem? = nil
    
    @AppStorage("codeTableSauvegarde") private var codeTable = ""
    @ObservedObject private var usageManager = UsageManager.shared
    @ObservedObject private var contactsManager = ContactsManager.shared
    @EnvironmentObject var appState: AppState
    
    private let codeur = CourrierCodeur()
    
    // Codes effectifs (du correspondant sélectionné ou saisis manuellement)
    private var effectiveCodeSecret: String {
        correspondantSelectionne?.codeSecret ?? codeSecret
    }
    
    private var effectiveCodeTable: String {
        correspondantSelectionne?.codeTable ?? codeTable
    }
    
    var messageCode: String {
        codeur.encoder(texte: texteOriginal, avecDecalage: true, codeSecret: effectiveCodeSecret, codeTable: effectiveCodeTable)
    }
    
    var messageInverse: String {
        String(messageCode.reversed())
    }
    
    // Code mélangé = encodage de la phrase mélangée
    var messageMelange: String {
        guard !texteMelange.isEmpty else { return "" }
        return codeur.encoder(texte: texteMelange, avecDecalage: true, codeSecret: effectiveCodeSecret, codeTable: effectiveCodeTable)
    }
    
    var tableAleatoireActive: Bool {
        effectiveCodeTable.count == 6
    }
    
    // Fonction pour mélanger les mots du texte original
    private func melangerMotsOriginaux() {
        let mots = texteOriginal.split(separator: " ").map(String.init)
        texteMelange = mots.shuffled().joined(separator: " ")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                        usageBadge
                        if contactsManager.hasCorrespondants {
                            correspondantSelector
                        }
                        statusIndicators
                        if correspondantSelectionne == nil {
                            codeSecretSection
                        }
                        inputSection
                        melangeTexteSection
                        resultSection
                        actionButtons
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .background(Color(.systemGroupedBackground))
                
                // Overlay si limite atteinte
                if showLimiteAtteinte {
                    LimiteAtteinteView(showPremiumView: $showPremiumView)
                        .transition(.opacity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Encodeur")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showPremiumView = true }) {
                        Image(systemName: usageManager.isPremium ? "crown.fill" : "crown")
                            .foregroundColor(usageManager.isPremium ? .yellow : .gray)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("OK") { hideKeyboard() }
                }
            }
            .sheet(isPresented: $showPremiumView) {
                PremiumView()
            }
            .sheet(isPresented: $isShowingExportSheet, onDismiss: {
                cleanupExportFile()
            }) {
                MessageShareSheetView(fileURL: exportFileURL)
            }
            .sheet(item: $qrCodeItem) { item in
                QRCodeView(message: item.message)
            }
            .onAppear {
                checkForMessageToEncode()
            }
            .onChange(of: appState.messageToEncode) { _, newMessage in
                if newMessage != nil {
                    checkForMessageToEncode()
                }
            }
        }
    }
    
    // Vérifie si un message doit être encodé (venant d'une autre app)
    private func checkForMessageToEncode() {
        if let message = appState.messageToEncode {
            print("📥 Message à encoder détecté: \(message.count) caractères")
            self.texteOriginal = message
            appState.messageToEncode = nil
        }
    }
    
    // Badge d'utilisation
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
    
    private var headerView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.successGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: AppColors.encode.opacity(0.4), radius: 15, x: 0, y: 8)
                
                Image(systemName: "pencil.and.outline")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Text("Encoder un message")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Transformez votre texte en code secret")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 10)
        .padding(.bottom, 5)
    }
    
    // Sélecteur de correspondant du carnet
    private var correspondantSelector: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Destinataire", icon: "person.fill", color: Color(hex: "667eea"), subtitle: "Sélectionnez un correspondant du carnet")
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Option "Manuel"
                        Button(action: { correspondantSelectionne = nil }) {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(correspondantSelectionne == nil ? 
                                              LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                              LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "pencil")
                                        .font(.title3)
                                        .foregroundColor(correspondantSelectionne == nil ? .white : .gray)
                                }
                                Text("Manuel")
                                    .font(.caption)
                                    .foregroundColor(correspondantSelectionne == nil ? Color(hex: "667eea") : .secondary)
                            }
                        }
                        
                        // Correspondants du carnet
                        ForEach(contactsManager.correspondants) { correspondant in
                            Button(action: { correspondantSelectionne = correspondant }) {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(correspondantSelectionne?.id == correspondant.id ?
                                                  LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                                  LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 50, height: 50)
                                        
                                        Text(String(correspondant.nom.prefix(1)).uppercased())
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(correspondantSelectionne?.id == correspondant.id ? .white : .gray)
                                    }
                                    Text(correspondant.nom)
                                        .font(.caption)
                                        .foregroundColor(correspondantSelectionne?.id == correspondant.id ? Color(hex: "667eea") : .secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                
                if let correspondant = correspondantSelectionne {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Codes de \(correspondant.nom) utilisés")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }
    
    private var statusIndicators: some View {
        HStack(spacing: 10) {
            if let correspondant = correspondantSelectionne {
                StatusPill(text: correspondant.nom, icon: "person.fill", color: Color(hex: "667eea"))
            }
            if tableAleatoireActive {
                StatusPill(text: "Table: \(effectiveCodeTable)", icon: "shuffle", color: AppColors.random)
            }
            if correspondantSelectionne == nil && !codeSecret.isEmpty {
                StatusPill(text: "Code secret actif", icon: "key.fill", color: AppColors.secret)
            }
            Spacer()
        }
    }
    
    private var codeSecretSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Code secret", icon: "key.fill", color: AppColors.secret, subtitle: "Optionnel - Partagez-le avec votre destinataire")
                ModernTextField(placeholder: "Entrez un code partagé...", text: $codeSecret, icon: "lock.fill", isSecure: true, accentColor: AppColors.secret)
            }
        }
    }
    
    private var inputSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Votre message", icon: "text.alignleft", color: AppColors.decode)
                ModernTextEditor(placeholder: "Tapez votre message ici...", text: $texteOriginal, minHeight: 120, accentColor: AppColors.decode)
                if !texteOriginal.isEmpty {
                    HStack {
                        Image(systemName: "character.cursor.ibeam")
                            .foregroundColor(.secondary)
                        Text("\(texteOriginal.count) caractères")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    // Section mélange du texte original (sous la zone de saisie)
    @ViewBuilder
    private var melangeTexteSection: some View {
        if !texteOriginal.isEmpty {
            VStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if texteMelange.isEmpty {
                            melangerMotsOriginaux()
                        } else {
                            texteMelange = ""
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "shuffle")
                        Text(texteMelange.isEmpty ? "🔀 Mélanger les mots" : "Masquer le mélange")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.pink)
                    .padding(.vertical, 8)
                }
                
                if !texteMelange.isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                SectionHeader(title: "Mots mélangés", icon: "shuffle", color: .pink)
                                Spacer()
                                Button(action: { melangerMotsOriginaux() }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "dice.fill")
                                        Text("Remélanger")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.pink)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.pink.opacity(0.15))
                                    .cornerRadius(8)
                                }
                                Button(action: { exportMessage(texteMelange, prefix: "MotsMelanges") }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.pink)
                                        .cornerRadius(8)
                                }
                                AnimatedCopyButton(action: { copyToClipboard(texteMelange) }, color: .pink)
                            }
                            Text(texteMelange)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.pink)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.pink.opacity(0.1)))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.pink.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5])))
                        }
                    }
                    .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity), removal: .scale(scale: 0.9).combined(with: .opacity)))
                }
            }
        }
    }
    
    private var resultSection: some View {
        VStack(spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        SectionHeader(title: "Message codé", icon: "lock.shield.fill", color: AppColors.encode)
                        Spacer()
                        // Bouton QR Code
                        Button(action: { 
                            print("🔘 Bouton QR cliqué, messageCode: '\(messageCode)' (\(messageCode.count) caractères)")
                            qrCodeItem = QRCodeItem(message: messageCode)
                        }) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(AppColors.encode)
                                .cornerRadius(8)
                        }
                        // Bouton partage lien CourrierCode
                        Button(action: { shareAsLink(messageCode) }) {
                            Image(systemName: "link")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(AppColors.encode)
                                .cornerRadius(8)
                        }
                        Button(action: { exportMessage(messageCode, prefix: "Code") }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(AppColors.encode)
                                .cornerRadius(8)
                        }
                        AnimatedCopyButton(action: { copyToClipboard(messageCode) }, color: AppColors.encode)
                    }
                    Text(messageCode.isEmpty ? "Le code apparaîtra ici..." : messageCode)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(messageCode.isEmpty ? .secondary : .white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.8)))
                }
            }
            
            if !messageCode.isEmpty {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showInverse.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.left.arrow.right")
                        Text(showInverse ? "Masquer l'inversé" : "Afficher inversé")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(AppColors.random)
                    .padding(.vertical, 8)
                }
                
                if showInverse {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                SectionHeader(title: "Message inversé", icon: "arrow.uturn.backward", color: AppColors.random)
                                Spacer()
                                Button(action: { exportMessage(messageInverse, prefix: "Inverse") }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(AppColors.random)
                                        .cornerRadius(8)
                                }
                                AnimatedCopyButton(action: { copyToClipboard(messageInverse) }, color: AppColors.random)
                            }
                            Text(messageInverse)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.8)))
                        }
                    }
                    .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity), removal: .scale(scale: 0.9).combined(with: .opacity)))
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showMelange.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "shuffle")
                        Text(showMelange ? "Masquer le mélange" : "Mélanger le code")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(AppColors.secret)
                    .padding(.vertical, 8)
                }
                
                if showMelange {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                SectionHeader(title: "Code mélangé", icon: "shuffle", color: AppColors.secret)
                                Spacer()
                                Button(action: { exportMessage(messageMelange, prefix: "Melange") }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(AppColors.secret)
                                        .cornerRadius(8)
                                }
                                AnimatedCopyButton(action: { copyToClipboard(messageMelange) }, color: AppColors.secret)
                            }
                            Text(messageMelange)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.8)))
                        }
                    }
                    .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity), removal: .scale(scale: 0.9).combined(with: .opacity)))
                }
            }
        }
    }
    
    private var actionButtons: some View {
        GradientButton(title: "Effacer tout", icon: "trash.fill", gradient: AppColors.dangerGradient, action: {
            withAnimation {
                texteOriginal = ""
                codeSecret = ""
                showInverse = false
                showMelange = false
                texteMelange = ""
            }
        }, fullWidth: true)
        .opacity(texteOriginal.isEmpty ? 0.5 : 1)
        .disabled(texteOriginal.isEmpty)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func copyToClipboard(_ text: String) {
        // Vérifier si l'utilisateur peut encore utiliser
        guard usageManager.canUse else {
            withAnimation {
                showLimiteAtteinte = true
            }
            return
        }
        
        // Enregistrer l'utilisation
        usageManager.recordUsage()
        
        // Copier dans le presse-papier
        UIPasteboard.general.string = text
    }
    
    private func exportMessage(_ message: String, prefix: String) {
        guard !message.isEmpty else { return }
        guard usageManager.canUse else {
            withAnimation { showLimiteAtteinte = true }
            return
        }
        
        let fileName = "CourrierCode_\(prefix)_\(Int(Date().timeIntervalSince1970)).txt"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try message.write(to: tempURL, atomically: true, encoding: .utf8)
            self.exportFileURL = tempURL
            usageManager.recordUsage()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isShowingExportSheet = true
            }
        } catch {
            print("Erreur export: \(error.localizedDescription)")
        }
    }
    
    private func shareAsLink(_ message: String) {
        guard !message.isEmpty else { return }
        guard usageManager.canUse else {
            withAnimation { showLimiteAtteinte = true }
            return
        }
        
        // Créer le lien courriercode://
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? message
        let link = "courriercode://decode?message=\(encodedMessage)"
        
        usageManager.recordUsage()
        
        // Partager le lien
        let activityVC = UIActivityViewController(activityItems: [link], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func cleanupExportFile() {
        if let url = exportFileURL {
            try? FileManager.default.removeItem(at: url)
            exportFileURL = nil
        }
    }
}

// MARK: - QR Code View

struct QRCodeView: View {
    let message: String
    @Environment(\.dismiss) var dismiss
    @State private var qrImage: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Scannez ce QR code")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("L'autre utilisateur peut scanner ce code avec son app CourrierCode pour recevoir le message")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if let qrImage = qrImage {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                } else {
                    ProgressView()
                        .frame(width: 250, height: 250)
                }
                
                VStack(spacing: 12) {
                    Button(action: saveQRCode) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Enregistrer l'image")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.encode)
                        .cornerRadius(12)
                    }
                    
                    Button(action: shareQRCode) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Partager")
                        }
                        .font(.headline)
                        .foregroundColor(AppColors.encode)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.encode.opacity(0.15))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                generateQRCode()
            }
        }
    }
    
    private func generateQRCode() {
        print("📊 Génération QR Code avec message: '\(message)' (\(message.count) caractères)")
        
        guard !message.isEmpty else {
            print("❌ Message vide, QR code non généré")
            return
        }
        
        // Encoder le message pour l'URL
        guard let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            print("❌ Impossible d'encoder le message")
            return
        }
        
        let link = "courriercode://decode?message=\(encodedMessage)"
        print("📊 Lien QR Code: \(link)")
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(link.utf8)
        filter.correctionLevel = "M"
        
        if let outputImage = filter.outputImage {
            let scale = 250 / outputImage.extent.width
            let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                qrImage = UIImage(cgImage: cgImage)
            }
        }
    }
    
    private func saveQRCode() {
        guard let image = qrImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    private func shareQRCode() {
        guard let image = qrImage else { return }
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        // Trouver le ViewController le plus haut dans la hiérarchie
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            // Trouver le contrôleur présenté le plus haut
            var topController = rootVC
            while let presented = topController.presentedViewController {
                topController = presented
            }
            topController.present(activityVC, animated: true)
        }
    }
}

// MARK: - Message Share Sheet View

struct MessageShareSheetView: View {
    let fileURL: URL?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Group {
            if let url = fileURL, FileManager.default.fileExists(atPath: url.path) {
                MessageShareSheet(items: [url])
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

struct MessageShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    EncodeurView()
        .environmentObject(AppState.shared)
}
