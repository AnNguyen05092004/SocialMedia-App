//
//  DatabaseManager.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import FirebaseFirestore

public class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let db = Firestore.firestore()
    
    // MARK: - Public

    /// Check if username is already taken
    public func canCreateNewUser(with email: String, username: String, completion: @escaping (Bool) -> Void) {
        let usersRef = db.collection("users")
        
        usersRef.whereField("username", isEqualTo: username).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error checking username: \(error)")
                completion(false)
            } else {
                completion(querySnapshot?.isEmpty == true)
            }
        }
    }

    /// Insert new user data to Firestore
//    public func insertNewUser(with email: String, username: String, completion: @escaping (Bool) -> Void) {
//        let usersRef = db.collection("users")
//        let documentID = email.safeDatabaseKey()
//
//        usersRef.document(documentID).setData([
//            "email": email,
//            "username": username,
//            "createdAt": FieldValue.serverTimestamp()
//        ]) { error in
//            if let error = error {
//                print("Error writing user to Firestore: \(error)")
//                completion(false)
//            } else {
//                completion(true)
//            }
//        }
//    }
    public func insertNewUser(userId: String,
                              username: String,
                              email: String,
                              completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        let userData: [String: Any] = [
            "userId": userId,
            "username": username,
            "email": email,
            "bio": "",
            "firstName": "",
            "lastName": "",
            "profilePhoto": "",
            "birthDate": Timestamp(date: Date()),
            "gender": "other",
            "followers": 0,
            "following": 0,
            "posts": 0,
            "joinDate": Timestamp(date: Date())
        ]
        
        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                print("❌ Failed to insert user: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User inserted to Firestore")
                completion(true)
            }
        }
    }

}
