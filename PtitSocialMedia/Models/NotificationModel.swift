//
//  NotificationModel.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/05/2025.
//

import Foundation
import FirebaseCore
enum UserNotificationType {
    case like(post: UserPost)
    case follow(state: FollowState)
    //case comment()
}

struct UserNotification {
    let type: UserNotificationType
    let text: String
    let user: User
}


