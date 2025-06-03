//
//  UserModel.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 01/06/2025.
//

import Foundation


enum Gender {
    case male, female, other
}

struct User {
    let userId: String
    let username: String
    let bio: String
    let name: String
    let profilePhoto: URL?
    let birthDate: Date
    let gender: Gender
    var counts: UserCount
    let joinDate: Date
    
}

struct UserCount {
    let followers: Int
    let following: Int
    var posts: Int
}
