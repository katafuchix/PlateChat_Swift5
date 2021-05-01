//
//  UsersData.swift
//  PlateChat
//
//  Created by cano on 2018/08/31.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import Firebase

struct UsersData {

    private enum DataType: String {
        case profileImages  = "profileImages"
        case nickNames      = "nickNames"
        case profileTexts   = "profileTexts"

        case genders        = "genders"
        case ages           = "ages"
        case prefecture_ids = "prefecture_ids"

        case userBlock      = "userBlock"
        case userBlocked    = "userBlocked"
    }

    private init() {}

    private static let ud = UserDefaults.standard

    static var profileImages: [String: String] {
        get { return self.ud.object(forKey: UsersData.DataType.profileImages.rawValue) as? [String: String] ?? [String: String]()}
        set { self.ud.set(newValue, forKey: UsersData.DataType.profileImages.rawValue); self.ud.synchronize() }
    }

    static var nickNames: [String: String] {
        get { return self.ud.object(forKey: UsersData.DataType.nickNames.rawValue) as? [String: String] ?? [String: String]()}
        set { self.ud.set(newValue, forKey: UsersData.DataType.nickNames.rawValue); self.ud.synchronize() }
    }

    static var profileTexts: [String: String] {
        get { return self.ud.object(forKey: UsersData.DataType.profileTexts.rawValue) as? [String: String] ?? [String: String]()}
        set { self.ud.set(newValue, forKey: UsersData.DataType.profileTexts.rawValue); self.ud.synchronize() }
    }

    static var genders: [String: Int] {
        get { return self.ud.object(forKey: UsersData.DataType.genders.rawValue) as? [String: Int] ?? [String: Int]()}
        set { self.ud.set(newValue, forKey: UsersData.DataType.genders.rawValue); self.ud.synchronize() }
    }

    static var ages: [String: Int] {
        get { return self.ud.object(forKey: UsersData.DataType.ages.rawValue) as? [String: Int] ?? [String: Int]()}
        set { self.ud.set(newValue, forKey: UsersData.DataType.ages.rawValue); self.ud.synchronize() }
    }

    static var prefecture_ids: [String: Int] {
        get { return self.ud.object(forKey: UsersData.DataType.prefecture_ids.rawValue) as? [String: Int] ?? [String: Int]()}
        set { self.ud.set(newValue, forKey: UsersData.DataType.prefecture_ids.rawValue); self.ud.synchronize() }
    }

    static var userBlock: [String: Bool] {
        get { return self.ud.object(forKey: UsersData.DataType.userBlock.rawValue) as? [String: Bool] ?? [String: Bool]()}
        set { self.ud.set(newValue, forKey: UsersData.DataType.userBlock.rawValue); self.ud.synchronize() }
    }

    static var userBlocked: [String: Bool] {
        get { return self.ud.object(forKey: UsersData.DataType.userBlocked.rawValue) as? [String: Bool] ?? [String: Bool]()}
        set { self.ud.set(newValue, forKey: UsersData.DataType.userBlocked.rawValue); self.ud.synchronize() }
    }
}
