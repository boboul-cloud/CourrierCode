import SwiftUI

@main
struct CourrierCodeApp: App {
    @StateObject private var appState = AppState.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onOpenURL { url in
                    print("📥 onOpenURL appelé: \(url)")
                    Self.handleIncomingURL(url: url, appState: appState)
                }
        }
    }
    
    static func handleIncomingURL(url: URL, appState: AppState) {
        print("📥 URL reçue: \(url)")
        print("📥 Scheme: \(url.scheme ?? "nil")")
        
        // Vérifier si c'est un lien courriercode://
        if url.scheme == "courriercode" {
            handleCourrierCodeURL(url: url, appState: appState)
            return
        }
        
        // Sinon c'est un fichier
        handleIncomingFile(url: url, appState: appState)
    }
    
    static func handleCourrierCodeURL(url: URL, appState: AppState) {
        print("📥 URL CourrierCode: \(url)")
        
        // Format: courriercode://decode?message=MESSAGE_ENCODE
        // ou: courriercode://encode?message=MESSAGE_CLAIR
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("❌ URL invalide")
            return
        }
        
        let host = url.host ?? components.path.replacingOccurrences(of: "/", with: "")
        print("📥 Action: \(host)")
        
        if let messageParam = components.queryItems?.first(where: { $0.name == "message" })?.value {
            let message = messageParam.removingPercentEncoding ?? messageParam
            print("📥 Message: \(message.prefix(100))...")
            
            DispatchQueue.main.async {
                if host == "decode" {
                    appState.importedMessage = message
                    appState.shouldNavigateToDecoder = true
                } else if host == "encode" {
                    appState.messageToEncode = message
                    appState.shouldNavigateToEncoder = true
                }
            }
        }
    }
    
    static func handleIncomingFile(url: URL, appState: AppState) {
        print("📥 Fichier reçu: \(url)")
        print("📥 Path: \(url.path)")
        print("📥 Extension: \(url.pathExtension)")
        
        // Accéder au fichier
        let accessing = url.startAccessingSecurityScopedResource()
        print("📥 Accès sécurisé: \(accessing)")
        defer { 
            if accessing {
                url.stopAccessingSecurityScopedResource() 
            }
        }
        
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            print("📥 Contenu lu: \(content.count) caractères")
            print("📥 Début: \(content.prefix(100))")
            
            // Vérifier si c'est un JSON (image encodée)
            if url.pathExtension.lowercased() == "json" {
                if let encoded = ImageEncoder.shared.importFromJSONString(content) {
                    print("✅ Image JSON importée: \(encoded.width)x\(encoded.height)")
                    DispatchQueue.main.async {
                        appState.importedEncodedImage = encoded
                        appState.shouldNavigateToImageDecoder = true
                    }
                } else {
                    print("❌ JSON invalide")
                }
            } else {
                // C'est un fichier texte (message codé)
                print("✅ Message texte importé: \(content.count) caractères")
                DispatchQueue.main.async {
                    appState.importedMessage = content
                    appState.shouldNavigateToDecoder = true
                }
            }
        } catch {
            print("❌ Erreur lecture: \(error)")
        }
    }
}

// MARK: - App Delegate pour gérer l'ouverture de fichiers

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("🚀 App démarrée")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("📥 AppDelegate open URL: \(url)")
        CourrierCodeApp.handleIncomingURL(url: url, appState: AppState.shared)
        return true
    }
}

// MARK: - App State pour partager les données entre vues

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var importedEncodedImage: EncodedImage?
    @Published var shouldNavigateToImageDecoder = false
    @Published var importedMessage: String?
    @Published var shouldNavigateToDecoder = false
    @Published var messageToEncode: String?
    @Published var shouldNavigateToEncoder = false
    
    private init() {}
}
