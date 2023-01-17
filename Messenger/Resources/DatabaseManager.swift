//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 01/12/22.
//

import UIKit
import FirebaseDatabase

final class DatabaseManager {
    
    static var shared = DatabaseManager()
    private let database = Database.database().reference()
    
    /// Creates a new user in database if it is not exist or append the user
    public func insertUser(with user: ChatAppUser, completion: @escaping(Bool) -> Void){
        let userDict = ["first_name": user.firstName,
                        "last_name": user.lastName]
        
        database.child(user.safeEmail).setValue(userDict) { error, _ in
            guard error == nil else {
                print("failed to store data in firebase database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                if let userCollection = snapshot.value as? [String:String] {
                    // add user to collection and update database
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email":user.safeEmail
                    ]
                    var newCollection = [[String:String]]()
                    newCollection.append(userCollection)
                    newCollection.append(newElement)
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                } else if var usersCollection = snapshot.value as? [[String:String]] {
                   
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email":user.safeEmail
                    ]
                    
                    usersCollection.append(newElement)
                    self.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                    
                } else {
                    // create collection and upload to database
                    let newCollection: [String:String] = [
                        "name": user.firstName + " " + user.lastName,
                        "email":user.safeEmail
                    ]
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        }
    }
    
    /// Checks does user exist in db
    public func userExists(withEmail email: String, completion: @escaping((Bool) -> Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? [String:Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    /// Converts email into safeEmail
    static func safeEmail(emailAddress: String) -> String {
        var email = emailAddress.replacingOccurrences(of: ".", with: "-")
        email = email.replacingOccurrences(of: "@", with: "-")
        return email
    }
    
    /// Fetchs all users from db
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        self.database.child("users").observeSingleEvent(of: .value) { snapshot in
            if let _ = snapshot.value as? [String: String] {
                completion(.failure(FetchError.failedToFetchUsers))
            } else if let users = snapshot.value as? [[String: String]]{
                completion(.success(users))
            }
        }
        
    }
    
    // Errors enum
    public enum FetchError: Error {
        case failedToFetchUsers
    }
}


// MARK: - Sending Messages / Conversations
extension DatabaseManager {
    
   /*
    
    "foewnfewnfon": {
        "message": [
            "id": String
            "type": text, photo, video
            "content": String
            "date": Date
            "sender_email": String
            "is_read": Bool
        ]
    
    }
    
    "conversation" [
        "conversation_id": "foewnfewnfon"
        "other_user_email": String
        "latest_message": {
            "date": Date
            "latest_message": Message
            "is_read": Bool
        }
    ]
    
    */
    
    
    /// Create a new conversation with target user email and new message
    public func createNewConversation(with otherUserEmail: String, otherUserName: String, firstMessage: Message, completion: @escaping(Bool) -> Void){
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        print(email)
        let ref = database.child("\(safeEmail)")
        
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let conversation: [String: Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "other_user_name": otherUserName,
                "latest_message": [
                    "date": dateString,
                    "latest_message": message,
                    "is_read": false
                ]
            ]
            
            let recipient_conversation: [String: Any] = [
                "id": conversationId,
                "other_user_email": safeEmail,
                "other_user_name": "Self",
                "latest_message": [
                    "date": dateString,
                    "latest_message": message,
                    "is_read": false
                ]
            ]
            
            // Update recipient conversation entry
            self?.database.child("\(otherUserEmail)/conversation").observeSingleEvent(of: .value) { [weak self] snapshot in
                if let singleConversation = snapshot.value as? [String:Any]{
                    
                    var newConversation = [[String: Any]]()
                    newConversation.append(singleConversation)
                    newConversation.append(recipient_conversation)
                    
                    self?.database.child("\(otherUserEmail)/conversation").setValue(newConversation)
                    
                } else if var multipleConversations = snapshot.value as? [[String: Any]] {
                    
                    multipleConversations.append(recipient_conversation)
                    self?.database.child("\(otherUserEmail)/conversation").setValue(multipleConversations)
                    
                } else {
                    
                    self?.database.child("\(otherUserEmail)/conversation").setValue(recipient_conversation)
                    
                }
            }
            
            
            // Update current user conversation entry
            if let  singleConversation = userNode["conversation"] as? [String: Any] {
                
                // User has only one conversation
                var newConversation = [[String: Any]]()
                newConversation.append(singleConversation)
                newConversation.append(conversation)
                userNode["conversation"] = newConversation
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingConversation(conversationId: conversationId, otherUserName: otherUserName, firstMessage: firstMessage, completion: completion)
                }
                
            } else if var conversations = userNode["conversation"] as? [[String: Any]] {
                
                // User has more than one conversation
                conversations.append(conversation)
                userNode["conversation"] = conversations
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingConversation(conversationId: conversationId, otherUserName: otherUserName, firstMessage: firstMessage, completion: completion)
                }
                
            } else {
                
                // User hasn't any conversation
                userNode["conversation"] = [
                    conversation
                ]
                
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationId: conversationId, otherUserName: otherUserName, firstMessage: firstMessage, completion: completion)
                }
            }
        }
    }
    
    private func finishCreatingConversation(conversationId: String, otherUserName: String, firstMessage: Message, completion: @escaping(Bool) -> Void){
        
//        "foewnfewnfon": {
//            "message": [
//                "id": String
//                "type": text, photo, video
//                "content": String
//                "date": Date
//                "sender_email": String
//                "is_read": Bool
//            ]
//
//        }
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
            
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "other_user_name": otherUserName,
            "sender_email": safeEmail,
            "is_read": false,
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.child("\(conversationId)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
        
        
    }
    
    /// Fetches and returns all conversations for the user with passed in email
    public func getAllConversations(for email: String, completion: @escaping(Result<[Conversation], Error>) -> Void){
        
        database.child("\(email)/conversation").observe(.value) { snapshot in
            
            if let singleValue = snapshot.value as? [String: Any] {
                
                guard let conversationId = singleValue["id"] as? String,
                      let otherUserName = singleValue["other_user_name"] as? String,
                      let otherUserEmail = singleValue["other_user_email"] as? String,
                      let latestMessage = singleValue["latest_message"] as? [String:Any],
                      let date = latestMessage["date"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool,
                      let message = latestMessage["latest_message"] as? String else {
                          return
                      }
                
                let latestMessageObject = LatestMessage(date: date,
                                                        isRead: isRead,
                                                        text: message)
                
                let conversation = Conversation(id: conversationId,
                                                otherUserEmail: otherUserEmail,
                                                otherUserName: otherUserName,
                                                latestMessage: latestMessageObject)
                
                var conversations = [Conversation]()
                conversations.append(conversation)
                completion(.success(conversations))
                
                      
            } else if let multipleValues = snapshot.value as? [[String: Any]] {
                
                let conversations: [Conversation] = multipleValues.compactMap { collection in
                    
                    guard let conversationId = collection["id"] as? String,
                          let otherUserName = collection["other_user_name"] as? String,
                          let otherUserEmail = collection["other_user_email"] as? String,
                          let latestMessage = collection["latest_message"] as? [String:Any],
                          let date = latestMessage["date"] as? String,
                          let isRead = latestMessage["is_read"] as? Bool,
                          let message = latestMessage["latest_message"] as? String else {
                              return nil
                          }
                    
                    let latestMessageObject = LatestMessage(date: date,
                                                            isRead: isRead,
                                                            text: message)
                    
                    return Conversation(id: conversationId,
                                        otherUserEmail: otherUserEmail,
                                        otherUserName: otherUserName,
                                        latestMessage: latestMessageObject)
                }
                
                completion(.success(conversations))
                
            } else {
                completion(.failure(FetchError.failedToFetchUsers))
            }
            
        }
        
    }
    
    /// Gets all messages for given conversation
    public func getAllMessagesFromConversation(with id: String, completion: @escaping(Result<[Message], Error>) -> Void){
        
        database.child("\(id)/messages").observe(.value) { snapshot in
            
            if let singleValue = snapshot.value as? [String: Any] {
                
                guard let content = singleValue["content"] as? String,
                      let dateString = singleValue["date"] as? String,
                      let id = singleValue["id"] as? String,
                      let isRead = singleValue["is_read"] as? Bool,
                      let otherUserName = singleValue["other_user_name"] as? String,
                      let senderEmail = singleValue["sender_email"] as? String,
                      let type = singleValue["type"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString)
                else {
                    return
                }
                
                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: otherUserName)
                    
                let singleMessage = Message(sender: sender,
                                            messageId: id,
                                            sentDate: date,
                                            kind: .text(content))
                
                
                var messages = [Message]()
                messages.append(singleMessage)
                completion(.success(messages))
                
                      
            } else if let multipleValues = snapshot.value as? [[String: Any]] {
                
                let messages: [Message] = multipleValues.compactMap { collection in
                    
                    guard let content = collection["content"] as? String,
                          let dateString = collection["date"] as? String,
                          let id = collection["id"] as? String,
                          let isRead = collection["is_read"] as? Bool,
                          let otherUserName = collection["other_user_name"] as? String,
                          let senderEmail = collection["sender_email"] as? String,
                          let type = collection["type"] as? String,
                          let date = ChatViewController.dateFormatter.date(from: dateString) else {
                              return nil
                          }
                    
                    let sender = Sender(photoURL: "",
                                        senderId: senderEmail,
                                        displayName: otherUserName)
                        
                    return Message(sender: sender,
                                   messageId: id,
                                   sentDate: date,
                                   kind: .text(content))
                }
                
                completion(.success(messages))
                
            } else {
                completion(.failure(FetchError.failedToFetchUsers))
            }
            
        }
        
    }
    
    /// Sends a message to target conversation 
    public func sendMessage(to conversation: String, message: Message, completion: @escaping(Bool) -> Void){
        
    }
    
}


