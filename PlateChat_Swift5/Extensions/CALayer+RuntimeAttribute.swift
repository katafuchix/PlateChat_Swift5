//
//  CALayer+RuntimeAttribute.swift
//  PlateChat
//
//  Created by cano on 2018/08/12.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

extension CALayer {
    func setBorderIBColor(color: UIColor!) -> Void{
        self.borderColor = color.cgColor
    }
}
