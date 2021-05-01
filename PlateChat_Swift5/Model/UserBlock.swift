//
//  UserBlock.swift
//  PlateChat
//
//  Created by cano on 2018/09/01.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase

// 自分がブロックした
struct UserBlock {

    let key: String             // my uid
    let members: [String: Bool]

    init(from document: DocumentSnapshot) throws {
        self.key = document.documentID
        guard
            let members    = document.get("members") as? [String: Bool]
            else { throw ModelError.parseError }
        self.members        = members
    }
}

extension UserBlock: Equatable {
    static func == (lhs: UserBlock, rhs: UserBlock) -> Bool {
        return lhs.key == rhs.key
    }
}
