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
    
    public func insertUser(with user: ChatAppUser){
        let userDict = ["first_name": user.firstName,
                        "last_name": user.lastName]
        
        guard let safeEmail = user.safeEmail else {return}
        database.child(safeEmail).setValue(userDict)
    }
    
    public func userExists(withEmail email: String, completion: @escaping((Bool) -> Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
}
