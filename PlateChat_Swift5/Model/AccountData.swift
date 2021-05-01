//
//  AccountData.swift
//  PlateChat
//
//  Created by cano on 2018/08/12.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import Firebase

struct AccountData {

    private enum DataType: String {
        case isFirst        = "isFirst"
        case uid            = "uid"         // Auth.auth().currentUser?.uid
        case nickname       = "nickname"
        case email          = "email"
        case password       = "password"
        case login_email    = "login_email"
        case login_password = "login_password"
        case sex            = "sex"
        case prefecture_id  = "prefecture_id"
        case age            = "age"
        case profile_text   = "profile_text"
        case my_profile_image = "my_profile_image" // メイン画像
        case fcmToken       = "fcmToken" // firebase remote notification token
        case notification_on = "notification_on" // 通知設定
        case notification_reply = "notification_reply"
        case notification_message = "notification_message"
        case notification_footprint = "notification_footprint"

        case search_collection_is_grid = "search_collection_is_grid"
        case passcode = "passcode"
        case isShowingPasscordLockView = "isShowingPasscordLockView"
    }

    private init() {}

    private static let ud = UserDefaults.standard

    static var isFirst: Bool {
        get { return self.ud.bool(forKey: AccountData.DataType.isFirst.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.isFirst.rawValue); self.ud.synchronize() }
    }

    static var uid: String? {
        get { return Auth.auth().currentUser?.uid }
    }

    static var nickname: String? {
        get { return self.ud.string(forKey: AccountData.DataType.nickname.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.nickname.rawValue); self.ud.synchronize() }
    }

    static var login_email: String? {
        get { return self.ud.string(forKey: AccountData.DataType.login_email.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.login_email.rawValue); self.ud.synchronize() }
    }

    static var login_password: String? {
        get { return self.ud.string(forKey: AccountData.DataType.login_password.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.login_password.rawValue); self.ud.synchronize() }
    }

    static var sex: Int {
        get { return self.ud.integer(forKey: AccountData.DataType.sex.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.sex.rawValue); self.ud.synchronize() }
    }

    static var prefecture_id: Int {
        get { return self.ud.integer(forKey: AccountData.DataType.prefecture_id.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.prefecture_id.rawValue); self.ud.synchronize() }
    }

    static var age: Int {
        get { return self.ud.integer(forKey: AccountData.DataType.age.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.age.rawValue); self.ud.synchronize() }
    }

    static var profile_text: String? {
        get { return self.ud.string(forKey: AccountData.DataType.profile_text.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.profile_text.rawValue); self.ud.synchronize() }
    }

    // メイン画像
    static var my_profile_image: String? {
        get { return self.ud.string(forKey: AccountData.DataType.my_profile_image.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.my_profile_image.rawValue); self.ud.synchronize() }
    }

    static var fcmToken: String? {
        get { return self.ud.string(forKey: AccountData.DataType.fcmToken.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.fcmToken.rawValue); self.ud.synchronize() }
    }

    static var notification_on: Bool? {
        get { return self.ud.bool(forKey: AccountData.DataType.notification_on.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.notification_on.rawValue); self.ud.synchronize() }
    }

    static var notification_reply: Bool? {
        get { return self.ud.bool(forKey: AccountData.DataType.notification_reply.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.notification_reply.rawValue); self.ud.synchronize() }
    }

    static var notification_message: Bool? {
        get { return self.ud.bool(forKey: AccountData.DataType.notification_message.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.notification_message.rawValue); self.ud.synchronize() }
    }

    static var notification_footprint: Bool? {
        get { return self.ud.bool(forKey: AccountData.DataType.notification_footprint.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.notification_footprint.rawValue); self.ud.synchronize() }
    }

    static var search_collection_is_grid: Bool? {
        get { return self.ud.bool(forKey: AccountData.DataType.search_collection_is_grid.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.search_collection_is_grid.rawValue); self.ud.synchronize() }
    }

    static func setNewValueForKey(_ key: String, _ value: Any) {
        self.ud.set(value, forKey: key)
        self.ud.synchronize()
    }

    static var passcode: String? {
        get { return self.ud.string(forKey: AccountData.DataType.passcode.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.passcode.rawValue); self.ud.synchronize() }
    }

    static var isShowingPasscordLockView: Bool {
        get { return self.ud.bool(forKey: AccountData.DataType.isShowingPasscordLockView.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.isShowingPasscordLockView.rawValue); self.ud.synchronize() }
    }
}
