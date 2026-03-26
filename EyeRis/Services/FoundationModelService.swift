//
//  FoundationModelService.swift
//  EyeRis
//
//  Created by SDC-USER on 25/03/26.
//  Migrated from GeminiService to use Apple's Foundation Models
//

import Foundation
import FoundationModels

// MARK: - Service Errors

enum FoundationModelServiceError: LocalizedError {
    case modelNotAvailable
    case sessionCreationFailed
    case generationFailed(Error)
    case noContent
    case guardedContent(String)
    case unsupportedDevice
    
    var errorDescription: String? {
        switch self {
        case .modelNotAvailable:
            return "The on-device AI model is not available on this device."
        case .sessionCreationFailed:
            return "Failed to create AI session."
        case .generationFailed(let error):
            return "Failed to generate response: \(error.localizedDescription)"
        case .noContent:
            return "No response content received."
        case .guardedContent(let reason):
            return "Content was blocked: \(reason)"
        case .unsupportedDevice:
            return "This device does not support on-device AI features."
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
        case assistant
    }
}

// MARK: - Foundation Model Service

/// Singleton service for interacting with Apple's Foundation Models (on-device AI)
@available(iOS 26.0, *)
final class FoundationModelService {
    
    // MARK: - Singleton
    
    static let shared = FoundationModelService()
    
    private init() {}
    
    // MARK: - Configuration
    
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
    
    // MARK: - Conversation History
    
    /// Maintains conversation history for context
    private var conversationHistory: [ChatMessage] = []
    
    /// Maximum number of messages to keep in history
    private let maxHistoryCount = 20
    
    // MARK: - Session Management
    
    /// The language model session for multi-turn conversations
    private var session: LanguageModelSession?
    
    /// Creates or returns existing session with system prompt
    private func getOrCreateSession() throws -> LanguageModelSession {
        if let existingSession = session {
            return existingSession
        }
        
        // Check if model is available
        guard SystemLanguageModel.default.isAvailable else {
            throw FoundationModelServiceError.modelNotAvailable
        }
        
        // Create session with system prompt instructions
        let instructions = Instructions(systemPrompt)
        let newSession = LanguageModelSession(instructions: instructions)
        self.session = newSession
        
        return newSession
    }
    
    // MARK: - Public Methods
    
    /// Checks if the Foundation Model is available on this device
    var isAvailable: Bool {
        return SystemLanguageModel.default.isAvailable
    }
    
    /// Clears the conversation history and resets the session
    func clearConversationHistory() {
        conversationHistory.removeAll()
        session = nil
    }
    
    /// Sends a message and gets a response using Foundation Models
    /// - Parameters:
    ///   - message: The user's message
    ///   - includeHistory: Whether to include conversation history for context (handled by session)
    ///   - completion: Completion handler with Result containing response or error
    func sendMessage(
        _ message: String,
        includeHistory: Bool = true,
        completion: @escaping (Result<String, FoundationModelServiceError>) -> Void
    ) {
        // Add user message to history
        let userMessage = ChatMessage(role: .user, content: message, timestamp: Date())
        addToHistory(userMessage)
        
        Task {
            do {
                let session = try getOrCreateSession()
                
                // Generate response using the session (maintains conversation context automatically)
                let response = try await session.respond(to: message)
                
                let responseText = response.content
                
                // Check if response is empty
                guard !responseText.isEmpty else {
                    // Remove user message from history since we failed
                    await MainActor.run {
                        self.conversationHistory.removeLast()
                        completion(.failure(.noContent))
                    }
                    return
                }
                
                // Add assistant response to history
                let assistantMessage = ChatMessage(role: .assistant, content: responseText, timestamp: Date())
                
                await MainActor.run {
                    self.addToHistory(assistantMessage)
                    completion(.success(responseText))
                }
                
            } catch let error as LanguageModelSession.GenerationError {
                await MainActor.run {
                    self.conversationHistory.removeLast()
                    
                    switch error {
                    case .guardrailViolation(let violation):
                        completion(.failure(.guardedContent(String(describing: violation))))
                    default:
                        completion(.failure(.generationFailed(error)))
                    }
                }
            } catch {
                await MainActor.run {
                    self.conversationHistory.removeLast()
                    completion(.failure(.generationFailed(error)))
                }
            }
        }
    }
    
    /// Sends a simple one-off message without conversation history
    /// - Parameters:
    ///   - message: The message to send
    ///   - completion: Completion handler with Result
    func sendSimpleMessage(
        _ message: String,
        completion: @escaping (Result<String, FoundationModelServiceError>) -> Void
    ) {
        Task {
            do {
                // Check if model is available
                guard SystemLanguageModel.default.isAvailable else {
                    await MainActor.run {
                        completion(.failure(.modelNotAvailable))
                    }
                    return
                }
                
                // Create a fresh session for one-off message
                let instructions = Instructions(systemPrompt)
                let tempSession = LanguageModelSession(instructions: instructions)
                
                let response = try await tempSession.respond(to: message)
                
                let responseText = response.content
                
                guard !responseText.isEmpty else {
                    await MainActor.run {
                        completion(.failure(.noContent))
                    }
                    return
                }
                
                await MainActor.run {
                    completion(.success(responseText))
                }
                
            } catch let error as LanguageModelSession.GenerationError {
                await MainActor.run {
                    switch error {
                    case .guardrailViolation(let violation):
                        completion(.failure(.guardedContent(String(describing: violation))))
                    default:
                        completion(.failure(.generationFailed(error)))
                    }
                }
            } catch {
                await MainActor.run {
                    completion(.failure(.generationFailed(error)))
                }
            }
        }
    }
    
    // MARK: - Streaming Support
    
    /// Sends a message and streams the response
    /// - Parameters:
    ///   - message: The user's message
    ///   - onPartialResponse: Called with each partial response chunk
    ///   - completion: Called when streaming is complete or on error
    func sendMessageStreaming(
        _ message: String,
        onPartialResponse: @escaping (String) -> Void,
        completion: @escaping (Result<String, FoundationModelServiceError>) -> Void
    ) {
        // Add user message to history
        let userMessage = ChatMessage(role: .user, content: message, timestamp: Date())
        addToHistory(userMessage)
        
        Task {
            do {
                let session = try getOrCreateSession()
                
                var fullResponse = ""
                
                // Stream the response
                let stream = session.streamResponse(to: message)
                
                for try await partialResponse in stream {
                    let text = partialResponse.content
                    fullResponse = text
                    
                    await MainActor.run {
                        onPartialResponse(text)
                    }
                }
                
                // Add assistant response to history
                let assistantMessage = ChatMessage(role: .assistant, content: fullResponse, timestamp: Date())
                
                await MainActor.run {
                    self.addToHistory(assistantMessage)
                    completion(.success(fullResponse))
                }
                
            } catch let error as LanguageModelSession.GenerationError {
                await MainActor.run {
                    self.conversationHistory.removeLast()
                    
                    switch error {
                    case .guardrailViolation(let violation):
                        completion(.failure(.guardedContent(String(describing: violation))))
                    default:
                        completion(.failure(.generationFailed(error)))
                    }
                }
            } catch {
                await MainActor.run {
                    self.conversationHistory.removeLast()
                    completion(.failure(.generationFailed(error)))
                }
            }
        }
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
}

// MARK: - Async/Await Support

@available(iOS 26.0, *)
extension FoundationModelService {
    
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
