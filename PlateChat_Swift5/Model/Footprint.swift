//
//  Footprint.swift
//  PlateChat
//
//  Created by cano on 2018/09/23.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase

struct Footprint {

    let key: String             // other uid
    let history: [String: String]

    init(from document: DocumentSnapshot) throws {
        self.key = document.documentID
        guard
        let history    = document.get("history") as? [String : String]
            else { throw ModelError.parseError }
        self.history        = history
    }
}

extension Footprint: Equatable {
    static func == (lhs: Footprint, rhs: Footprint) -> Bool {
        return lhs.key == rhs.key
    }
}
