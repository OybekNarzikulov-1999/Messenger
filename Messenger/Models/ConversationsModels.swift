//
//  ConversationsModels.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 24/01/23.
//

import Foundation

struct Conversation {
    let id: String
    let otherUserEmail: String
    let otherUserName: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let isRead: Bool
    let text: String
}
