//
//  PostModel.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 20/04/2025.
//

import Foundation

enum Gender {
    case male, female, other
}

struct User {
    let username: String
    let bio: String
    let name: (first: String, last: String)
    let profilePhoto: URL
    let birthDate: Date
    let gender: Gender
    let counts: UserCount
    let joinDate: Date
}

struct UserCount {
    let followers: Int
    let following: Int
    let posts: Int
}


public enum UserPostType: String {
    case photo = "Photo"
    case video = "Video"
}

// represent a user post
public struct UserPost {
    let identifier: String
    let postType: UserPostType
    let thumbnailImage: URL
    let postURL: URL // video or photo url
    let caption: String?
    let likeCount: [PostLike]
    let comments: [PostComment]
    let createdData: Date
    let taggedUsers: [String]
    let owner: User
}


struct PostLike {
    let username: String
    let postIndentifier: String
    
}

struct CommentLike {
    let username: String
    let commentIndentifier: String
    
}

struct PostComment {
    let identifier: String
    let username: String
    let text: String
    let createdDate: Date
    let like: [CommentLike]
}
