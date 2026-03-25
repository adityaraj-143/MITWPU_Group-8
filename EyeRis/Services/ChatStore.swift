//
//  ChatStore.swift
//  EyeRis
//
//  Created by SDC-USER on 23/03/26.
//

import Foundation

/// In-memory store for chat messages.
/// Persists messages while the app is running, clears on app termination.
final class ChatStore {
    
    // MARK: - Singleton
    
    static let shared = ChatStore()
    
    private init() {}
    
    // MARK: - Storage
    
    /// All messages in the current session
    private(set) var messages: [ChatBubbleMessage] = []
    
    // MARK: - Methods
    
    /// Adds a message to the store
    func addMessage(_ message: ChatBubbleMessage) {
        messages.append(message)
    }
    
    /// Clears all messages
    func clearAll() {
        messages.removeAll()
    }
    
    /// Returns true if there are existing messages
    var hasMessages: Bool {
        return !messages.isEmpty
    }
}
