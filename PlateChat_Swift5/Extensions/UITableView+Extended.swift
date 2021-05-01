//
//  UITableView+Extended.swift
//  PlateChat
//
//  Created by cano on 2018/08/31.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

extension UITableView {

    func registerNibCell<T: UITableViewCell>(_: T.Type) {
        self.register(UINib(nibName: T.nameOfClass, bundle: nil), forCellReuseIdentifier: T.nameOfClass)
    }

    func dequeueCell<T: UITableViewCell>(_: T.Type, indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.nameOfClass, for: indexPath) as! T
    }

    func setDefaultFooterView() {
        let footer = UIView(frame: CGRect.zero)
        footer.frame.size.width = self.frame.size.width
        footer.frame.size.height = 0.3
        footer.backgroundColor = self.separatorColor
        self.tableFooterView = footer
    }
}
