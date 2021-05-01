//
//  LoginUser.swift
//  PlateChat
//
//  Created by cano on 2018/08/07.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase

struct LoginUser {
    
    let key: String
    let email: String
    let password: String
    let login_email: String
    let login_password: String
    let nickname: String
    let sex: Int
    let prefecture_id: Int
    let age: Int
    let profile_text: String
    let profile_image_url: String
    let status: Int
    let notification_on: Bool
    let created_date: Date
    var updated_date: Date

    let notification_reply: Bool
    let notification_message: Bool
    let notification_footprint: Bool

    init(from document: DocumentSnapshot) throws {
        key = document.documentID

        guard
            let email   = document.get("email") as? String,
            let pass    = document.get("password") as? String,
            let status  = document.get("status") as? Int
            else { throw ModelError.parseError }

        self.email          = email
        self.password       = pass
        self.status         = status
        self.login_email    = (document.get("login_email") as? String) ?? ""
        self.login_password = (document.get("login_password") as? String) ?? ""
        self.nickname       = (document.get("nickname") as? String) ?? ""
        self.sex            = (document.get("sex") as? Int) ?? 0
        self.prefecture_id  = (document.get("prefecture_id") as? Int) ?? 0
        self.age            = (document.get("age") as? Int) ?? 0
        self.profile_text   = (document.get("profile_text") as? String) ?? ""
        self.profile_image_url = (document.get("profile_image_url") as? String) ?? ""

        self.notification_on = (document.get("notification_on") as? Bool) ?? true
        self.notification_reply      = (document.get("notification_reply") as? Bool) ?? true
        self.notification_message    = (document.get("notification_message") as? Bool) ?? true
        self.notification_footprint  = (document.get("notification_footprint") as? Bool) ?? true

        self.created_date   = (document.get("created_at") as? Timestamp)?.dateValue() ?? Date()
        self.updated_date   = (document.get("updated_at") as? Timestamp)?.dateValue() ?? Date()
    }
}
