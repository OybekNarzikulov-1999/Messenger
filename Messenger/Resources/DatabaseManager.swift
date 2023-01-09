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
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        
        self.database.child("users").observeSingleEvent(of: .value) { snapshot in
            if let _ = snapshot.value as? [String: String] {
                completion(.failure(FetchError.failedToFetchUsers))
            } else if let users = snapshot.value as? [[String: String]]{
                completion(.success(users))
            }
        }
        
    }
    
    public enum FetchError: Error {
        case failedToFetchUsers
    }
    
}

