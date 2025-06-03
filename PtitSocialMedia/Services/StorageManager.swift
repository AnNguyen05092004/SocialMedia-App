//
//  StorageManager.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 31/05/2025.
//
//completion: @escaping (Result<URL, Error>) -> Void là một closure thoát ra ngoài, giúp bạn nhận kết quả upload ảnh từ Firebase:
//.success(url) nếu upload thành công.
//.failure(error) nếu có lỗi xảy ra.

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage()

    private init() {}

    func uploadProfilePhoto(uid: String, imageData: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = storage.reference().child("profile_pictures/\(uid).jpg")
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            ref.downloadURL { url, error in
                if let url = url {
                    completion(.success(url))
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func uploadPostImage(data: Data, fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
            let ref = storage.reference().child("posts/\(fileName).jpg")

            ref.putData(data, metadata: nil) { _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                ref.downloadURL { url, error in
                    if let url = url {
                        completion(.success(url))
                    } else if let error = error {
                        completion(.failure(error))
                    }
                }
            }
        }
}




