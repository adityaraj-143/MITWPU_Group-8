//
//  ChatBotViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

// MARK: - Chat Message Model

/// Represents a single chat message in the conversation
struct ChatBubbleMessage {
    let id: UUID
    let text: String
    let isIncoming: Bool
    let timestamp: Date
    let status: MessageStatus
    
    enum MessageStatus {
        case sending
        case sent
        case failed
        case received
    }
    
    init(
        id: UUID = UUID(),
        text: String,
        isIncoming: Bool,
        timestamp: Date = Date(),
        status: MessageStatus = .sent
    ) {
        self.id = id
        self.text = text
        self.isIncoming = isIncoming
        self.timestamp = timestamp
        self.status = status
    }
}

// MARK: - Chatbot View Controller

final class ChatbotViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var GreetText: UILabel!
    @IBOutlet weak var ChatBotIcon: UIImageView!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: - Properties
    
    /// Initial prompt passed from previous screen (e.g., FAQ question)
    var prompt: String?
    
    /// All messages in the conversation
    private var messages: [ChatBubbleMessage] = []
    
    /// Reference to Gemini service
    private let geminiService = GeminiService.shared
    
    /// Flag to track if we're waiting for a response
    private var isWaitingForResponse = false
    
    /// Typing indicator message ID (used to remove it when response arrives)
    private var typingIndicatorId: UUID?
    
    /// Welcome message shown at start
    private let welcomeMessage = "Hi! I'm EyeRis, your eye health assistant. How can I help you today?"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextField()
        setupCollectionView()
        setupKeyboardHandling()
        setupTapGesture()
        setupInitialMessages()
        
        // Handle initial prompt if provided
        if let prompt = prompt, !prompt.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.sendMessage(prompt)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textField.layer.cornerRadius = textField.frame.height / 2
        textField.layer.masksToBounds = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    
    private func setupTextField() {
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        textField.rightViewMode = .always
        textField.delegate = self
        textField.returnKeyType = .send
        textField.placeholder = "Ask about eye health..."
        textField.autocorrectionType = .yes
        textField.spellCheckingType = .yes
    }
    
    private func setupCollectionView() {
        collectionView.register(
            UINib(nibName: "ChatMessageCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ChatMessageCollectionViewCell"
        )
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: view.bounds.width, height: 44)
            layout.minimumLineSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupInitialMessages() {
        // Add welcome message from bot
        let welcomeMsg = ChatBubbleMessage(
            text: welcomeMessage,
            isIncoming: true,
            status: .received
        )
        messages.append(welcomeMsg)
        collectionView.reloadData()
    }
    
    // MARK: - Keyboard Handling
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        view.bringSubviewToFront(inputContainerView)
        
        let moveUp = frame.height - view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: duration) {
            self.inputContainerView.transform = CGAffineTransform(translationX: 0, y: -moveUp)
        }
        
        // Scroll to bottom when keyboard appears
        scrollToBottom(animated: true)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        UIView.animate(withDuration: duration) {
            self.inputContainerView.transform = .identity
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - IBActions
    
    @IBAction func sendTapped(_ sender: Any) {
        sendCurrentMessage()
    }
    
    // MARK: - Message Handling
    
    /// Sends the current text field content as a message
    private func sendCurrentMessage() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        
        view.endEditing(true)
        textField.text = ""
        
        sendMessage(text)
    }
    
    /// Sends a message and gets AI response
    /// - Parameter text: The message text to send
    private func sendMessage(_ text: String) {
        guard !isWaitingForResponse else {
            showErrorAlert(message: "Please wait for the current response.")
            return
        }
        
        // Add user message
        let userMessage = ChatBubbleMessage(
            text: text,
            isIncoming: false,
            status: .sent
        )
        appendMessage(userMessage)
        
        // Show typing indicator
        showTypingIndicator()
        
        // Set waiting state
        isWaitingForResponse = true
        updateSendButtonState()
        
        // Make API call
        geminiService.sendMessage(text, includeHistory: true) { [weak self] result in
            guard let self = self else { return }
            
            // Remove typing indicator
            self.hideTypingIndicator()
            
            // Reset waiting state
            self.isWaitingForResponse = false
            self.updateSendButtonState()
            
            switch result {
            case .success(let response):
                self.handleSuccessResponse(response)
                
            case .failure(let error):
                self.handleErrorResponse(error, originalMessage: text)
            }
        }
    }
    
    /// Handles successful API response
    private func handleSuccessResponse(_ response: String) {
        let botMessage = ChatBubbleMessage(
            text: response,
            isIncoming: true,
            status: .received
        )
        appendMessage(botMessage)
        
        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Handles API error response
    private func handleErrorResponse(_ error: GeminiServiceError, originalMessage: String) {
        // Show error message in chat
        let errorMessage = ChatBubbleMessage(
            text: "Sorry, I couldn't process your request. \(error.localizedDescription)",
            isIncoming: true,
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
    private func isRecoverableError(_ error: GeminiServiceError) -> Bool {
        switch error {
        case .networkError, .rateLimited, .serverError:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Typing Indicator
    
    private func showTypingIndicator() {
        let typingMessage = ChatBubbleMessage(
            text: "Typing...",
            isIncoming: true,
            status: .sending
        )
        typingIndicatorId = typingMessage.id
        appendMessage(typingMessage)
    }
    
    private func hideTypingIndicator() {
        guard let typingId = typingIndicatorId else { return }
        
        if let index = messages.firstIndex(where: { $0.id == typingId }) {
            messages.remove(at: index)
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
        
        typingIndicatorId = nil
    }
    
    // MARK: - Collection View Helpers
    
    /// Appends a message and updates the collection view
    private func appendMessage(_ message: ChatBubbleMessage) {
        messages.append(message)
        
        let indexPath = IndexPath(item: messages.count - 1, section: 0)
        
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: [indexPath])
        }, completion: { [weak self] _ in
            self?.scrollToBottom(animated: true)
        })
    }
    
    /// Scrolls to the bottom of the conversation
    private func scrollToBottom(animated: Bool) {
        guard messages.count > 0 else { return }
        
        let lastIndexPath = IndexPath(item: messages.count - 1, section: 0)
        collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: animated)
    }
    
    // MARK: - UI State Updates
    
    /// Updates the send button enabled state
    private func updateSendButtonState() {
        let hasText = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        sendButton?.isEnabled = hasText && !isWaitingForResponse
        sendButton?.alpha = (hasText && !isWaitingForResponse) ? 1.0 : 0.5
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
    private func showRetryAlert(for message: String, error: GeminiServiceError) {
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
        messages.removeAll()
        geminiService.clearConversationHistory()
        setupInitialMessages()
        collectionView.reloadData()
    }
    
    /// Sends a pre-defined prompt (e.g., from FAQ)
    func sendPrompt(_ text: String) {
        sendMessage(text)
    }
}

// MARK: - UITextFieldDelegate

extension ChatbotViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCurrentMessage()
        return true
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        // Update send button state after text changes
        DispatchQueue.main.async { [weak self] in
            self?.updateSendButtonState()
        }
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ChatbotViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        // Don't dismiss keyboard when tapping on controls
        if touch.view is UIControl {
            return false
        }
        return true
    }
}

// MARK: - UICollectionViewDataSource

extension ChatbotViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return messages.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ChatMessageCollectionViewCell",
            for: indexPath
        ) as? ChatMessageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let message = messages[indexPath.item]
        cell.configure(text: message.text, isIncoming: message.isIncoming)
        
        // Apply typing animation for typing indicator
        if message.id == typingIndicatorId {
            applyTypingAnimation(to: cell)
        }
        
        return cell
    }
    
    /// Applies a pulsing animation to the typing indicator cell
    private func applyTypingAnimation(to cell: ChatMessageCollectionViewCell) {
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            options: [.repeat, .autoreverse, .allowUserInteraction],
            animations: {
                cell.alpha = 0.5
            }
        )
    }
}

// MARK: - UICollectionViewDelegate

extension ChatbotViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        // Dismiss keyboard when tapping on a message
        view.endEditing(true)
        
        // Optional: Copy message to clipboard on long press could be added here
        let message = messages[indexPath.item]
        
        // Show action sheet for message options
        showMessageOptions(for: message, at: indexPath)
    }
    
    /// Shows action sheet with message options
    private func showMessageOptions(for message: ChatBubbleMessage, at indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Copy", style: .default) { _ in
            UIPasteboard.general.string = message.text
            
            // Show feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alert.popoverPresentationController {
            if let cell = collectionView.cellForItem(at: indexPath) {
                popover.sourceView = cell
                popover.sourceRect = cell.bounds
            }
        }
        
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ChatbotViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // Return estimated size - actual size handled by preferredLayoutAttributesFitting in cell
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
}
