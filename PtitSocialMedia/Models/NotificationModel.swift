//
//  NotificationModel.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/05/2025.
//

import Foundation
enum UserNotificationType {
    case like(post: UserPost)
    case follow(state: FollowState)
}

struct UserNotification {
    let type: UserNotificationType
    let text: String
    let user: User
}
