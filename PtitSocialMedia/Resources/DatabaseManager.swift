//
//  DatabaseManager.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import FirebaseDatabase

public class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    //MARK: - Public
    /// check if username and email are available
    public func canCreateNewUser(with email: String, username: String, completion: (Bool) -> Void){
        completion(true)
    }
    
    /// Insert new user data to database
    public func insertNewUser(with email: String, username: String, completion: @escaping(Bool) -> Void) {
        database.child(email.safeDatabaseKey()).setValue(["username": username]) { error, _ in // tạo 1 node con =email và setvalue
            if error == nil {
                // succeeded
                completion(true)
                return
            } else {
                // failed
                completion(false)
                return
            }
        }
    }
    
    
}
