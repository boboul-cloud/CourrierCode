import SwiftUI
import AVFoundation
import AudioToolbox

struct DecodeurView: View {
    @State private var texteCrypte = ""
    @State private var codeSecret = ""
    @State private var codeTableManuel = ""
    @State private var messageDecode = ""
    @State private var showCopiedAlert = false
    @State private var jourDetecte: String? = nil
    @State private var showPremiumView = false
    @State private var showLimiteAtteinte = false
    @State private var correspondantDetecte: String? = nil  // Nom du correspondant détecté
    @State private var modeCarnet = false  // Mode décodage automatique avec carnet
    @State private var showQRScanner = false
    
    @ObservedObject private var usageManager = UsageManager.shared
    @ObservedObject private var biometricManager = BiometricManager.shared
    @ObservedObject private var contactsManager = ContactsManager.shared
    @EnvironmentObject var appState: AppState
    private let codeur = CourrierCodeur()
    
    var tableAleatoireActive: Bool {
        codeTableManuel.count == 6
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                        usageBadge
                        if contactsManager.hasCorrespondants {
                            modeSelector
                        }
                        statusIndicators
                        if !modeCarnet {
                            tableSection
                            codeSecretSection
                        }
                        inputSection
                        actionButtonsSection
                        resultSection
                        clearButton
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
                    Text("Décodeur")
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
            .sheet(isPresented: $showQRScanner) {
                QRScannerView { scannedCode in
                    handleScannedQRCode(scannedCode)
                }
            }
            .onAppear {
                checkForImportedMessage()
            }
            .onChange(of: appState.importedMessage) { _, newMessage in
                if newMessage != nil {
                    checkForImportedMessage()
                }
            }
        }
    }
    
    // Vérifie si un message a été importé depuis une autre app
    private func checkForImportedMessage() {
        if let imported = appState.importedMessage {
            print("📥 Message importé détecté: \(imported.count) caractères")
            self.texteCrypte = imported
            appState.importedMessage = nil  // Réinitialiser
        }
    }
    
    // Sélecteur de mode (manuel ou carnet)
    private var modeSelector: some View {
        GlassCard {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: biometricManager.biometricIcon)
                        .foregroundColor(Color(hex: "667eea"))
                    Text("Décodage automatique")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Toggle("", isOn: $modeCarnet)
                        .labelsHidden()
                        .tint(Color(hex: "667eea"))
                }
                
                if modeCarnet {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                        Text("\(contactsManager.count) correspondant\(contactsManager.count > 1 ? "s" : "") dans le carnet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
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
                    .fill(AppColors.primaryGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: AppColors.decode.opacity(0.4), radius: 15, x: 0, y: 8)
                
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Text("Décoder un message")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Révélez le contenu d'un message codé")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 10)
        .padding(.bottom, 5)
    }
    
    private var statusIndicators: some View {
        HStack(spacing: 10) {
            if let correspondant = correspondantDetecte {
                StatusPill(text: correspondant, icon: "person.fill", color: Color(hex: "667eea"))
            }
            if !modeCarnet && tableAleatoireActive {
                StatusPill(text: "Table: \(codeTableManuel)", icon: "shuffle", color: AppColors.random)
            }
            if !modeCarnet && !codeSecret.isEmpty {
                StatusPill(text: "Code secret", icon: "key.fill", color: AppColors.secret)
            }
            if let jour = jourDetecte {
                StatusPill(text: jour, icon: "calendar", color: AppColors.decode)
            }
            Spacer()
        }
    }
    
    private var tableSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Table aléatoire", icon: "shuffle", color: AppColors.random, subtitle: "Si l'expéditeur en a utilisé une")
                HStack(spacing: 12) {
                    ModernTextField(placeholder: "Code à 6 caractères", text: $codeTableManuel, icon: "number", accentColor: AppColors.random)
                        .onChange(of: codeTableManuel) { oldValue, newValue in
                            if newValue.count > 6 {
                                codeTableManuel = String(newValue.prefix(6)).uppercased()
                            } else {
                                codeTableManuel = newValue.uppercased()
                            }
                        }
                    if tableAleatoireActive {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
    
    private var codeSecretSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Code secret", icon: "key.fill", color: AppColors.secret, subtitle: "Si l'expéditeur en a utilisé un")
                ModernTextField(placeholder: "Entrez le code partagé...", text: $codeSecret, icon: "lock.fill", isSecure: true, accentColor: AppColors.secret)
            }
        }
    }
    
    private var inputSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    SectionHeader(title: "Message codé", icon: "doc.text.fill", color: AppColors.decode)
                    Spacer()
                    Button(action: { showQRScanner = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "qrcode.viewfinder")
                            Text("Scanner")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColors.decode)
                        .cornerRadius(8)
                    }
                }
                ModernTextEditor(placeholder: "Collez le message codé ici...", text: $texteCrypte, minHeight: 100, accentColor: AppColors.decode)
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            GradientButton(title: "Coller", icon: "doc.on.clipboard.fill", gradient: AppColors.warningGradient, action: coller, fullWidth: true)
            
            if modeCarnet {
                // Mode carnet : décodage avec Face ID
                GradientButton(
                    title: "Décoder avec \(biometricManager.biometricTypeString)",
                    icon: biometricManager.biometricIcon,
                    gradient: LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")], startPoint: .leading, endPoint: .trailing),
                    action: decoderAvecCarnet,
                    fullWidth: true
                )
            } else {
                // Mode manuel classique
                GradientButton(title: "Décoder", icon: "lock.open.fill", gradient: AppColors.primaryGradient, action: decoderIntelligent, fullWidth: true)
                Button(action: decoderLettresCollees) {
                    HStack {
                        Image(systemName: "textformat.abc")
                        Text("Décoder sans espaces")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(AppColors.random)
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    private var resultSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    SectionHeader(title: "Message décodé", icon: "text.bubble.fill", color: Color(hex: "4ade80"), subtitle: "Éditable")
                    Spacer()
                    AnimatedCopyButton(action: { UIPasteboard.general.string = messageDecode }, color: Color(hex: "4ade80"))
                }
                ZStack(alignment: .topLeading) {
                    if messageDecode.isEmpty {
                        Text("Le message décodé apparaîtra ici...")
                            .foregroundColor(Color(hex: "4ade80").opacity(0.5))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                    }
                    TextEditor(text: $messageDecode)
                        .scrollContentBackground(.hidden)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(Color(hex: "4ade80"))
                        .padding(12)
                }
                .frame(minHeight: 120)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.85)))
            }
        }
    }
    
    private var clearButton: some View {
        GradientButton(title: "Effacer tout", icon: "trash.fill", gradient: AppColors.dangerGradient, action: effacer, fullWidth: true)
            .opacity(texteCrypte.isEmpty && messageDecode.isEmpty ? 0.5 : 1)
            .disabled(texteCrypte.isEmpty && messageDecode.isEmpty)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func coller() {
        if let texte = UIPasteboard.general.string {
            texteCrypte = texte
        }
    }
    
    // MARK: - Décodage avec carnet (Face ID)
    
    private func decoderAvecCarnet() {
        guard !texteCrypte.isEmpty else { return }
        
        // Vérifier si l'utilisateur peut encore utiliser
        guard usageManager.canUse else {
            withAnimation {
                showLimiteAtteinte = true
            }
            return
        }
        
        // Authentification biométrique
        biometricManager.authenticate(reason: "Décoder avec votre carnet de codes") { success, _ in
            guard success else { return }
            
            // Enregistrer l'utilisation
            usageManager.recordUsage()
            
            // Tester tous les correspondants
            if let resultat = contactsManager.decoderAvecCarnet(texte: texteCrypte, codeur: codeur) {
                withAnimation {
                    messageDecode = resultat.messageDecod
                    correspondantDetecte = resultat.correspondant.nom
                    jourDetecte = resultat.jourDetecte
                }
            } else {
                // Aucun correspondant n'a fonctionné
                messageDecode = "⚠️ Aucun correspondant du carnet ne correspond à ce message. Essayez le mode manuel."
                correspondantDetecte = nil
                jourDetecte = nil
            }
        }
    }
    
    // MARK: - Décodage manuel
    
    private func decoderIntelligent() {
        // Vérifier si l'utilisateur peut encore utiliser
        guard usageManager.canUse else {
            withAnimation {
                showLimiteAtteinte = true
            }
            return
        }
        
        // Enregistrer l'utilisation
        usageManager.recordUsage()
        
        let resultat = codeur.decoderIntelligent(texte: texteCrypte, modeJour: true, codeSecret: codeSecret, codeTable: codeTableManuel)
        messageDecode = resultat.texte
        correspondantDetecte = nil
        
        if let info = codeur.extraireJourDuCode(texteCrypte.replacingOccurrences(of: " ", with: "")) {
            jourDetecte = codeur.nomsJours[info.jour]
        } else if let info = codeur.extraireJourDuCode(String(texteCrypte.replacingOccurrences(of: " ", with: "").reversed())) {
            jourDetecte = codeur.nomsJours[info.jour]
        } else {
            jourDetecte = nil
        }
    }
    
    private func decoderLettresCollees() {
        // Vérifier si l'utilisateur peut encore utiliser
        guard usageManager.canUse else {
            withAnimation {
                showLimiteAtteinte = true
            }
            return
        }
        
        // Enregistrer l'utilisation
        usageManager.recordUsage()
        
        let code = texteCrypte.replacingOccurrences(of: " ", with: "")
        let codeInverse = String(code.reversed())
        let decalageSecret = codeur.calculerDecalageSecret(codeSecret)
        
        if let info = codeur.extraireJourDuCode(code) {
            let codeSansMarqueur = codeur.retirerMarqueurJour(code, position: info.position)
            let decalage = codeur.getDecalageJour(jour: info.jour) + decalageSecret
            messageDecode = codeur.decoder(texte: codeSansMarqueur, decalage: decalage, codeTable: codeTableManuel)
            jourDetecte = codeur.nomsJours[info.jour]
            correspondantDetecte = nil
            return
        }
        
        if let info = codeur.extraireJourDuCode(codeInverse) {
            let codeSansMarqueur = codeur.retirerMarqueurJour(codeInverse, position: info.position)
            let decalage = codeur.getDecalageJour(jour: info.jour) + decalageSecret
            messageDecode = codeur.decoder(texte: codeSansMarqueur, decalage: decalage, codeTable: codeTableManuel)
            jourDetecte = codeur.nomsJours[info.jour]
            correspondantDetecte = nil
            return
        }
        
        // Pas de marqueur trouvé : tester tous les jours et les deux sens (normal et inversé)
        var meilleurResultat = ""
        var meilleurScore = -1
        var meilleurJour: Int? = nil
        
        for jour in 0..<7 {
            let decalage = codeur.getDecalageJour(jour: jour) + decalageSecret
            
            // Tester le code normal
            let decode1 = codeur.decoder(texte: code, decalage: decalage, codeTable: codeTableManuel)
            let score1 = codeur.compterMotsReconnus(decode1)
            if score1 > meilleurScore {
                meilleurScore = score1
                meilleurResultat = decode1
                meilleurJour = jour
            }
            
            // Tester le code inversé
            let decode2 = codeur.decoder(texte: codeInverse, decalage: decalage, codeTable: codeTableManuel)
            let score2 = codeur.compterMotsReconnus(decode2)
            if score2 > meilleurScore {
                meilleurScore = score2
                meilleurResultat = decode2
                meilleurJour = jour
            }
        }
        
        messageDecode = meilleurResultat
        correspondantDetecte = nil
        jourDetecte = meilleurJour != nil ? codeur.nomsJours[meilleurJour!] : nil
    }
    
    private func effacer() {
        withAnimation {
            texteCrypte = ""
            messageDecode = ""
            codeSecret = ""
            codeTableManuel = ""
            correspondantDetecte = nil
            jourDetecte = nil
        }
    }
    
    private func handleScannedQRCode(_ code: String) {
        print("📱 QR Code scanné: \(code)")
        
        // Stocker le texte scanné avant de fermer la sheet
        var scannedText = ""
        
        // Vérifier si c'est un lien CourrierCode
        if code.hasPrefix("courriercode://decode?message=") {
            let messageEncoded = code.replacingOccurrences(of: "courriercode://decode?message=", with: "")
            if let message = messageEncoded.removingPercentEncoding {
                scannedText = message
            } else {
                scannedText = messageEncoded
            }
        } else if code.hasPrefix("courriercode://") {
            // Autre format courriercode
            if let url = URL(string: code),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let messageParam = components.queryItems?.first(where: { $0.name == "message" })?.value {
                scannedText = messageParam.removingPercentEncoding ?? messageParam
            } else {
                scannedText = code
            }
        } else {
            // C'est directement un message codé (pas un lien)
            scannedText = code
        }
        
        // Fermer d'abord la sheet, puis mettre à jour le texte après un court délai
        showQRScanner = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.texteCrypte = scannedText
            print("📝 Texte intégré: \(scannedText)")
        }
    }
}

// MARK: - QR Scanner View

struct QRScannerView: View {
    let onCodeScanned: (String) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var isFlashOn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                QRScannerRepresentable(onCodeScanned: { code in
                    onCodeScanned(code)
                }, isFlashOn: $isFlashOn)
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Zone de scan
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 250, height: 250)
                        .background(Color.clear)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("Scannez un QR code CourrierCode")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Pointez la caméra vers le QR code généré par un autre utilisateur")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: { isFlashOn.toggle() }) {
                            HStack {
                                Image(systemName: isFlashOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                Text(isFlashOn ? "Flash activé" : "Activer le flash")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - QR Scanner UIKit Wrapper

struct QRScannerRepresentable: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void
    @Binding var isFlashOn: Bool
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.onCodeScanned = onCodeScanned
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        uiViewController.setFlash(isFlashOn)
    }
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var onCodeScanned: ((String) -> Void)?
    private var hasScanned = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hasScanned = false
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession?.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showNoCameraAlert()
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showNoCameraAlert()
            return
        }
        
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        } else {
            showNoCameraAlert()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession?.canAddOutput(metadataOutput) == true {
            captureSession?.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            showNoCameraAlert()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !hasScanned else { return }
        
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            hasScanned = true
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            onCodeScanned?(stringValue)
        }
    }
    
    func setFlash(_ on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Erreur flash: \(error)")
        }
    }
    
    private func showNoCameraAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Caméra non disponible",
                message: "Cette fonctionnalité nécessite une caméra",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

#Preview {
    DecodeurView()
        .environmentObject(AppState.shared)
}
