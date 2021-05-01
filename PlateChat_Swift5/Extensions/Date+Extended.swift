//
//  Date+Extended.swift
//  PlateChat
//
//  Created by cano on 2018/08/30.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate

extension DateFormatter {

    fileprivate static var defaultFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        return f
    }()

    func format(_ dateFormat: String) -> DateFormatter {
        self.dateFormat = dateFormat
        return self
    }
}

extension Date {

    fileprivate var defaultFormatter: DateFormatter {
        return DateFormatter.defaultFormatter
    }

    public static func timeAgoString(_ fromDate: Date) -> String {
        return Date().timeAgoString(fromDate)
    }

    public static func loginStatusImageNameString(_ fromDate: Date) -> String {
        return Date().loginStatusImageNameString(fromDate)
    }

    public func toString(_ format: String) -> String {
        return self.defaultFormatter.format(format).string(from: self)
    }

    public func toStringYYYY_MM_DD() -> String {
        return self.defaultFormatter.format("yyyy-MM-dd").string(from: self)
    }

    public func timeToJpYYMMDD() -> String {
        return self.defaultFormatter.format("yyyy年M月d日").string(from: self)
    }

    func timeToJpDayAndDayOfWeek() -> String {
        let weekdaySymbolIndex: Int = weekday - 1
        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja")
        return self.defaultFormatter.format("M/d ").string(from: self) + "(\(formatter.shortWeekdaySymbols[weekdaySymbolIndex]))"
    }

    public func hourAndMinites() -> String {
        return self.defaultFormatter.format("HH:mm").string(from: self)
    }

    public func timeAgoString(_ fromDate: Date) -> String {
        let interval = self.timeIntervalSince1970 - fromDate.timeIntervalSince1970

        switch interval {
        case 0..<60:
            return "たった今"
        case 60..<3_600:
            return "\(Int(interval / 60))分前"
        case 3600..<86_400:
            return "\(Int(Int(interval / 60) / 60))時間前"
        case 86400..<604_800:
            return "\(Int(Int(interval / 60) / 60 / 24))日前"
        case 604800..<2_678_400:
            return "\(Int(Int(interval / 60) / 60 / 24 / 7))週間前"
        case 2678400..<31_536_000:
            return "\(Int(interval / 60.0 / 60.0 / 24.0 / 30.4))ヶ月前"
        default:
            return "\(Int(Int(interval / 60) / 60 / 24 / 365))年前"
        }
    }

    func loginStatusImageNameString(_ fromDate: Date) -> String {
        let interval = self.timeIntervalSince1970 - fromDate.timeIntervalSince1970

        switch interval {
        case 0..<3600: // 1時間以内
            return "login_status_active"
        case 3600..<86400: // 1時間以上24時間以内
            return "login_status_24hrs"
        case 86400..<259200: // 24時間以上72時間以内
            return "login_status_3days"
        case 259200..<604800: // 72時間以上1週間以内
            return "login_status_1week"
        default: // 1週間以上
            return "login_status_inactive"
        }
    }

    func isNextDay(_ nextDay: Date) -> Bool {
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        var current = cal.dateComponents([.year, .month, .day], from: self)
        current.setValue((current.day ?? 0) + 1, for: .day)
        let next = cal.dateComponents([.year, .month, .day], from: nextDay)

        guard let cy = current.year, let cm = current.month, let cd = current.day else { return false }
        guard let ny = next.year, let nm = next.month, let nd = next.day else { return false }

        return cy == ny && cm == nm && cd == nd
    }

    func isToDay(_ aDay: Date) -> Bool {
        // TODO : 雑
        return self.timeToJpYYMMDD() == aDay.timeToJpYYMMDD()
    }
}

extension Date {

    public static func convertStringToDate(_ dateYYYYMMDD: String) -> Date? {
        return DateFormatter.defaultFormatter.format("yyyy-MM-dd").date(from: dateYYYYMMDD)
    }

    public static func convertStringToDate(dateYYYYMMDD_HHmmSS: String) -> Date? {
        return DateFormatter.defaultFormatter.format("yyyy-MM-dd HH:mm:SS").date(from: dateYYYYMMDD_HHmmSS)
    }

    public static func convertAPIRssponseStringToDate(_ string: String) -> Date? {
        return DateFormatter.defaultFormatter.format("yyyy-MM-dd'T'HH:mm:ss.SSSZ").date(from: string)
    }
}

