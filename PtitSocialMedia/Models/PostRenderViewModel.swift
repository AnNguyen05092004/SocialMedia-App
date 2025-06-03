//
//  PostRenderViewModel.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 01/06/2025.
//

import Foundation

/// States of a rendered cell
enum PostRenderType {
    case header(provider: User)
    case primaryContent(provider: UserPost) //post
    case action(provider: String) // Like, comment, share
    case comments(comments: [PostComment])
}

/// Model of rendered Post
struct PostRenderViewModel {
    let renderType: PostRenderType
}
