//
//  ChatBotViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class ChatbotViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var GreetText: UILabel!
    
    @IBOutlet weak var ChatBotIcon: UIImageView!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var TextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    struct Message {
        let text: String
        let isIncoming: Bool
    }
    
    var messages = [
        Message(text: "Hello 👋", isIncoming: true),
        Message(text: "Hi, how can I help you?", isIncoming: false),
        Message(text: "Tell me about EyeRis", isIncoming: true)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        TextField.borderStyle = .none
        TextField.backgroundColor = .white
        TextField.layer.borderWidth = 1
        TextField.layer.borderColor = UIColor.systemGray4.cgColor
        TextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        TextField.leftViewMode = .always
        
        collectionView.register(
            UINib(nibName: "ChatMessageCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ChatMessageCollectionViewCell"
        )
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        TextField.delegate = self   // Imp
        TextField.returnKeyType = .send
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        let moveUp = frame.height - view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: duration) {
            self.inputContainerView.transform = CGAffineTransform(
                translationX: 0,
                y: -moveUp
            )
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        UIView.animate(withDuration: duration) {
            self.inputContainerView.transform = .identity
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        TextField.layer.cornerRadius = TextField.frame.height / 2
        TextField.layer.masksToBounds = true
    }
    
    
    @IBAction func sendTapped(_ sender: Any) {
        guard let text = TextField.text, !text.isEmpty else { return }
        
        // Add outgoing message
        messages.append(Message(text: text, isIncoming: false))
        
        let indexPath = IndexPath(item: messages.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        
        TextField.text = ""
        
        // Fake bot reply after 1 sec
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.messages.append(Message(text: "Bot reply to: \(text)", isIncoming: true))
            self.collectionView.reloadData()
            
            let botIndex = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView.scrollToItem(at: botIndex, at: .bottom, animated: true)
        }
    }
}

extension ChatbotViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ChatMessageCollectionViewCell",
            for: indexPath
        ) as! ChatMessageCollectionViewCell
        
        let message = messages[indexPath.item]
        cell.configure(text: message.text, isIncoming: message.isIncoming)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(
            width: collectionView.bounds.width,
            height: UICollectionViewFlowLayout.automaticSize.height
        )
    }

}


