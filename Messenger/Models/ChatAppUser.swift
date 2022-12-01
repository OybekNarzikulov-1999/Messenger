//
//  ChatAppUser.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 01/12/22.
//

import UIKit


struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String? {
        var email = emailAddress.replacingOccurrences(of: ".", with: "-")
        email = email.replacingOccurrences(of: "@", with: "-")
        return email
    }
}
