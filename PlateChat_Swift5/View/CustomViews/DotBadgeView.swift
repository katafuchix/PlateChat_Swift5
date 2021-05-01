//
//  DotBadgeView.swift
//  PlateChat
//
//  Created by cano on 2018/08/22.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

class DotBadgeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.red
        self.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        circle()
        guard let superview = self.superview else { return }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: bounds.height * 1.5),
            rightAnchor.constraint(equalTo: superview.rightAnchor, constant: bounds.width * -2),
            widthAnchor.constraint(equalToConstant: bounds.width),
            heightAnchor.constraint(equalToConstant: bounds.height)
            ])
    }

}
