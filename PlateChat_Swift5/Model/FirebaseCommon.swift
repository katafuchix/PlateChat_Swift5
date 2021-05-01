//
//  FirebaseCommon.swift
//  PlateChat
//
//  Created by cano on 2018/08/26.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase

protocol Entity {
    var key: String! { get set } // TODO: リードオンリーにしたい
}

protocol WithFirestoreData: Entity, Decodable {
    associatedtype Fields
    init(key: String, fields: Fields)
    init(from: DocumentSnapshot) throws
}

extension WithFirestoreData {
    init(key: String, fields: Self) {
        self = fields
        self.key = key
    }

    init(from document: DocumentSnapshot) throws {
        let decoder = JSONDecoder()
        let data = try JSONSerialization.data(withJSONObject: document.data()!)
        let decoded = try decoder.decode(Self.self, from: data)

        self.init(key: document.documentID, fields: decoded)
    }
}

enum ModelError: Error {
    case parseError
}
