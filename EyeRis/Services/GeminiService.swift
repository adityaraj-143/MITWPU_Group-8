//
//  GeminiService.swift
//  EyeRis
//
//  Created by SDC-USER on 18/03/26.
//

import Foundation

// MARK: - Gemini API Models

/// Request body for Gemini API
struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GenerationConfig?
    let safetySettings: [SafetySetting]?
    
    init(
        contents: [GeminiContent],
        generationConfig: GenerationConfig? = nil,
        safetySettings: [SafetySetting]? = nil
    ) {
        self.contents = contents
        self.generationConfig = generationConfig
        self.safetySettings = safetySettings
    }
}

struct GeminiContent: Codable {
    let role: String
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GenerationConfig: Codable {
    let temperature: Double?
    let topK: Int?
    let topP: Double?
    let maxOutputTokens: Int?
    let stopSequences: [String]?
    
    init(
        temperature: Double? = 0.7,
        topK: Int? = 40,
        topP: Double? = 0.95,
        maxOutputTokens: Int? = 1024,
        stopSequences: [String]? = nil
    ) {
        self.temperature = temperature
        self.topK = topK
        self.topP = topP
        self.maxOutputTokens = maxOutputTokens
        self.stopSequences = stopSequences
    }
}

struct SafetySetting: Codable {
    let category: String
    let threshold: String
}

/// Response from Gemini API
struct GeminiResponse: Codable {
    let candidates: [Candidate]?
    let promptFeedback: PromptFeedback?
    let error: GeminiError?
}

struct Candidate: Codable {
    let content: GeminiContent?
    let finishReason: String?
    let index: Int?
    let safetyRatings: [SafetyRating]?
}

struct PromptFeedback: Codable {
    let safetyRatings: [SafetyRating]?
    let blockReason: String?
}

struct SafetyRating: Codable {
    let category: String
    let probability: String
}

struct GeminiError: Codable {
    let code: Int?
    let message: String?
    let status: String?
}

// MARK: - Service Errors

enum GeminiServiceError: LocalizedError {
    case invalidURL
    case invalidRequest
    case networkError(Error)
    case invalidResponse
    case apiError(String)
    case noContent
    case rateLimited
    case serverError(Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL configuration."
        case .invalidRequest:
            return "Failed to create API request."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server."
        case .apiError(let message):
            return "API Error: \(message)"
        case .noContent:
            return "No response content received."
        case .rateLimited:
            return "Rate limit exceeded. Please try again later."
        case .serverError(let code):
            return "Server error (HTTP \(code)). Please try again."
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        }
    }
}

// MARK: - Chat Message for Conversation History

struct ChatMessage {
    let role: ChatRole
    let content: String
    let timestamp: Date
    
    enum ChatRole: String {
        case user
        case model
        
        var geminiRole: String {
            return self.rawValue
        }
    }
}

// MARK: - Gemini Service

/// Singleton service for interacting with Google's Gemini API
final class GeminiService {
    
    // MARK: - Singleton
    
    static let shared = GeminiService()
    
    private init() {}
    
    // MARK: - Configuration
    
    /// API key for Gemini - loaded from APIKeys.swift
    private var apiKey: String = APIKeys.geminiAPIKey
    
    /// Base URL for Gemini API
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    
    /// Model to use - gemini-1.5-flash is free tier
    private let modelName = "gemini-2.5-flash"
    
    /// System prompt for eye health assistant context
    private let systemPrompt = """
    You are EyeRis, a knowledgeable and slightly formal eye health assistant. Your role is to:

    Provide clear, helpful information about eye health, vision care, and eye exercises
    Answer questions about common eye conditions, symptoms, and when to seek professional help
    Offer practical remedies, tips, and preventive measures whenever a user mentions any eye-related problem
    Suggest ways to reduce eye strain, especially from screen use
    Explain the 20-20-20 rule and other best practices for eye care
    Maintain a polite, calm, and professional tone while remaining approachable

    Important guidelines:

    Whenever a user mentions any eye problem or discomfort, always provide helpful remedies or tips AND recommend consulting an eye care professional
    Encourage healthy habits and preventive care
    Use simple, easy-to-understand language
    Avoid making definitive medical diagnoses
    Be concise and on point, without unnecessary detail
    Keep responses under 30 words unless more detail is specifically requested

    Your goal is to be helpful, informative, and supportive while guiding users toward proper eye care.
    """
    
    /// Default generation configuration
    private let defaultConfig = GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024
    )
    
    /// Default safety settings
    private let defaultSafetySettings: [SafetySetting] = [
        SafetySetting(category: "HARM_CATEGORY_HARASSMENT", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
        SafetySetting(category: "HARM_CATEGORY_HATE_SPEECH", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
        SafetySetting(category: "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
        SafetySetting(category: "HARM_CATEGORY_DANGEROUS_CONTENT", threshold: "BLOCK_MEDIUM_AND_ABOVE")
    ]
    
    // MARK: - Conversation History
    
    /// Maintains conversation history for context
    private var conversationHistory: [ChatMessage] = []
    
    /// Maximum number of messages to keep in history
    private let maxHistoryCount = 20
    
    // MARK: - Public Methods
    
    /// Updates the API key
    /// - Parameter key: The new API key
    func setAPIKey(_ key: String) {
        apiKey = key
    }
    
    /// Clears the conversation history
    func clearConversationHistory() {
        conversationHistory.removeAll()
    }
    
    /// Sends a message and gets a response from Gemini
    /// - Parameters:
    ///   - message: The user's message
    ///   - includeHistory: Whether to include conversation history for context
    ///   - completion: Completion handler with Result containing response or error
    func sendMessage(
        _ message: String,
        includeHistory: Bool = true,
        completion: @escaping (Result<String, GeminiServiceError>) -> Void
    ) {
        // Add user message to history
        let userMessage = ChatMessage(role: .user, content: message, timestamp: Date())
        addToHistory(userMessage)
        
        // Build contents array
        var contents: [GeminiContent] = []
        
        // Add system prompt as first user message (Gemini doesn't have a dedicated system role)
        contents.append(GeminiContent(
            role: "user",
            parts: [GeminiPart(text: systemPrompt)]
        ))
        contents.append(GeminiContent(
            role: "model",
            parts: [GeminiPart(text: "I understand. I'm EyeRis, your friendly eye health assistant. How can I help you with your eye health today?")]
        ))
        
        // Add conversation history if enabled
        if includeHistory {
            for chatMessage in conversationHistory {
                contents.append(GeminiContent(
                    role: chatMessage.role.geminiRole,
                    parts: [GeminiPart(text: chatMessage.content)]
                ))
            }
        } else {
            // Just add the current message
            contents.append(GeminiContent(
                role: "user",
                parts: [GeminiPart(text: message)]
            ))
        }
        
        // Create request
        let request = GeminiRequest(
            contents: contents,
            generationConfig: defaultConfig,
            safetySettings: defaultSafetySettings
        )
        
        // Make API call
        makeAPIRequest(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                // Add bot response to history
                let botMessage = ChatMessage(role: .model, content: response, timestamp: Date())
                self?.addToHistory(botMessage)
                completion(.success(response))
                
            case .failure(let error):
                // Remove the user message from history since we failed
                self?.conversationHistory.removeLast()
                completion(.failure(error))
            }
        }
    }
    
    /// Sends a simple one-off message without conversation history
    /// - Parameters:
    ///   - message: The message to send
    ///   - completion: Completion handler with Result
    func sendSimpleMessage(
        _ message: String,
        completion: @escaping (Result<String, GeminiServiceError>) -> Void
    ) {
        let contents = [
            GeminiContent(
                role: "user",
                parts: [GeminiPart(text: "\(systemPrompt)\n\nUser question: \(message)")]
            )
        ]
        
        let request = GeminiRequest(
            contents: contents,
            generationConfig: defaultConfig,
            safetySettings: defaultSafetySettings
        )
        
        makeAPIRequest(request: request, completion: completion)
    }
    
    // MARK: - Private Methods
    
    /// Adds a message to conversation history, maintaining max count
    private func addToHistory(_ message: ChatMessage) {
        conversationHistory.append(message)
        
        // Trim history if needed
        if conversationHistory.count > maxHistoryCount {
            conversationHistory.removeFirst(conversationHistory.count - maxHistoryCount)
        }
    }
    
    /// Makes the actual API request
    private func makeAPIRequest(
        request: GeminiRequest,
        completion: @escaping (Result<String, GeminiServiceError>) -> Void
    ) {
        // Build URL
        let urlString = "\(baseURL)/\(modelName):generateContent?key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(.failure(.invalidURL))
            }
            return
        }
        
        // Create URL request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 30
        
        // Encode request body
        do {
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            DispatchQueue.main.async {
                completion(.failure(.invalidRequest))
            }
            return
        }
        
        // Make request
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // Handle network error
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }
            
            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200:
                break // Success, continue processing
            case 429:
                DispatchQueue.main.async {
                    completion(.failure(.rateLimited))
                }
                return
            case 500...599:
                DispatchQueue.main.async {
                    completion(.failure(.serverError(httpResponse.statusCode)))
                }
                return
            default:
                if httpResponse.statusCode != 200 {
                    // Try to parse error message
                    if let data = data,
                       let geminiResponse = try? JSONDecoder().decode(GeminiResponse.self, from: data),
                       let errorMessage = geminiResponse.error?.message {
                        DispatchQueue.main.async {
                            completion(.failure(.apiError(errorMessage)))
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        completion(.failure(.serverError(httpResponse.statusCode)))
                    }
                    return
                }
            }
            
            // Parse response
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let geminiResponse = try decoder.decode(GeminiResponse.self, from: data)
                
                // Check for API error
                if let error = geminiResponse.error {
                    DispatchQueue.main.async {
                        completion(.failure(.apiError(error.message ?? "Unknown API error")))
                    }
                    return
                }
                
                // Check for blocked content
                if let blockReason = geminiResponse.promptFeedback?.blockReason {
                    DispatchQueue.main.async {
                        completion(.failure(.apiError("Content blocked: \(blockReason)")))
                    }
                    return
                }
                
                // Extract response text
                guard let candidate = geminiResponse.candidates?.first,
                      let content = candidate.content,
                      let text = content.parts.first?.text else {
                    DispatchQueue.main.async {
                        completion(.failure(.noContent))
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(text))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            }
        }
        
        task.resume()
    }
}

// MARK: - Async/Await Support

@available(iOS 15.0, *)
extension GeminiService {
    
    /// Sends a message using async/await
    /// - Parameters:
    ///   - message: The user's message
    ///   - includeHistory: Whether to include conversation history
    /// - Returns: The response string
    func sendMessage(_ message: String, includeHistory: Bool = true) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            sendMessage(message, includeHistory: includeHistory) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Sends a simple message using async/await
    /// - Parameter message: The message to send
    /// - Returns: The response string
    func sendSimpleMessage(_ message: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            sendSimpleMessage(message) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
