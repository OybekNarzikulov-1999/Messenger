//
//  ChatViewController.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 06/12/22.
//

import UIKit
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    // MARK: - Properties
    
    var messages = [Message]()
    
    var selfSender = Sender(photoURL: "", senderId: "1", displayName: "Oybek")
    var otherSender = Sender(photoURL: "", senderId: "2", displayName: "Izzat")
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("I have just finished my work, can we meet somewhere and have a lunch maybe. What do u think?")))
        messages.append(Message(sender: otherSender, messageId: "1", sentDate: Date(), kind: .text("Of course man. I will be on minor station at 5 mins. See ya")))
        
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDataSource = self
    }
    
    // MARK: - Selectors
    
    
    // MARK: - Helper Methods
    
    private func configureNavigationBar(){
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

            navigationController?.navigationBar.tintColor = .black
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().tintColor = .black
            UINavigationBar.appearance().barTintColor = .black
            UINavigationBar.appearance().isTranslucent = false
        }
    }

}

extension ChatViewController: MessagesDisplayDelegate, MessagesDataSource, MessagesLayoutDelegate {
    
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}
