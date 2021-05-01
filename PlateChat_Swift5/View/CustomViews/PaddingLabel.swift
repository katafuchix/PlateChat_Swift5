//
//  PaddingLabel.swift
//  PlateChat
//
//  Created by cano on 2018/09/04.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {

    @IBInspectable var padding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

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
