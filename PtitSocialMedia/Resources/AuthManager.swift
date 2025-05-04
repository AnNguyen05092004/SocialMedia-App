//
//  AuthManager.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import FirebaseAuth

public class AuthManager {
    static let shared = AuthManager()
    
    public func registerNewUser(userName: String, email: String, password: String, completion: @escaping(Bool) -> Void){
        /*
         - Check if username is available
         - Check if email is available
         */
        DatabaseManager.shared.canCreateNewUser(with: email, username: userName) { canCreate in
            // Create and insert account to database
            if canCreate {
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    guard error == nil, result != nil else {
                        completion(false)
                        return
                    }
                    // create account
                    DatabaseManager.shared.insertNewUser(with: email, username: userName) { inserted in
                        if inserted {
                            completion(true)
                            return
                        } else {
                            // failed to insert to db
                            completion(true)
                            return
                        }
                    }
                }
            } else {
                // either email or username is exist
                completion(false)
            }
        }
    }
    
    public func loginUser(userName: String?, email: String?, password: String, completion: @escaping ((Bool) -> Void)){ // escape to use completion in other closure
        if let email = email {
            // email login
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
            
        } else if let userName = userName {
            // username login
            print(userName)
            
        }
    }
    
    public func logOut(completion: (Bool) -> Void){
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        } catch {
            print(error)
            completion(false)
            return
        }
    }
}
