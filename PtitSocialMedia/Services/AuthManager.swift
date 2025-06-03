//
//  AuthManager.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import FirebaseAuth
import FirebaseFirestore

public class AuthManager {
    static let shared = AuthManager()
    
    
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
