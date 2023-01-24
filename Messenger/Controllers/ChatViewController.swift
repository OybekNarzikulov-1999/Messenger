//
//  ChatViewController.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 06/12/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVKit
import CoreLocation

final class ChatViewController: MessagesViewController {
    
    // MARK: - Properties
    
    public static let dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = Locale(identifier: "en-En")
        return formatter
        
    }()
    
    private var selfPhotoUrl: URL?
    private var otherUserPhotoUrl: URL?
    
    private var otherUserEmail: String
    private var conversationId: String?
    public var isNewConversation = false
    
    var messages = [Message]()
    
    private var selfSender: Sender? {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        return Sender(photoURL: "",
               senderId: safeEmail,
               displayName: "Me")
    }
    
    
    // MARK: - Lifecycle
    
    init(with email: String, id: String?) {
        otherUserEmail = email
        conversationId = id
        super.init(nibName: nil, bundle: nil)
        
        if let conversationId = conversationId {
            listenForMessages(id: conversationId)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        
        setupInputButton()
    }
    
    // MARK: - Selectors
    
    
    // MARK: - Helper Methods
    
    private func setupInputButton(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Media", message: "Choose what would you like to attach", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self? .presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self] _ in
            self?.presentLocationPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentLocationPicker(){
        
        guard let messageId = createMessageId(),
              let conversationId = conversationId,
              let otherUserName = title,
              let selfSender = selfSender
        else {
            return
        }
        
        let vc = LocationPickerViewController(coordinates: nil, isPickable: true)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = "Pick Location"
        vc.hidesBottomBarWhenPushed = true
        vc.completion = { [weak self] selectedCoordinates in
            guard let strongSelf = self else {return}
            
            let longitude: Double = selectedCoordinates.longitude
            let latitude: Double = selectedCoordinates.latitude
            
            print("long: \(longitude)")
            print("lat: \(latitude)")
            
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                    size: .zero)
            
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .location(location))
            
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, otherUserName: otherUserName, newMessage: message) { success in
                if success {
                    print("sent location message")
                } else {
                    print("Failed to send a location message")
                }
            }
            
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentPhotoInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Photo", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentVideInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Video", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }

    
    private func listenForMessages(id: String){
        
        DatabaseManager.shared.getAllMessagesFromConversation(with: id) { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                }
            case .failure(let error):
                print("Error While Fetch All Messages For Conversation: \(error)")
            }
        }
        
    }

}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil )
        
        guard let messageId = createMessageId(),
              let conversationId = conversationId,
              let otherUserName = title,
              let selfSender = selfSender
        else {
            return
        }
        
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
           let imageData = image.pngData() {
            
            let fileName = "photo_message_\(messageId.replacingOccurrences(of: " ", with: "-")).png"
            
            // Upload image
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName) { [weak self] result in
                guard let strongSelf = self else {return}
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    
                    guard let url = URL(string: urlString),
                          let placeholer = UIImage(systemName: "plus") else {
                              return
                          }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholer,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .photo(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, otherUserName: otherUserName, newMessage: message) { success in
                        if success {
                            print("sent photo message")
                        } else {
                            print("Failed to send a message")
                        }
                    }
                    
                case .failure(let error):
                    print("MEssage photo upload error: \(error)")
                }
                
            }
            
        } else if let videoUrl = info[.mediaURL] as? URL {
            
            let fileName = "video_message_\(messageId.replacingOccurrences(of: " ", with: "-")).mov"
            
            // Upload video
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName) { [weak self] result in
                guard let strongSelf = self else {return}
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    print("Uploaded message video: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                          let placeholer = UIImage(systemName: "plus") else {
                              return
                          }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholer,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .video(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, otherUserName: otherUserName, newMessage: message) { success in
                        if success {
                            print("sent photo messag e")
                        } else {
                            print("Failed to send a message")
                        }
                    }
                    
                case .failure(let error):
                    print("MEssage photo upload error: \(error)")
                }
                
            }
            
        }
        
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
                  return
        }
        
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        
        // Send message
        if isNewConversation {
            // Create a new conversation in database
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, otherUserName: title ?? "User" ,firstMessage: message) { [weak self] success in
                if success {
                    print("Message sent")
                    self?.isNewConversation = false
                    self?.conversationId = "conversation_\(message.messageId)"
                    guard let newConversationId = self?.conversationId else {return}
                    self?.listenForMessages(id: newConversationId)
                    self?.messageInputBar.inputTextView.text = nil
                } else {
                    print("Failed to sent")
                }
            }
            
        } else {
            guard let conversationId = conversationId,
                  let name = title else {return}
            // Append message to existing conversation data
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, otherUserName: name, newMessage: message) { [weak self] success in
                if success {
                    print("Message sent")
                    self?.messageInputBar.inputTextView.text = nil
                    
                } else {
                    print("Failed to sent")
                }
            }
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
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        guard let message = message as? Message else {return}
        
        switch message.kind {
        case .photo(let media):
            
            imageView.sd_setImage(with: media.url, completed: nil)
            
        default:
            break
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        if message.sender.senderId != selfSender?.senderId {
            return .secondarySystemBackground
        }
        return .link
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {return}
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        if message.sender.senderId == selfSender?.senderId {
            
            if let selfPhoto = selfPhotoUrl {
                avatarView.sd_setImage(with: selfPhoto, completed: nil)
            } else {
                let path = "images/\(safeEmail)_profile_picture.png"
                StorageManager.shared.downloadURL(for: path) { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.selfPhotoUrl = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                }
            }
            
        } else {
            let otherUserSafeEmail = DatabaseManager.safeEmail(emailAddress: otherUserEmail)
            
            if let otherPhoto = otherUserPhotoUrl {
                avatarView.sd_setImage(with: otherPhoto, completed: nil)
            } else {
                let path = "images/\(otherUserSafeEmail)_profile_picture.png"
                StorageManager.shared.downloadURL(for: path) { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.otherUserPhotoUrl = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                }
            }
            
        }
        
    }
    
}

extension ChatViewController: MessageCellDelegate {
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {return}
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .location(let locationItem):
            let coordinates = locationItem.location.coordinate
            let vc = LocationPickerViewController(coordinates: coordinates, isPickable: false)
            vc.title = "Location"
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {return}
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            
            let vc = PhotoViewerViewController(url: media.url)
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
            
        case .video(let media):
            guard let videoUrl = media.url else {return}
            
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            vc.player?.play()
            present(vc, animated: true)
            
        default:
            break
        }
        
    }
    
}
