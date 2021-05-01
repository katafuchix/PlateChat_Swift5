//
//  Constants.swift
//  PlateChat
//
//  Created by cano on 2018/08/05.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation

struct Constants {
    /// 開発版モード
    /// - Budle ID: 開発版
    /// - API接続先: 開発環境
    ///
    static var DEBUG: Bool {
        #if DEBUG || PAYMENT
        // DEBUG、PAYMENTが定義されていたら開発モード
        return true
        #else
        return false
        #endif
    }

    /// 課金試験モード
    /// - Budle ID: 製品版
    /// - API接続先: 開発環境
    ///
    static var PAYMENT: Bool {
        #if PAYMENT
        // PAYMENTが定義済みの場合のみ、課金試験モード
        return true
        #else
        return false
        #endif
    }

    /// 製品版モード
    /// - Budle ID: 製品版
    /// - API接続先: 本番環境
    ///
    static var PRODUCTION: Bool {
        #if PRODUCTION
        // PRODUCTIONが定義済みの場合のみ製品版モード
        return true
        #else
        return false
        #endif
    }

    static let adminEmail = "info@p-chat.net"

    /**
     GoogleService-Info.plist path
     */
    static var GoogleServiceInfoPlistPath: String {
        print("Constants.DEBUG")
        print(Constants.DEBUG)
        print("Constants.PRODUCTION")
        print(Constants.PRODUCTION)
        if Constants.DEBUG {
            return Bundle.main.path(forResource: "GoogleService-Info-dev", ofType: "plist")!
        } else {
            return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
        }
    }
    static let genders = ["未設定", "男性", "女性"]

    static let prefs: [Int: String] = [
        0: "未設定",
        1: "東京都",
        2: "神奈川県",
        3: "埼玉県",
        4: "千葉県",
        5: "大阪府",
        6: "京都府",
        7: "兵庫県",
        8: "奈良県",
        9: "愛知県",
        10: "岐阜県",
        11: "三重県",
        12: "福岡県",
        13: "北海道",
        14: "青森県",
        15: "岩手県",
        16: "宮城県",
        17: "秋田県",
        18: "山形県",
        19: "福島県",
        20: "茨城県",
        21: "栃木県",
        22: "群馬県",
        23: "新潟県",
        24: "富山県",
        25: "石川県",
        26: "福井県",
        27: "山梨県",
        28: "長野県",
        29: "静岡県",
        30: "滋賀県",
        31: "和歌山県",
        32: "鳥取県",
        33: "島根県",
        34: "岡山県",
        35: "広島県",
        36: "山口県",
        37: "徳島県",
        38: "香川県",
        39: "愛媛県",
        40: "高知県",
        41: "佐賀県",
        42: "長崎県",
        43: "熊本県",
        44: "大分県",
        45: "宮崎県",
        46: "鹿児島県",
        47: "沖縄県",
        48: "海外"
    ]

    static let ages: [Int: String] = [
            0: "未設定",
            /*1: "1",
            2: "2",
            3: "3",
            4: "4",
            5: "5",
            6: "6",
            7: "7",
            8: "8",
            9: "9",
            10: "10",
            11: "11",
            12: "12",
            13: "13",
            14: "14",
            15: "15",
            16: "16",
            17: "17",*/
            18: "18",
            19: "19",
            20: "20",
            21: "21",
            22: "22",
            23: "23",
            24: "24",
            25: "25",
            26: "26",
            27: "27",
            28: "28",
            29: "29",
            30: "30",
            31: "31",
            32: "32",
            33: "33",
            34: "34",
            35: "35",
            36: "36",
            37: "37",
            38: "38",
            39: "39",
            40: "40",
            41: "41",
            42: "42",
            43: "43",
            44: "44",
            45: "45",
            46: "46",
            47: "47",
            48: "48",
            49: "49",
            50: "50",
            51: "51",
            52: "52",
            53: "53",
            54: "54",
            55: "55",
            56: "56",
            57: "57",
            58: "58",
            59: "59",
            60: "60",
            61: "61",
            62: "62",
            63: "63",
            64: "64",
            65: "65",
            66: "66",
            67: "67",
            68: "68",
            69: "69",
            70: "70",
            71: "71",
            72: "72",
            73: "73",
            74: "74",
            75: "75",
            76: "76",
            77: "77",
            78: "78",
            79: "79",
            80: "80",
            81: "81",
            82: "82",
            83: "83",
            84: "84",
            85: "85",
            86: "86",
            87: "87",
            88: "88",
            89: "89",
            90: "90",
            91: "91",
            92: "92",
            93: "93",
            94: "94",
            95: "95",
            96: "96",
            97: "97",
            98: "98",
            99: "99"
    ]
}
