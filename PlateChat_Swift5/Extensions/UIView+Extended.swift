//
//  UIView+Extended.swift
//  PlateChat
//
//  Created by cano on 2018/08/12.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

extension UIView {

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    // 円形にするメソッド
    func circle() {
        self.forcingLayout()
        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.size.width * 0.5
    }

    func forcingLayout() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
