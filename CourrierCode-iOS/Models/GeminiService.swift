//
//  GeminiService.swift
//  decoupemots
//
//  Service pour appeler l'API Gemini de Google (gratuit)
//

import Foundation

// MARK: - Modèles de données pour l'API Gemini

struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GenerationConfig?
    
    init(prompt: String) {
        self.contents = [GeminiContent(parts: [GeminiPart(text: prompt)])]
        self.generationConfig = GenerationConfig(
            temperature: 0.1,
            maxOutputTokens: 1024
        )
    }
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GenerationConfig: Codable {
    let temperature: Double
    let maxOutputTokens: Int
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]?
    let error: GeminiError?
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
}

struct GeminiError: Codable {
    let message: String
    let code: Int?
}

// MARK: - Service Gemini

class GeminiService {
    static let shared = GeminiService()
    
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    
    private init() {}
    
    /// Découpe une suite de lettres en mots français en utilisant Gemini
    func splitWordsWithAI(input: String, apiKey: String) async throws -> [String] {
        guard !apiKey.isEmpty else {
            throw GeminiServiceError.noAPIKey
        }
        
        let prompt = """
        Tu es un expert en langue française. Voici un texte à analyser : "\(input)"
        
        Ce texte peut contenir :
        - Des lettres collées sans espaces (exemple: "bonjourjesuisla")
        - Des mots mélangés dans le désordre (exemple: "chat le mange souris la")
        - Ou les DEUX : des lettres collées ET des mots dans le désordre (exemple: "lechat mange lasouris" ou "sourisla chatmange le")
        
        Ta mission :
        1. D'abord, découpe les lettres collées en mots français
        2. Ensuite, réordonne tous les mots pour former des phrases cohérentes et naturelles
        
        Règles :
        - Utilise TOUS les caractères, dans l'ordre pour le découpage
        - Propose les 5 phrases les plus probables et naturelles
        - Chaque phrase doit être sur une ligne séparée
        - Les mots doivent être séparés par des espaces
        - Ne mets pas de numérotation ni de ponctuation
        - Privilégie les phrases qui ont du sens grammaticalement
        
        Exemples :
        - "bonjourjesuisla" → "bonjour je suis là"
        - "chat le mange souris la" → "le chat mange la souris"
        - "lechat mange lasouris" → "le chat mange la souris"
        
        Réponds uniquement avec les phrases reconstruites, rien d'autre.
        """
        
        let url = URL(string: "\(baseURL)?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let geminiRequest = GeminiRequest(prompt: prompt)
        request.httpBody = try JSONEncoder().encode(geminiRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiServiceError.invalidResponse
        }
        
        if httpResponse.statusCode == 400 {
            throw GeminiServiceError.invalidAPIKey
        }
        
        if httpResponse.statusCode == 404 {
            throw GeminiServiceError.modelNotFound
        }
        
        if httpResponse.statusCode == 429 {
            throw GeminiServiceError.rateLimitExceeded
        }
        
        if httpResponse.statusCode != 200 {
            throw GeminiServiceError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        if let error = geminiResponse.error {
            throw GeminiServiceError.apiError(message: error.message)
        }
        
        guard let candidates = geminiResponse.candidates,
              let firstCandidate = candidates.first,
              let textPart = firstCandidate.content.parts.first else {
            throw GeminiServiceError.noResults
        }
        
        // Parser les résultats (une phrase par ligne)
        let results = textPart.text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .filter { !$0.hasPrefix("-") && !$0.hasPrefix("•") && !$0.hasPrefix("*") }
            .map { line in
                // Nettoyer les éventuels numéros en début de ligne
                var cleaned = line
                if let range = cleaned.range(of: #"^\d+[\.\)\-\s]+"#, options: .regularExpression) {
                    cleaned.removeSubrange(range)
                }
                return cleaned.trimmingCharacters(in: .whitespaces)
            }
            .filter { !$0.isEmpty }
        
        return Array(results.prefix(10))
    }
    
    /// Reconstitue une phrase cohérente à partir de mots mélangés
    func reorderWordsWithAI(words: [String], apiKey: String) async throws -> [String] {
        guard !apiKey.isEmpty else {
            throw GeminiServiceError.noAPIKey
        }
        
        let wordsString = words.joined(separator: ", ")
        
        let prompt = """
        Tu es un expert en langue française. Voici une liste de mots mélangés : \(wordsString)
        
        Reconstitue la ou les phrases les plus cohérentes et naturelles en français avec ces mots.
        
        Règles :
        - Utilise TOUS les mots donnés, exactement une fois chacun
        - Ne modifie pas les mots (garde-les tels quels)
        - Propose jusqu'à 5 reconstructions différentes si plusieurs sont possibles
        - Chaque phrase doit être sur une ligne séparée
        - Privilégie les phrases qui ont le plus de sens
        - La phrase doit être grammaticalement correcte
        
        Exemple pour "chat le mange souris la" :
        le chat mange la souris
        la souris mange le chat
        
        Réponds uniquement avec les phrases reconstituées, rien d'autre.
        """
        
        let url = URL(string: "\(baseURL)?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let geminiRequest = GeminiRequest(prompt: prompt)
        request.httpBody = try JSONEncoder().encode(geminiRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiServiceError.invalidResponse
        }
        
        if httpResponse.statusCode == 400 {
            throw GeminiServiceError.invalidAPIKey
        }
        
        if httpResponse.statusCode == 404 {
            throw GeminiServiceError.modelNotFound
        }
        
        if httpResponse.statusCode == 429 {
            throw GeminiServiceError.rateLimitExceeded
        }
        
        if httpResponse.statusCode != 200 {
            throw GeminiServiceError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        if let error = geminiResponse.error {
            throw GeminiServiceError.apiError(message: error.message)
        }
        
        guard let candidates = geminiResponse.candidates,
              let firstCandidate = candidates.first,
              let textPart = firstCandidate.content.parts.first else {
            throw GeminiServiceError.noResults
        }
        
        // Parser les résultats (une phrase par ligne)
        let results = textPart.text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .filter { !$0.hasPrefix("-") && !$0.hasPrefix("•") && !$0.hasPrefix("*") }
            .map { line in
                // Nettoyer les éventuels numéros en début de ligne
                var cleaned = line
                if let range = cleaned.range(of: #"^\d+[\.\)\-\s]+"#, options: .regularExpression) {
                    cleaned.removeSubrange(range)
                }
                return cleaned.trimmingCharacters(in: .whitespaces)
            }
            .filter { !$0.isEmpty }
        
        return Array(results.prefix(10))
    }
    
    /// Corrige l'orthographe et la grammaire d'un texte
    func correctSpelling(text: String, apiKey: String) async throws -> SpellCheckResult {
        guard !apiKey.isEmpty else {
            throw GeminiServiceError.noAPIKey
        }
        
        let prompt = """
        Tu es un correcteur orthographique et grammatical expert en langue française.
        
        Voici le texte à corriger :
        \"\"\"
        \(text)
        \"\"\"
        
        Analyse ce texte et corrige toutes les fautes :
        - Fautes d'orthographe
        - Fautes de grammaire
        - Fautes d'accord (genre, nombre)
        - Fautes de conjugaison
        - Mauvais usage des accents
        - Ponctuation incorrecte
        
        Réponds EXACTEMENT dans ce format JSON (et rien d'autre) :
        {
            "texte_corrige": "Le texte entièrement corrigé ici",
            "corrections": [
                {
                    "original": "mot ou expression fautive",
                    "corrige": "correction",
                    "explication": "brève explication de la règle"
                }
            ]
        }
        
        Si le texte ne contient aucune faute, retourne le texte original avec un tableau corrections vide.
        IMPORTANT : Réponds UNIQUEMENT avec le JSON, sans aucun texte avant ou après.
        """
        
        let url = URL(string: "\(baseURL)?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let geminiRequest = GeminiRequest(prompt: prompt)
        request.httpBody = try JSONEncoder().encode(geminiRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiServiceError.invalidResponse
        }
        
        if httpResponse.statusCode == 400 {
            throw GeminiServiceError.invalidAPIKey
        }
        
        if httpResponse.statusCode == 404 {
            throw GeminiServiceError.modelNotFound
        }
        
        if httpResponse.statusCode == 429 {
            throw GeminiServiceError.rateLimitExceeded
        }
        
        if httpResponse.statusCode != 200 {
            throw GeminiServiceError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        if let error = geminiResponse.error {
            throw GeminiServiceError.apiError(message: error.message)
        }
        
        guard let candidates = geminiResponse.candidates,
              let firstCandidate = candidates.first,
              let textPart = firstCandidate.content.parts.first else {
            throw GeminiServiceError.noResults
        }
        
        // Parser le JSON de réponse
        return parseSpellCheckResponse(textPart.text, originalText: text)
    }
    
    /// Parse la réponse JSON du correcteur
    private func parseSpellCheckResponse(_ response: String, originalText: String) -> SpellCheckResult {
        // Nettoyer la réponse (enlever les backticks markdown si présents)
        var cleanedResponse = response
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Enlever ```json et ``` si présents
        if cleanedResponse.hasPrefix("```json") {
            cleanedResponse = String(cleanedResponse.dropFirst(7))
        } else if cleanedResponse.hasPrefix("```") {
            cleanedResponse = String(cleanedResponse.dropFirst(3))
        }
        if cleanedResponse.hasSuffix("```") {
            cleanedResponse = String(cleanedResponse.dropLast(3))
        }
        cleanedResponse = cleanedResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Essayer de parser le JSON
        guard let jsonData = cleanedResponse.data(using: .utf8) else {
            return SpellCheckResult(correctedText: originalText, corrections: [])
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                let correctedText = json["texte_corrige"] as? String ?? originalText
                var corrections: [CorrectionItem] = []
                
                if let correctionsArray = json["corrections"] as? [[String: Any]] {
                    for item in correctionsArray {
                        if let original = item["original"] as? String,
                           let corrected = item["corrige"] as? String {
                            let explanation = item["explication"] as? String ?? ""
                            corrections.append(CorrectionItem(
                                original: original,
                                corrected: corrected,
                                explanation: explanation
                            ))
                        }
                    }
                }
                
                return SpellCheckResult(correctedText: correctedText, corrections: corrections)
            }
        } catch {
            // Si le parsing échoue, essayer d'extraire le texte corrigé directement
            print("Erreur parsing JSON: \(error)")
        }
        
        return SpellCheckResult(correctedText: originalText, corrections: [])
    }
}

// MARK: - Modèles pour le correcteur orthographique

// Modèle pour une correction
struct CorrectionItem: Identifiable {
    let id = UUID()
    let original: String
    let corrected: String
    let explanation: String
}

// Résultat de la correction
struct SpellCheckResult {
    let correctedText: String
    let corrections: [CorrectionItem]
}

// MARK: - Erreurs

enum GeminiServiceError: LocalizedError {
    case noAPIKey
    case invalidAPIKey
    case invalidResponse
    case rateLimitExceeded
    case modelNotFound
    case httpError(statusCode: Int)
    case apiError(message: String)
    case noResults
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "Aucune clé API configurée"
        case .invalidAPIKey:
            return "Clé API invalide. Vérifiez votre clé dans les réglages."
        case .invalidResponse:
            return "Réponse invalide du serveur"
        case .rateLimitExceeded:
            return "Quota dépassé. Attendez 1 minute et réessayez."
        case .modelNotFound:
            return "Modèle IA non disponible. Veuillez mettre à jour l'application."
        case .httpError(let statusCode):
            return "Erreur serveur (code \(statusCode))"
        case .apiError(let message):
            return "Erreur API : \(message)"
        case .noResults:
            return "Aucun résultat retourné par l'IA"
        }
    }
}
