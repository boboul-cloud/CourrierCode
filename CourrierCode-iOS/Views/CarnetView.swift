import SwiftUI

struct CarnetView: View {
    @ObservedObject private var contactsManager = ContactsManager.shared
    @ObservedObject private var biometricManager = BiometricManager.shared
    
    @State private var showAjouterSheet = false
    @State private var correspondantAModifier: Correspondant? = nil
    @State private var isAuthenticated = false
    @State private var showAuthError = false
    
    var body: some View {
        NavigationStack {
            Group {
                if !isAuthenticated && biometricManager.isBiometricAvailable {
                    // Écran de verrouillage
                    lockedView
                } else {
                    // Contenu du carnet
                    carnetContent
                }
            }
            .navigationTitle("Carnet de codes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isAuthenticated || !biometricManager.isBiometricAvailable {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showAjouterSheet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(hex: "667eea"))
                        }
                    }
                }
            }
            .sheet(isPresented: $showAjouterSheet) {
                EditCorrespondantView(correspondant: nil) { nouveau in
                    contactsManager.ajouter(nouveau)
                }
            }
            .sheet(item: $correspondantAModifier) { correspondant in
                EditCorrespondantView(correspondant: correspondant) { modifie in
                    contactsManager.modifier(modifie)
                }
            }
            .alert("Authentification échouée", isPresented: $showAuthError) {
                Button("Réessayer") { authenticate() }
                Button("Annuler", role: .cancel) { }
            } message: {
                Text("Impossible d'accéder au carnet de codes. Veuillez réessayer.")
            }
            .onAppear {
                if biometricManager.isBiometricAvailable && !isAuthenticated {
                    authenticate()
                } else {
                    isAuthenticated = true
                }
            }
        }
    }
    
    private var lockedView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 15, x: 0, y: 8)
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Text("Carnet verrouillé")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Utilisez \(biometricManager.biometricTypeString) pour accéder à vos correspondants")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: authenticate) {
                HStack(spacing: 10) {
                    Image(systemName: biometricManager.biometricIcon)
                    Text("Déverrouiller")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 14)
                .background(LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(14)
            }
            
            Spacer()
        }
    }
    
    private var carnetContent: some View {
        Group {
            if contactsManager.correspondants.isEmpty {
                emptyStateView
            } else {
                correspondantsList
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(hex: "667eea").opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.2.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "667eea"))
            }
            
            Text("Aucun correspondant")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Ajoutez vos correspondants et leurs codes pour décoder automatiquement avec Face ID")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showAjouterSheet = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter un correspondant")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(12)
            }
            .padding(.top, 10)
            
            Spacer()
        }
    }
    
    private var correspondantsList: some View {
        List {
            ForEach(contactsManager.correspondants) { correspondant in
                Button(action: { correspondantAModifier = correspondant }) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 44, height: 44)
                            
                            Text(String(correspondant.nom.prefix(1)).uppercased())
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(correspondant.nom)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(correspondant.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    contactsManager.supprimer(contactsManager.correspondants[index])
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func authenticate() {
        biometricManager.authenticate(reason: "Accéder à votre carnet de codes") { success, _ in
            if success {
                withAnimation {
                    isAuthenticated = true
                }
            } else {
                showAuthError = true
            }
        }
    }
}

// MARK: - Vue d'édition d'un correspondant

struct EditCorrespondantView: View {
    @Environment(\.dismiss) private var dismiss
    
    let correspondant: Correspondant?
    let onSave: (Correspondant) -> Void
    
    @State private var nom = ""
    @State private var codeSecret = ""
    @State private var codeTable = ""
    
    var isEditing: Bool { correspondant != nil }
    
    var isValid: Bool {
        !nom.trimmingCharacters(in: .whitespaces).isEmpty &&
        (!codeSecret.isEmpty || !codeTable.isEmpty)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nom du correspondant", text: $nom)
                } header: {
                    Text("Correspondant")
                } footer: {
                    Text("Ex: Maman, Papa, Ami...")
                }
                
                Section {
                    SecureField("Code secret", text: $codeSecret)
                } header: {
                    Text("Code secret")
                } footer: {
                    Text("Le mot de passe partagé avec ce correspondant")
                }
                
                Section {
                    TextField("Code table (6 caractères)", text: $codeTable)
                        .textInputAutocapitalization(.characters)
                        .onChange(of: codeTable) { _, newValue in
                            if newValue.count > 6 {
                                codeTable = String(newValue.prefix(6)).uppercased()
                            } else {
                                codeTable = newValue.uppercased()
                            }
                        }
                } header: {
                    Text("Table aléatoire")
                } footer: {
                    Text("Si ce correspondant utilise une table personnalisée")
                }
            }
            .navigationTitle(isEditing ? "Modifier" : "Nouveau correspondant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        let nouveau = Correspondant(
                            id: correspondant?.id ?? UUID(),
                            nom: nom.trimmingCharacters(in: .whitespaces),
                            codeSecret: codeSecret,
                            codeTable: codeTable
                        )
                        onSave(nouveau)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if let correspondant = correspondant {
                    nom = correspondant.nom
                    codeSecret = correspondant.codeSecret
                    codeTable = correspondant.codeTable
                }
            }
        }
    }
}

#Preview {
    CarnetView()
}
