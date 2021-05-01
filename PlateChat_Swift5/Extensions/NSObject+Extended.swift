//
//  NSObject+Extended.swift
//  PlateChat
//
//  Created by cano on 2018/08/31.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation

extension NSObject {

    // @see : http://stackoverflow.com/questions/24107658/get-a-user-readable-version-of-the-class-name-in-swift-in-objc-nsstringfromclas

    static var nameOfClass: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }

    var nameOfClass: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}
