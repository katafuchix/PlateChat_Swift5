//
//  UIColor+Extended.swift
//  matching
//
//  Created by james Lee on 2017/02/02.
//  Copyright © 2018 Re:Quest Co.,Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    var image: UIImage? {
        return self.generateImage(CGSize(width: 1, height: 1))
    }
    
    func generateImage(_ size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    static func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(
            red: (red < 0 ? 0 : red) / 255,
            green: (green < 0 ? 0 : green) / 255,
            blue: (blue < 0 ? 0 : blue) / 255,
            alpha: alpha < 0 ? 0 : alpha)
    }

    class func hexStr ( hexStr : NSString, alpha : CGFloat) -> UIColor {
        let hexStrValue = hexStr.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexStrValue as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string")
            return UIColor.white;
        }
    }

    // Change navigation bar bottom border color Swift
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width:1, height:1))
        let ctx = UIGraphicsGetCurrentContext()
        self.setFill()
        ctx!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
