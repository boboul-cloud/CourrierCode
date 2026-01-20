import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var appState: AppState
    
    init() {
        // Personnaliser l'apparence de la TabBar
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // Style des icônes non sélectionnées
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        // Style des icônes sélectionnées
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "667eea"))
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color(hex: "667eea"))]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            EncodeurView()
                .tabItem {
                    Image(systemName: "pencil.circle.fill")
                    Text("Encoder")
                }
                .tag(0)
            
            DecodeurView()
                .tabItem {
                    Image(systemName: "magnifyingglass.circle.fill")
                    Text("Décoder")
                }
                .tag(1)
            
            ImageEncoderView()
                .tabItem {
                    Image(systemName: "photo.circle.fill")
                    Text("Image")
                }
                .tag(2)
            
            TableReferenceView()
                .tabItem {
                    Image(systemName: "tablecells.badge.ellipsis")
                    Text("Table")
                }
                .tag(3)
            
            AutreView()
                .tabItem {
                    Image(systemName: "ellipsis.circle.fill")
                    Text("Autre")
                }
                .tag(4)
        }
        .onChange(of: appState.shouldNavigateToImageDecoder) { _, shouldNavigate in
            if shouldNavigate {
                selectedTab = 2  // Aller à l'onglet Image (maintenant en position 2)
                appState.shouldNavigateToImageDecoder = false
            }
        }
        .tint(Color(hex: "667eea"))
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState.shared)
}
