import SwiftUI

struct EncodeurView: View {
    @State private var texteOriginal = ""
    @State private var codeSecret = ""
    @State private var showCopiedAlert = false
    @State private var showInverse = false
    @State private var showMelange = false
    @State private var texteMelange = ""
    
    @AppStorage("codeTableSauvegarde") private var codeTable = ""
    
    private let codeur = CourrierCodeur()
    
    var messageCode: String {
        codeur.encoder(texte: texteOriginal, avecDecalage: true, codeSecret: codeSecret, codeTable: codeTable)
    }
    
    var messageInverse: String {
        String(messageCode.reversed())
    }
    
    // Code mélangé = encodage de la phrase mélangée
    var messageMelange: String {
        guard !texteMelange.isEmpty else { return "" }
        return codeur.encoder(texte: texteMelange, avecDecalage: true, codeSecret: codeSecret, codeTable: codeTable)
    }
    
    var tableAleatoireActive: Bool {
        codeTable.count == 6
    }
    
    // Fonction pour mélanger les mots du texte original
    private func melangerMotsOriginaux() {
        let mots = texteOriginal.split(separator: " ").map(String.init)
        texteMelange = mots.shuffled().joined(separator: " ")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    statusIndicators
                    codeSecretSection
                    inputSection
                    melangeTexteSection
                    resultSection
                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Encodeur")
                        .font(.headline)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("OK") { hideKeyboard() }
                }
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
                        AnimatedCopyButton(action: { copyToClipboard(messageCode) }, color: AppColors.encode)
                    }
                    Text(messageCode.isEmpty ? "Le code apparaîtra ici..." : messageCode)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(messageCode.isEmpty ? .secondary : AppColors.encode)
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
                                AnimatedCopyButton(action: { copyToClipboard(messageInverse) }, color: AppColors.random)
                            }
                            Text(messageInverse)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(AppColors.random)
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
                                AnimatedCopyButton(action: { copyToClipboard(messageMelange) }, color: AppColors.secret)
                            }
                            Text(messageMelange)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(AppColors.secret)
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
        UIPasteboard.general.string = text
    }
}

#Preview {
    EncodeurView()
}
