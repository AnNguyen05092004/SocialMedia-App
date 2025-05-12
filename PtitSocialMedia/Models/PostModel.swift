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
    var likeCount: [PostLike]
    let comments: [PostComment]
    let createdData: Date
    let taggedUsers: [String]
    let owner: User
}

struct PostLike {
    let userId: String
    let postIdentifier: String
}


struct PostComment {
    let identifier: String
    let username: String
    let text: String
    let createdDate: Date
    let like: [CommentLike]
}

struct CommentLike {
    let userId: String
    let commentIdentifier: String
}
