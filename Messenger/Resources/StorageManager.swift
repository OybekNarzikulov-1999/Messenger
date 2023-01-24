//
//  StorageManager.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 07/01/23.
//

import Foundation
import FirebaseStorage

/// Get fetch and upload files to firebase storage
final class StorageManager {
    
    static let shared = StorageManager()
    
    /// Force to use shared
    private init() {}
    
    /// Reference to firebase storage
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Upload picture to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data, metadata: nil) { [weak self] metadata, error in
            guard error == nil else {
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.FailedToUpload))
                return
            }
            
            self?.storage.child("images/\(fileName)").downloadURL { url, error in
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
    
    ///  Upload image that will be sent in a conversation message
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("message_images/\(fileName)").putData(data, metadata: nil) { [weak self] metadata, error in
            guard error == nil else {
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.FailedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("failed to get downloaded url")
                    completion(.failure(StorageErrors.FailedToDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                completion(.success(urlString))
                
            }
            
        }
    }
    
    ///  Upload video that will be sent in a conversation message
    public func uploadMessageVideo(with url: URL, fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("message_videos/\(fileName)").putFile(from: url, metadata: nil) { [weak self] metadata, error in
            guard error == nil else {
                print("failed to upload file to firebase for picture")
                completion(.failure(StorageErrors.FailedToUpload))
                return
            }
            
            self?.storage.child("message_videos/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("failed to get downloaded url")
                    completion(.failure(StorageErrors.FailedToDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
    }
    
    public enum StorageErrors: Error {
        case FailedToUpload
        case FailedToDownloadURL
    }
    
    /// Downloads and returns image url for given path
    public func downloadURL(for path: String, completion: @escaping (Result<URL,Error>) -> Void) {
        
        storage.child(path).downloadURL { url, error in
            guard let url = url, error == nil else {
                print("Failed to download url from firebase storage")
                completion(.failure(StorageErrors.FailedToDownloadURL))
                return
            }
            completion(.success(url))
        }
        
    }
    
}
