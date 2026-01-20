import SwiftUI

struct TableReferenceView: View {
    @State private var codeEntre = ""
    @State private var estDeverrouille = false
    @State private var erreur = ""
    @State private var codeTableAleatoire = ""
    @State private var showCodeCopied = false
    @State private var tableAleatoireActive = false
    @State private var showUnlockAnimation = false
    @State private var showChangerCode = false
    @State private var ancienCode = ""
    @State private var nouveauCode = ""
    @State private var confirmationCode = ""
    @State private var erreurChangement = ""
    @State private var showCodeChanged = false
    
    @AppStorage("codeSecret") private var codeSecret = "1234"
    @AppStorage("codeTableSauvegarde") private var codeTableSauvegarde = ""
    
    let colonnes = [
        GridItem(.adaptive(minimum: 55))
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if estDeverrouille {
                    unlockedView
                } else {
                    lockedView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Table de référence")
                        .font(.headline)
                }
            }
            .alert("Code copié !", isPresented: $showCodeCopied) {
                Button("OK", role: .cancel) {}
            }
            .alert("Code modifié !", isPresented: $showCodeChanged) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Votre nouveau code a été enregistré.")
            }
            .sheet(isPresented: $showChangerCode) {
                changerCodeSheet
            }
            .onAppear {
                if !codeTableSauvegarde.isEmpty {
                    codeTableAleatoire = codeTableSauvegarde
                    TableAleatoire.shared.genererTable(avecCode: codeTableSauvegarde)
                    tableAleatoireActive = true
                }
            }
        }
    }
    
    // MARK: - Locked View
    private var lockedView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppColors.primaryGradient)
                    .frame(width: 120, height: 120)
                    .shadow(color: AppColors.decode.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: showUnlockAnimation ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(showUnlockAnimation ? 1.2 : 1.0)
            }
            
            VStack(spacing: 8) {
                Text("Table verrouillée")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Entrez le code pour accéder à la table de correspondance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Text("Code par défaut : 1234")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.8))
                    .padding(.top, 4)
            }
            
            GlassCard {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "key.fill")
                            .foregroundColor(codeEntre.isEmpty ? .secondary : AppColors.secret)
                            .frame(width: 24)
                        
                        SecureField("Code secret", text: $codeEntre)
                            .textFieldStyle(.plain)
                            .keyboardType(.numberPad)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    
                    if !erreur.isEmpty {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text(erreur)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    GradientButton(
                        title: "Déverrouiller",
                        icon: "lock.open.fill",
                        gradient: AppColors.primaryGradient,
                        action: deverrouiller,
                        fullWidth: true
                    )
                }
            }
            .padding(.horizontal, 30)
            
            Button(action: { showChangerCode = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "gearshape.fill")
                        .font(.caption)
                    Text("Changer le code")
                        .font(.footnote)
                        .fontWeight(.medium)
                }
                .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Unlocked View
    private var unlockedView: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView
                
                HStack(spacing: 12) {
                    Button(action: verrouiller) {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Verrouiller")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.red.opacity(0.1))
                        )
                    }
                    
                    Button(action: { showChangerCode = true }) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                            Text("Changer le code")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color(.systemGray5))
                        )
                    }
                }
                
                randomTableSection
                tableDisplaySection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(tableAleatoireActive ? AppColors.purpleGradient : AppColors.primaryGradient)
                    .frame(width: 70, height: 70)
                    .shadow(color: (tableAleatoireActive ? AppColors.random : AppColors.decode).opacity(0.4), radius: 12, x: 0, y: 6)
                
                Image(systemName: tableAleatoireActive ? "shuffle" : "tablecells")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Text(tableAleatoireActive ? "Table aléatoire" : "Table standard")
                .font(.title3)
                .fontWeight(.bold)
            
            if tableAleatoireActive {
                StatusPill(text: codeTableAleatoire, icon: "key.fill", color: AppColors.random)
            }
        }
        .padding(.top, 10)
    }
    
    private var randomTableSection: some View {
        GlassCard {
            VStack(spacing: 16) {
                SectionHeader(
                    title: "Table aléatoire",
                    icon: "shuffle",
                    color: AppColors.random,
                    subtitle: "Mélangez l'ordre des lettres"
                )
                
                if tableAleatoireActive {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Code actif :")
                                .foregroundColor(.secondary)
                            Text(codeTableAleatoire)
                                .font(.system(.title2, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.random)
                        }
                        
                        HStack(spacing: 12) {
                            GradientButton(
                                title: "Copier",
                                icon: "doc.on.doc",
                                gradient: AppColors.purpleGradient,
                                action: copierCode
                            )
                            
                            Button(action: desactiverTableAleatoire) {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("Désactiver")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemGray5))
                                )
                            }
                        }
                        
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Partagez ce code avec vos correspondants")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.top, 4)
                    }
                } else {
                    VStack(spacing: 16) {
                        GradientButton(
                            title: "Générer nouvelle table",
                            icon: "shuffle",
                            gradient: AppColors.purpleGradient,
                            action: genererNouvelleTable,
                            fullWidth: true
                        )
                        
                        HStack {
                            Rectangle()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(height: 1)
                            Text("ou")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Rectangle()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(height: 1)
                        }
                        
                        HStack(spacing: 12) {
                            ModernTextField(
                                placeholder: "Code à 6 chiffres",
                                text: $codeTableAleatoire,
                                icon: "number",
                                accentColor: AppColors.random
                            )
                            
                            Button(action: activerTableAvecCode) {
                                Text("Activer")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(
                                        Capsule()
                                            .fill(codeTableAleatoire.count == 6 ? AppColors.random : Color.gray)
                                    )
                            }
                            .disabled(codeTableAleatoire.count != 6)
                        }
                    }
                }
            }
        }
    }
    
    private var tableDisplaySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    title: tableAleatoireActive ? "Correspondance personnalisée" : "Correspondance standard",
                    icon: "tablecells",
                    color: AppColors.decode
                )
                
                LazyVGrid(columns: colonnes, spacing: 8) {
                    ForEach(Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ"), id: \.self) { lettre in
                        let numero = tableAleatoireActive
                            ? (TableAleatoire.shared.encoderLettre(lettre) ?? 0)
                            : (Int(lettre.asciiValue!) - 64)
                        ModernTableItem(
                            numero: String(format: "%02d", numero),
                            caractere: String(lettre),
                            isNumber: false
                        )
                    }
                    
                    ForEach(0...9, id: \.self) { num in
                        ModernTableItem(
                            numero: String(27 + num),
                            caractere: String(num),
                            isNumber: true
                        )
                    }
                }
            }
        }
    }
    
    private func deverrouiller() {
        if codeEntre == codeSecret {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showUnlockAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    estDeverrouille = true
                    showUnlockAnimation = false
                }
            }
            erreur = ""
            codeEntre = ""
        } else {
            erreur = "Code incorrect"
            codeEntre = ""
        }
    }
    
    private func verrouiller() {
        withAnimation {
            estDeverrouille = false
        }
    }
    
    private func genererNouvelleTable() {
        codeTableAleatoire = TableAleatoire.shared.genererNouveauCode()
        withAnimation {
            tableAleatoireActive = true
        }
        codeTableSauvegarde = codeTableAleatoire
    }
    
    private func activerTableAvecCode() {
        guard codeTableAleatoire.count == 6 else { return }
        TableAleatoire.shared.genererTable(avecCode: codeTableAleatoire)
        withAnimation {
            tableAleatoireActive = true
        }
        codeTableSauvegarde = codeTableAleatoire
    }
    
    private func desactiverTableAleatoire() {
        TableAleatoire.shared.reinitialiserTableParDefaut()
        withAnimation {
            tableAleatoireActive = false
        }
        codeTableAleatoire = ""
        codeTableSauvegarde = ""
    }
    
    private func copierCode() {
        UIPasteboard.general.string = codeTableAleatoire
        showCodeCopied = true
    }
    
    private func changerCode() {
        erreurChangement = ""
        
        guard ancienCode == codeSecret else {
            erreurChangement = "Code actuel incorrect"
            return
        }
        
        guard !nouveauCode.isEmpty else {
            erreurChangement = "Le nouveau code ne peut pas être vide"
            return
        }
        
        guard nouveauCode == confirmationCode else {
            erreurChangement = "Les codes ne correspondent pas"
            return
        }
        
        codeSecret = nouveauCode
        ancienCode = ""
        nouveauCode = ""
        confirmationCode = ""
        showChangerCode = false
        showCodeChanged = true
    }
    
    private var changerCodeSheet: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primaryGradient)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "key.fill")
                            .font(.system(size: 35, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    Text("Changer le code secret")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    GlassCard {
                        VStack(spacing: 16) {
                            SecureInputField(
                                placeholder: "Code actuel",
                                text: $ancienCode,
                                icon: "lock.fill"
                            )
                            
                            Divider()
                            
                            SecureInputField(
                                placeholder: "Nouveau code",
                                text: $nouveauCode,
                                icon: "key.fill"
                            )
                            
                            SecureInputField(
                                placeholder: "Confirmer le nouveau code",
                                text: $confirmationCode,
                                icon: "checkmark.shield.fill"
                            )
                            
                            if !erreurChangement.isEmpty {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text(erreurChangement)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            GradientButton(
                                title: "Enregistrer",
                                icon: "checkmark.circle.fill",
                                gradient: AppColors.successGradient,
                                action: changerCode,
                                fullWidth: true
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        ancienCode = ""
                        nouveauCode = ""
                        confirmationCode = ""
                        erreurChangement = ""
                        showChangerCode = false
                    }
                }
            }
        }
    }
}

struct SecureInputField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(text.isEmpty ? .secondary : AppColors.secret)
                .frame(width: 24)
            
            SecureField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .keyboardType(.numberPad)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct ModernTableItem: View {
    let numero: String
    let caractere: String
    let isNumber: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(numero)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundColor(.white)
            
            Text(caractere)
                .font(.system(.caption2, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(width: 48, height: 48)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isNumber ? AppColors.warningGradient : AppColors.primaryGradient)
                .shadow(color: (isNumber ? AppColors.secret : AppColors.decode).opacity(0.3), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    TableReferenceView()
}
