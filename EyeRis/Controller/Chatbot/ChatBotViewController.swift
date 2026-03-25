//
//  ChatBotViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 28/11/25.
//  Refactored to use MessageKit on 23/03/26.
//  Migrated to Apple Foundation Models on 25/03/26.
//

import UIKit
import MessageKit
import InputBarAccessoryView

// MARK: - MessageKit Models

/// Represents a sender in the conversation
struct ChatSender: SenderType {
    var senderId: String
    var displayName: String
}

/// Represents a chat message conforming to MessageKit's MessageType
struct ChatBubbleMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    /// Message status for UI feedback
    var status: BubbleMessageStatus
    
    enum BubbleMessageStatus {
        case sending
        case sent
        case failed
        case received
    }
    
    init(
        sender: SenderType,
        messageId: String = UUID().uuidString,
        sentDate: Date = Date(),
        kind: MessageKind,
        status: BubbleMessageStatus = .sent
    ) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
        self.status = status
    }
    
    /// Convenience initializer for text messages
    init(text: String, sender: SenderType, status: BubbleMessageStatus = .sent) {
        self.sender = sender
        self.messageId = UUID().uuidString
        self.sentDate = Date()
        self.kind = .text(text)
        self.status = status
    }
}

// MARK: - Chatbot View Controller

@available(iOS 26.0, *)
final class ChatbotViewController: MessagesViewController {
    
    // MARK: - Senders
    
    private let currentUser = ChatSender(senderId: "user", displayName: "You")
    private let botSender = ChatSender(senderId: "eyeris", displayName: "EyeRis")
    
    // MARK: - Properties
    
    /// Initial prompt passed from previous screen (e.g., FAQ question)
    var prompt: String?
    
    /// Reference to chat store for in-memory persistence
    private let chatStore = ChatStore.shared
    
    /// Reference to Foundation Model service (on-device AI)
    private let aiService = FoundationModelService.shared
    
    /// Flag to track if we're waiting for a response
    private var isWaitingForResponse = false
    
    /// Welcome message shown at start
    private let welcomeMessage = "Hi! I'm EyeRis, your eye health assistant. How can I help you today?"
    
    /// Message shown when AI is not available on this device
    private let unavailableMessage = "On-device AI is not available on this device. Please ensure you're running iOS 26 or later on a supported device."
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "EyeRis"
        
        configureMessageCollectionView()
        configureMessageInputBar()
        setupInitialMessages()
        
        // Check if AI is available
        checkAIAvailability()
        
        // Handle initial prompt if provided
        if let prompt = prompt, !prompt.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.sendMessage(prompt)
            }
        }
    }
    
    // MARK: - Configuration
    
    private func checkAIAvailability() {
        if !aiService.isAvailable {
            // Show unavailable message
            let unavailableMsg = ChatBubbleMessage(
                text: unavailableMessage,
                sender: botSender,
                status: .received
            )
            appendMessage(unavailableMsg)
            
            // Disable input
            messageInputBar.inputTextView.isEditable = false
            messageInputBar.inputTextView.placeholder = "AI not available on this device"
            updateSendButtonState(enabled: false)
        }
    }
    
    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        // Customize appearance
        messagesCollectionView.backgroundColor = .systemGray6
        
        // Scroll to bottom on new messages
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnInputBarHeightChanged = true
        showMessageTimestampOnSwipeLeft = true
        
        // Remove avatars for both user and bot
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
            layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)))
            layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)))
        }
    }
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        
        // Customize input bar appearance
        messageInputBar.inputTextView.placeholder = "Ask about eye health..."
        messageInputBar.inputTextView.placeholderTextColor = .placeholderText
        messageInputBar.inputTextView.backgroundColor = .tertiarySystemBackground
        messageInputBar.inputTextView.layer.cornerRadius = 18
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        
        // Configure send button
        messageInputBar.sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        messageInputBar.sendButton.setTitle("", for: .normal)
        messageInputBar.sendButton.tintColor = .systemBlue
        messageInputBar.sendButton.setSize(CGSize(width: 42, height: 42), animated: false)
        
        // Input bar background
        messageInputBar.backgroundView.backgroundColor = .systemGray6
        messageInputBar.separatorLine.isHidden = true
        
        // Padding
        messageInputBar.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    }
    
    private func setupInitialMessages() {
        // Check if we already have messages from a previous visit
        if chatStore.hasMessages {
            // Restore existing messages
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToLastItem(animated: false)
        } else {
            // First time - add welcome message
            let welcomeMsg = ChatBubbleMessage(
                text: welcomeMessage,
                sender: botSender,
                status: .received
            )
            chatStore.addMessage(welcomeMsg)
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToLastItem(animated: false)
        }
    }
    
    // MARK: - Message Handling
    
    /// Sends a message and gets AI response
    /// - Parameter text: The message text to send
    private func sendMessage(_ text: String) {
        guard aiService.isAvailable else {
            showErrorAlert(message: "On-device AI is not available on this device.")
            return
        }
        
        guard !isWaitingForResponse else {
            showErrorAlert(message: "Please wait for the current response.")
            return
        }
        
        // Add user message
        let userMessage = ChatBubbleMessage(
            text: text,
            sender: currentUser,
            status: .sent
        )
        appendMessage(userMessage)
        
        // Show typing indicator
        setTypingIndicatorViewHidden(false, animated: true)
        
        // Set waiting state
        isWaitingForResponse = true
        updateSendButtonState(enabled: false)
        
        // Make AI call using Foundation Models
        aiService.sendMessage(text, includeHistory: true) { [weak self] result in
            guard let self = self else { return }
            
            // Remove typing indicator
            self.setTypingIndicatorViewHidden(true, animated: true)
            
            // Reset waiting state
            self.isWaitingForResponse = false
            self.updateSendButtonState(enabled: true)
            
            switch result {
            case .success(let response):
                self.handleSuccessResponse(response)
                
            case .failure(let error):
                self.handleErrorResponse(error, originalMessage: text)
            }
        }
    }
    
    /// Handles successful AI response
    private func handleSuccessResponse(_ response: String) {
        let botMessage = ChatBubbleMessage(
            text: response,
            sender: botSender,
            status: .received
        )
        appendMessage(botMessage)
        
        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Handles AI error response
    private func handleErrorResponse(_ error: FoundationModelServiceError, originalMessage: String) {
        // Show error message in chat
        let errorMessage = ChatBubbleMessage(
            text: "Sorry, I couldn't process your request. \(error.localizedDescription ?? "Unknown error")",
            sender: botSender,
            status: .received
        )
        appendMessage(errorMessage)
        
        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        // Show retry alert for recoverable errors
        if isRecoverableError(error) {
            showRetryAlert(for: originalMessage, error: error)
        }
    }
    
    /// Checks if an error is recoverable (can be retried)
    private func isRecoverableError(_ error: FoundationModelServiceError) -> Bool {
        switch error {
        case .generationFailed, .noContent:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Collection View Helpers
    
    /// Appends a message and updates the collection view
    private func appendMessage(_ message: ChatBubbleMessage) {
        chatStore.addMessage(message)
        
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([chatStore.messages.count - 1])
        }, completion: { [weak self] _ in
            self?.messagesCollectionView.scrollToLastItem(animated: true)
        })
    }
    
    // MARK: - UI State Updates
    
    /// Updates the send button enabled state
    private func updateSendButtonState(enabled: Bool) {
        messageInputBar.sendButton.isEnabled = enabled
        messageInputBar.sendButton.alpha = enabled ? 1.0 : 0.5
    }
    
    // MARK: - Alerts
    
    /// Shows an error alert
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    /// Shows retry alert for failed messages
    private func showRetryAlert(for message: String, error: FoundationModelServiceError) {
        let alert = UIAlertController(
            title: "Message Failed",
            message: "Would you like to retry sending your message?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.sendMessage(message)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Public Methods
    
    /// Clears the conversation and starts fresh
    func clearConversation() {
        chatStore.clearAll()
        aiService.clearConversationHistory()
        setupInitialMessages()
        messagesCollectionView.reloadData()
    }
    
    /// Sends a pre-defined prompt (e.g., from FAQ)
    func sendPrompt(_ text: String) {
        sendMessage(text)
    }
}

// MARK: - MessagesDataSource

@available(iOS 26.0, *)
extension ChatbotViewController: MessagesDataSource {
    
    var currentSender: SenderType {
        return currentUser
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return chatStore.messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return chatStore.messages[indexPath.section]
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // Show sender name for bot messages
        if message.sender.senderId == botSender.senderId {
            return NSAttributedString(
                string: message.sender.displayName,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                    .foregroundColor: UIColor.secondaryLabel
                ]
            )
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // Show timestamp
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let dateString = formatter.string(from: message.sentDate)
        
        return NSAttributedString(
            string: dateString,
            attributes: [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.tertiaryLabel
            ]
        )
    }
}

// MARK: - MessagesLayoutDelegate

@available(iOS 26.0, *)
extension ChatbotViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        // Show label for bot messages
        if message.sender.senderId == botSender.senderId {
            return 20
        }
        return 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

// MARK: - MessagesDisplayDelegate

@available(iOS 26.0, *)
extension ChatbotViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if isFromCurrentSender(message: message) {
            return .systemBlue
        } else {
            return .tertiarySystemBackground
        }
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if isFromCurrentSender(message: message) {
            return .white
        } else {
            return .label
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Hide all avatars
        avatarView.isHidden = true
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        // Style for detected links, phone numbers, etc.
        return [
            .foregroundColor: isFromCurrentSender(message: message) ? UIColor.white : UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .phoneNumber]
    }
}

// MARK: - InputBarAccessoryViewDelegate

@available(iOS 26.0, *)
extension ChatbotViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // Clear input
        inputBar.inputTextView.text = ""
        inputBar.invalidatePlugins()
        
        // Send message
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        sendMessage(trimmedText)
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        // Enable/disable send button based on text
        let hasText = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        inputBar.sendButton.isEnabled = hasText && !isWaitingForResponse
        inputBar.sendButton.alpha = (hasText && !isWaitingForResponse) ? 1.0 : 0.5
    }
}

// MARK: - MessageCellDelegate (Optional - for tap handling)

@available(iOS 26.0, *)
extension ChatbotViewController: MessageCellDelegate {
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = chatStore.messages[indexPath.section]
        
        // Show action sheet for message options
        showMessageOptions(for: message)
    }
    
    /// Shows action sheet with message options
    private func showMessageOptions(for message: ChatBubbleMessage) {
        guard case .text(let text) = message.kind else { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Copy", style: .default) { _ in
            UIPasteboard.general.string = text
            
            // Show feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
}
