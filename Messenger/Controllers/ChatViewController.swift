//
//  ChatViewController.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 06/12/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    // MARK: - Properties
    
    public static let dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = Locale(identifier: "en-En")
        return formatter
        
    }()
    
    private var otherUserEmail: String
    public var isNewConversation = false
    
    var messages = [Message]()
    
    private var selfSender: Sender? {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        return Sender(photoURL: "",
               senderId: safeEmail,
               displayName: "Oybek")
    }
    
    
    // MARK: - Lifecycle
    
    init(with email: String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDataSource = self
        
        messageInputBar.delegate = self
    }
    
    // MARK: - Selectors
    
    
    // MARK: - Helper Methods

}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
                  return
        }
        
        // TODO: Send message
        if isNewConversation {
            // Create a new conversation in database
            
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .text(text))
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, otherUserName: self.title ?? "User" ,firstMessage: message) { success in
                if success {
                    print("Message sent")
                } else {
                    print("Failed to sent")
                }
            }
            
        } else {
            // Append message to existing conversation data
        }
    }
    
    private func createMessageId() -> String? {
        
        // Date, otherUserEmail, selfEmail, Random Int
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        print("Created message ID: \(newIdentifier)")
        return newIdentifier
        
    }
    
}

extension ChatViewController: MessagesDisplayDelegate, MessagesDataSource, MessagesLayoutDelegate {
    
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil, email is not cached ")
        return Sender(photoURL: "", senderId: "12321", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}
