//
//  StorageManager.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import FirebaseStorage

public class StorageManager {
    static let shared = StorageManager()
    
    private let bucket = Storage.storage().reference()
    
    //MARK: - Public
    public enum StorageManagerError: Error {
        case failToDownload
    }
    
    func uploadUserPost(model: UserPost, completion: (Result<URL, Error>) -> Void){
        
    }
    
    public func downloadImage(with reference: String, completion: @escaping(Result<URL, StorageManagerError>) -> Void){
        bucket.child(reference).downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(.failToDownload))
                return
            }
            completion(.success(url))
        }
    }
}
