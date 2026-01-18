import SwiftUI

struct DecodeurView: View {
    @State private var texteCrypte = ""
    @State private var codeSecret = ""
    @State private var codeTableManuel = ""
    @State private var messageDecode = ""
    @State private var showCopiedAlert = false
    @State private var jourDetecte: String? = nil
    @State private var showPremiumView = false
    @State private var showLimiteAtteinte = false
    
    @ObservedObject private var usageManager = UsageManager.shared
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
                        statusIndicators
                        tableSection
                        codeSecretSection
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
            if tableAleatoireActive {
                StatusPill(text: "Table: \(codeTableManuel)", icon: "shuffle", color: AppColors.random)
            }
            if !codeSecret.isEmpty {
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
                SectionHeader(title: "Message codé", icon: "doc.text.fill", color: AppColors.decode)
                ModernTextEditor(placeholder: "Collez le message codé ici...", text: $texteCrypte, minHeight: 100, accentColor: AppColors.decode)
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            GradientButton(title: "Coller", icon: "doc.on.clipboard.fill", gradient: AppColors.warningGradient, action: coller, fullWidth: true)
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
            return
        }
        
        if let info = codeur.extraireJourDuCode(codeInverse) {
            let codeSansMarqueur = codeur.retirerMarqueurJour(codeInverse, position: info.position)
            let decalage = codeur.getDecalageJour(jour: info.jour) + decalageSecret
            messageDecode = codeur.decoder(texte: codeSansMarqueur, decalage: decalage, codeTable: codeTableManuel)
            jourDetecte = codeur.nomsJours[info.jour]
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
        jourDetecte = meilleurJour != nil ? codeur.nomsJours[meilleurJour!] : nil
    }
    
    private func effacer() {
        withAnimation {
            texteCrypte = ""
            messageDecode = ""
            jourDetecte = nil
        }
    }
}

#Preview {
    DecodeurView()
}
