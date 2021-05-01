//
//  CircleSexButton.swift
//  PlateChat
//
//  Created by cano on 2018/08/13.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

class CircleSexButton: UIButton {
/*
    @IBInspectable override var borderColor : UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }
*/
    @IBInspectable var selectedBorderColor : UIColor = UIColor.clear {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderColor = selectedBorderColor.cgColor
            } else {
                layer.borderColor = UIColor.clear.cgColor
            }
        }
    }

    override func draw(_ rect: CGRect) {
        // アスペクト比を合わせる
        self.contentMode = .scaleAspectFill
        self.imageView?.contentMode = .scaleAspectFit
        // 円形にマスク
        self.layer.cornerRadius = self.frame.size.width / 2.0
        self.layer.masksToBounds = true
        self.layoutIfNeeded()
    }

}
