//
//  UserBlocked.swift
//  PlateChat
//
//  Created by cano on 2018/09/01.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase

// 相手からブロックされている
struct UserBlocked {

    let key: String             // other uid
    let members: [String: Bool]

    init(from document: DocumentSnapshot) throws {
        self.key = document.documentID
        guard
            let members    = document.get("members") as? [String: Bool]
            else { throw ModelError.parseError }
        self.members        = members
    }
}

extension UserBlocked: Equatable {
    static func == (lhs: UserBlocked, rhs: UserBlocked) -> Bool {
        return lhs.key == rhs.key
    }
}
