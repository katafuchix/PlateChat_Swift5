//
//  UserSearchData.swift
//  PlateChat
//
//  Created by cano on 2018/09/22.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

struct UserSearchData {

    private enum DataType: String {
        case ageLower       = "search_ageLower"
        case ageUpper       = "search_ageUpper"
        case sex            = "search_sex"
        case prefecture_id  = "search_prefecture_id"
    }

    private static let ud = UserDefaults.standard

    init() {
        let ud = UserDefaults.standard
        ud.register(defaults: [
                                    UserSearchData.DataType.ageLower.rawValue : 18,
                                    UserSearchData.DataType.ageUpper.rawValue : 99,
                                    UserSearchData.DataType.sex.rawValue : 0,
                                    UserSearchData.DataType.prefecture_id.rawValue : 0,
                                    ])
        ud.synchronize()
    }

    static var ageLower: Int {
        get { return self.ud.integer(forKey: UserSearchData.DataType.ageLower.rawValue) }
        set { self.ud.set(newValue, forKey: UserSearchData.DataType.ageLower.rawValue); self.ud.synchronize() }
    }

    static var ageUpper: Int {
        get { return self.ud.integer(forKey: UserSearchData.DataType.ageUpper.rawValue) }
        set { self.ud.set(newValue, forKey: UserSearchData.DataType.ageUpper.rawValue); self.ud.synchronize() }
    }

    static var sex: Int {
        get { return self.ud.integer(forKey: UserSearchData.DataType.sex.rawValue) }
        set { self.ud.set(newValue, forKey: UserSearchData.DataType.sex.rawValue); self.ud.synchronize() }
    }

    static var prefecture_id: Int {
        get { return self.ud.integer(forKey: UserSearchData.DataType.prefecture_id.rawValue) }
        set { self.ud.set(newValue, forKey: UserSearchData.DataType.prefecture_id.rawValue); self.ud.synchronize() }
    }

}
