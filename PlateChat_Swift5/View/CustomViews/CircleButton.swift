//
//  CircleButton.swift
//  PlateChat
//
//  Created by cano on 2018/08/12.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

class CircleButton: UIButton {

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
