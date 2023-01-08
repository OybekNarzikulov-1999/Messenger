//
//  StorageManager.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 07/01/23.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Upload picture to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.FailedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("failed to get downloaded url")
                    completion(.failure(StorageErrors.FailedToDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
//                print("downloaded url returned: \(urlString)")
                completion(.success(urlString))
                
            }
            
        }
    }
    
    public enum StorageErrors: Error {
        case FailedToUpload
        case FailedToDownloadURL
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL,Error>) -> Void) {
        
        self.storage.child(path).downloadURL { url, error in
            guard let url = url, error == nil else {
                print("Failed to download url from firebase storage")
                completion(.failure(StorageErrors.FailedToDownloadURL))
                return
            }
            completion(.success(url))
        }
        
    }
    
}
