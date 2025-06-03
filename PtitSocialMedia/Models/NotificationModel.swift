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
}

struct UserNotification {
    let type: UserNotificationType
    let text: String
    let user: User
}


//enum NotificationType: String {
//    case like
//    case follow
//}
//
//struct NotificationModel {
//    let id: String
//    let type: NotificationType
//    let fromUserId: String
//    let toUserId: String
//    let postId: String?
//    let timestamp: Date
//
//    // ✅ Custom initializer để bạn có thể khởi tạo bằng tham số
//    init(
//        id: String,
//        type: NotificationType,
//        fromUserId: String,
//        toUserId: String,
//        postId: String?,
//        timestamp: Date
//    ) {
//        self.id = id
//        self.type = type
//        self.fromUserId = fromUserId
//        self.toUserId = toUserId
//        self.postId = postId
//        self.timestamp = timestamp
//    }
//
//    // ✅ Init từ Firestore
//    init?(data: [String: Any]) {
//        guard
//            let id = data["id"] as? String,
//            let typeStr = data["type"] as? String,
//            let type = NotificationType(rawValue: typeStr),
//            let fromUserId = data["fromUserId"] as? String,
//            let toUserId = data["toUserId"] as? String,
//            let timestamp = data["timestamp"] as? Timestamp
//        else {
//            return nil
//        }
//
//        self.id = id
//        self.type = type
//        self.fromUserId = fromUserId
//        self.toUserId = toUserId
//        self.postId = data["postId"] as? String
//        self.timestamp = timestamp.dateValue()
//    }
//
//    func toDictionary() -> [String: Any] {
//        var dict: [String: Any] = [
//            "id": id,
//            "type": type.rawValue,
//            "fromUserId": fromUserId,
//            "toUserId": toUserId,
//            "timestamp": Timestamp(date: timestamp)
//        ]
//        if let postId = postId {
//            dict["postId"] = postId
//        }
//        return dict
//    }
//}
