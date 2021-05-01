//
//  Log.swift
//  PlateChat
//
//  Created by k.katafuchi on 2018/08/16.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import os.log

final class Log {
    static var osLog: OSLog = {
        Bundle.main.bundleIdentifier != nil ? OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "MAIN") : OSLog.default
    }()

    public static func info(_ message: String, osLog: OSLog = osLog) {
        writeLog(message, osLog, .info)
    }

    public static func debug(_ message: String, osLog: OSLog = osLog) {
        writeLog(message, osLog, .debug)
    }

    public static func error(_ message: String, osLog: OSLog = osLog) {
        writeLog(message, osLog, .error)
    }

    public static func error(_ error: Error, osLog: OSLog = osLog) {
        writeLog(String(reflecting: error), osLog, .error)
    }
    
    public static func fault(_ message: String, osLog: OSLog = osLog) {
        writeLog(message, osLog, .fault)
    }

    private static func typeDescription(_ logType: OSLogType) -> String {
        if logType == .debug {
            return "DEBUG"
        } else if logType == .info {
            return "INFO"
        } else if logType == .error {
            return "ERROR"
        } else if logType == .fault {
            return "FAULT"
        } else {
            return ""
        }
    }
    
    private static func writeLog(_ message: String, _ osLog: OSLog, _ logType: OSLogType = .default) {
        os_log("[%@]%@", log: osLog, type: logType, typeDescription(logType), message)
    }
}
