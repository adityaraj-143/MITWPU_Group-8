//
//  ChatBotViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class ChatbotViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var GreetText: UILabel!
    
    @IBOutlet weak var ChatBotIcon: UIImageView!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var prompt: String?
    
    struct Message {
        let text: String
        let isIncoming: Bool
    }
    
    var messages = [
        Message(text: "Hello 👋", isIncoming: false),
        Message(text: "Hi, how can I help you?", isIncoming: true),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        
//        collectionView.isUserInteractionEnabled = false
        
        collectionView.register(
            UINib(nibName: "ChatMessageCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ChatMessageCollectionViewCell"
        )
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: view.bounds.width, height: 44)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        textField.delegate = self   // Imp
        textField.returnKeyType = .send
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let prompt = prompt {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.sendPrompt(prompt)
            }
        }
        
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

           view.bringSubviewToFront(inputContainerView)  // ADD THIS
           
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
        textField.layer.cornerRadius = textField.frame.height / 2
        textField.layer.masksToBounds = true
    }
    
    
    @IBAction func sendTapped(_ sender: Any) {
        guard let text = textField.text, !text.isEmpty else { return }
           
           view.endEditing(true) // dismiss keyboard immediately
           
           messages.append(Message(text: text, isIncoming: false))
           
           let indexPath = IndexPath(item: messages.count - 1, section: 0)
           collectionView.insertItems(at: [indexPath])
           collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
           
           textField.text = ""
           
           DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
               self.messages.append(Message(text: "Bot reply to: \(text)", isIncoming: true))
               self.collectionView.reloadData()
               
               let botIndex = IndexPath(item: self.messages.count - 1, section: 0)
               self.collectionView.scrollToItem(at: botIndex, at: .bottom, animated: true)
           }
    }
    
    func sendPrompt(_ text: String) {
        
        messages.append(Message(text: text, isIncoming: false))
        
        let indexPath = IndexPath(item: messages.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        
        // fake bot reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.messages.append(Message(text: "Bot reply to: \(text)", isIncoming: true))
            self.collectionView.reloadData()
            
            let botIndex = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView.scrollToItem(at: botIndex, at: .bottom, animated: true)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        if touch.view is UIControl {
            return false
        }
        return true
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


}


