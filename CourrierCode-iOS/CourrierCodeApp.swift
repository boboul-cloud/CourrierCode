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
                    Self.handleIncomingFile(url: url, appState: appState)
                }
        }
    }
    
    static func handleIncomingFile(url: URL, appState: AppState) {
        print("📥 Fichier reçu: \(url)")
        print("📥 Scheme: \(url.scheme ?? "nil")")
        print("📥 Path: \(url.path)")
        
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
            
            if let encoded = ImageEncoder.shared.importFromJSONString(content) {
                print("✅ Image JSON importée: \(encoded.width)x\(encoded.height)")
                DispatchQueue.main.async {
                    appState.importedEncodedImage = encoded
                    appState.shouldNavigateToImageDecoder = true
                }
            } else {
                print("❌ JSON invalide")
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
        CourrierCodeApp.handleIncomingFile(url: url, appState: AppState.shared)
        return true
    }
}

// MARK: - App State pour partager les données entre vues

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var importedEncodedImage: EncodedImage?
    @Published var shouldNavigateToImageDecoder = false
    
    private init() {}
}
