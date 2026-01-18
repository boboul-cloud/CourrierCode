import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
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
            
            TableReferenceView()
                .tabItem {
                    Image(systemName: "tablecells.badge.ellipsis")
                    Text("Table")
                }
                .tag(2)
            
            DocumentationView()
                .tabItem {
                    Image(systemName: "book.circle.fill")
                    Text("Aide")
                }
                .tag(3)
        }
        .tint(Color(hex: "667eea"))
    }
}

#Preview {
    ContentView()
}
