//
//  ChatRoom.swift
//  PlateChat
//
//  Created by cano on 2018/08/26.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase

class ChatRoom {

    let key: String
    let owner: String
    let members: [String: Bool]
    var unreadCounts: [String: Int]?
    let status: Int
    let created_date: Date
    var updated_date: Date
    var last_update_message: String?

    init(from document: DocumentSnapshot) throws {
        self.key = document.documentID

        guard
            let owner   = document.get("owner") as? String,
        let members    = document.get("members") as? [String: Bool],
            let status  = document.get("status") as? Int
            else { throw ModelError.parseError }
        self.owner          = owner
        self.members        = members
        self.unreadCounts   = (document.get("unreadCounts") as? [String: Int]) ?? ["": 0]
        self.status         = status
        self.created_date   = (document.get("created_at") as? Timestamp)?.dateValue() ?? Date()
        self.updated_date   = (document.get("updated_at") as? Timestamp)?.dateValue() ?? Date()
        self.last_update_message       = (document.get("last_update_message") as? String) ?? nil
    }
}

extension ChatRoom: Equatable {
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        return lhs.key == rhs.key &&
            lhs.members == rhs.members
    }
}

