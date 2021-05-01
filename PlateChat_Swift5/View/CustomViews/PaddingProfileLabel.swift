//
//  PaddingProfileLabel.swift
//  PlateChat
//
//  Created by cano on 2018/12/18.
//  Copyright © 2018 deskplate. All rights reserved.
//

import UIKit

class PaddingProfileLabel: UILabel {

    @IBInspectable var padding: UIEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

    override func drawText(in rect: CGRect) {
        let newRect = rect.inset(by: padding)
        super.drawText(in: newRect)
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        return contentSize
    }
}
