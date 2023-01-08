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
    
    public func insertUser(with user: ChatAppUser, completion: @escaping(Bool) -> Void){
        let userDict = ["first_name": user.firstName,
                        "last_name": user.lastName]
        
        database.child(user.safeEmail).setValue(userDict) { error, _ in
            guard error == nil else {
                print("failed to store data in firebase database")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
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
    
    public func safeEmail(emailAddress: String) -> String {
        var email = emailAddress.replacingOccurrences(of: ".", with: "-")
        email = email.replacingOccurrences(of: "@", with: "-")
        return email
    }
    
}

