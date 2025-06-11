//
//  PostModel.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 20/04/2025.
//

import Foundation


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
    var comments: [PostComment]
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
    let postIdentifier: String   //  thêm dòng này
    let username: String
    let text: String
    let createdDate: Date
    let like: [CommentLike]
}

struct CommentLike {
    let userId: String
    let commentIdentifier: String
}
