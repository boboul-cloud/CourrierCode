//
//  DecoupeMotsView.swift
//  CourrierCode
//
//  Outil de découpage de mots et correcteur d'orthographe avec IA
//

import SwiftUI

struct DecoupeMotsView: View {
    @StateObject private var viewModel = DecoupeMotsViewModel()
    @State private var showSpellChecker = false
    @State private var showSettings = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // En-tête
                headerView
                
                // Configuration API
                if viewModel.geminiAPIKey.isEmpty {
                    apiKeyWarningView
                } else {
                    mainContent
                }
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Découpe Mots")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showSpellChecker) {
            SpellCheckerViewIntegrated(apiKey: viewModel.geminiAPIKey)
        }
        .sheet(isPresented: $showSettings) {
            DecoupeMotsSettingsView(viewModel: viewModel)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 12) {
            // Bouton paramètres en haut à droite
            HStack {
                Spacer()
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(10)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            .padding(.trailing, 4)
            
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.purple, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 70, height: 70)
                    .shadow(color: Color.purple.opacity(0.4), radius: 10, x: 0, y: 5)
                
                Image(systemName: "textformat.abc.dottedunderline")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Text("Découpe & Correction")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Recomposez des phrases et corrigez l'orthographe avec l'IA")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - API Key Warning
    private var apiKeyWarningView: some View {
        VStack(spacing: 16) {
            Image(systemName: "key.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Clé API requise")
                .font(.headline)
            
            Text("Pour utiliser cette fonctionnalité, vous devez configurer une clé API Gemini (gratuite).")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showSettings = true }) {
                HStack {
                    Image(systemName: "gearshape.fill")
                    Text("Configurer")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 16) {
            // Champ de saisie
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Texte à analyser")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        TextField("Ex: bonjourcommentcava", text: $viewModel.inputText)
                            .textFieldStyle(.plain)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        if !viewModel.inputText.isEmpty {
                            Button(action: { viewModel.inputText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(action: {
                            if let text = UIPasteboard.general.string {
                                viewModel.inputText = text
                            }
                        }) {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            
            // Boutons d'action
            HStack(spacing: 12) {
                // Découper
                Button(action: { viewModel.splitWords() }) {
                    HStack {
                        if viewModel.isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "scissors")
                        }
                        Text("Découper")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.inputText.isEmpty ? Color.gray : Color.purple)
                    .cornerRadius(12)
                }
                .disabled(viewModel.inputText.isEmpty || viewModel.isProcessing)
                
                // Correcteur
                Button(action: { showSpellChecker = true }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Correcteur")
                    }
                    .font(.headline)
                    .foregroundColor(.purple)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.15))
                    .cornerRadius(12)
                }
            }
            
            // Message d'erreur
            if let error = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
            }
            
            // Résultats
            if !viewModel.results.isEmpty {
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Phrases possibles")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        ForEach(viewModel.results, id: \.self) { phrase in
                            HStack {
                                Text(phrase)
                                    .font(.body)
                                
                                Spacer()
                                
                                Button(action: {
                                    UIPasteboard.general.string = phrase
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - ViewModel

class DecoupeMotsViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var results: [String] = []
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    @AppStorage("geminiAPIKey") var geminiAPIKey = ""
    
    func splitWords() {
        guard !inputText.isEmpty else { return }
        guard !geminiAPIKey.isEmpty else {
            errorMessage = "Clé API non configurée"
            return
        }
        
        isProcessing = true
        errorMessage = nil
        results = []
        
        Task {
            do {
                let cleanedInput = inputText
                    .lowercased()
                    .trimmingCharacters(in: .whitespaces)
                
                let aiResults = try await GeminiService.shared.splitWordsWithAI(
                    input: cleanedInput,
                    apiKey: geminiAPIKey
                )
                
                await MainActor.run {
                    self.results = aiResults
                    self.isProcessing = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isProcessing = false
                }
            }
        }
    }
}

// MARK: - Settings View

struct DecoupeMotsSettingsView: View {
    @ObservedObject var viewModel: DecoupeMotsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var tempAPIKey = ""
    @State private var showAPIKey = false
    @State private var showDeleteConfirmation = false
    
    private var hasExistingKey: Bool {
        !viewModel.geminiAPIKey.isEmpty
    }
    
    private var maskedKey: String {
        guard tempAPIKey.count > 8 else { return tempAPIKey }
        let prefix = String(tempAPIKey.prefix(4))
        let suffix = String(tempAPIKey.suffix(4))
        return "\(prefix)••••••••\(suffix)"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Clé API Gemini")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        // Affichage du statut actuel
                        if hasExistingKey && tempAPIKey == viewModel.geminiAPIKey {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Clé configurée")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        // Champ de saisie avec toggle visibilité
                        HStack {
                            if showAPIKey {
                                TextField("Entrez votre clé API", text: $tempAPIKey)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField("Entrez votre clé API", text: $tempAPIKey)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            Button(action: { showAPIKey.toggle() }) {
                                Image(systemName: showAPIKey ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.borderless)
                        }
                        
                        // Aperçu de la clé masquée si elle existe
                        if !tempAPIKey.isEmpty && !showAPIKey {
                            Text("Aperçu : \(maskedKey)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Bouton supprimer la clé
                    if hasExistingKey {
                        Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Supprimer la clé API")
                            }
                        }
                    }
                } header: {
                    Text("Configuration IA")
                } footer: {
                    Text("Obtenez une clé gratuite sur aistudio.google.com. Vous pouvez modifier ou supprimer la clé à tout moment.")
                }
                
                Section {
                    Link(destination: URL(string: "https://aistudio.google.com/apikey")!) {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.purple)
                            Text("Obtenir une clé API")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        viewModel.geminiAPIKey = tempAPIKey
                        dismiss()
                    }
                }
            }
            .onAppear {
                tempAPIKey = viewModel.geminiAPIKey
            }
            .alert("Supprimer la clé API ?", isPresented: $showDeleteConfirmation) {
                Button("Annuler", role: .cancel) { }
                Button("Supprimer", role: .destructive) {
                    tempAPIKey = ""
                    viewModel.geminiAPIKey = ""
                }
            } message: {
                Text("Cette action supprimera votre clé API. Vous devrez en configurer une nouvelle pour utiliser les fonctionnalités IA.")
            }
        }
    }
}

// MARK: - Spell Checker Integrated

struct SpellCheckerViewIntegrated: View {
    let apiKey: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var inputText: String = ""
    @State private var correctedText: String = ""
    @State private var corrections: [CorrectionItem] = []
    @State private var isProcessing: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showCopiedAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // En-tête
                    HStack {
                        Image(systemName: "textformat.abc")
                            .font(.title)
                            .foregroundColor(.purple)
                        VStack(alignment: .leading) {
                            Text("Correcteur d'orthographe")
                                .font(.headline)
                            Text("L'IA corrige vos fautes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Zone de saisie
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Texte à corriger :")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $inputText)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        HStack {
                            Button(action: {
                                if let text = UIPasteboard.general.string {
                                    inputText = text
                                }
                            }) {
                                Label("Coller", systemImage: "doc.on.clipboard")
                                    .font(.caption)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                inputText = ""
                                correctedText = ""
                                corrections = []
                            }) {
                                Label("Effacer", systemImage: "trash")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .disabled(inputText.isEmpty)
                            
                            Text("\(inputText.count) caractères")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Bouton Corriger
                    Button(action: correctSpelling) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "wand.and.stars")
                            }
                            Text(isProcessing ? "Correction..." : "Corriger avec l'IA")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canCorrect ? Color.purple : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!canCorrect)
                    .padding(.horizontal)
                    
                    // Message d'erreur
                    if let error = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Résultats
                    if !correctedText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Texte corrigé :")
                                        .font(.headline)
                                    Spacer()
                                    
                                    Button(action: {
                                        UIPasteboard.general.string = correctedText
                                        showCopiedAlert = true
                                    }) {
                                        Label("Copier", systemImage: "doc.on.doc")
                                            .font(.caption)
                                    }
                                }
                                
                                Text(correctedText)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            
                            if !corrections.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "pencil.circle.fill")
                                            .foregroundColor(.orange)
                                        Text("Corrections (\(corrections.count)) :")
                                            .font(.headline)
                                    }
                                    
                                    ForEach(corrections) { correction in
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 8) {
                                                Text(correction.original)
                                                    .strikethrough()
                                                    .foregroundColor(.red)
                                                
                                                Image(systemName: "arrow.right")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                
                                                Text(correction.corrected)
                                                    .foregroundColor(.green)
                                                    .fontWeight(.medium)
                                            }
                                            
                                            if !correction.explanation.isEmpty {
                                                Text(correction.explanation)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .italic()
                                            }
                                        }
                                        .padding(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.orange.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            } else {
                                HStack {
                                    Image(systemName: "hand.thumbsup.fill")
                                        .foregroundColor(.green)
                                    Text("Aucune faute détectée !")
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.top)
            }
            .navigationTitle("Correcteur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .alert("Copié !", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    private var canCorrect: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isProcessing &&
        !apiKey.isEmpty
    }
    
    private func correctSpelling() {
        guard canCorrect else { return }
        
        isProcessing = true
        errorMessage = nil
        correctedText = ""
        corrections = []
        
        Task {
            do {
                let result = try await GeminiService.shared.correctSpelling(
                    text: inputText,
                    apiKey: apiKey
                )
                
                await MainActor.run {
                    self.correctedText = result.correctedText
                    self.corrections = result.corrections
                    self.isProcessing = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isProcessing = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DecoupeMotsView()
    }
}
