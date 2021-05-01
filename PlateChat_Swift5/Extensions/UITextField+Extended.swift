//
//  UITextField+Extended.swift
//  PlateChat
//
//  Created by cano on 2018/08/17.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import NSObject_Rx

extension UITextField {

    func setInputAccessoryView() {
        self.inputAccessoryView = self.generateInputAccessoryView()
    }

    // キーボード上部の完了ボタン
    func generateInputAccessoryView() -> UIView {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:nil)
        //done.tintColor = R.color.orientalTheme.orientalGold()
        toolbar.setItems([flexible, done], animated: true)

        done.rx.tap.subscribe(onNext: { [unowned self] in
            self.resignFirstResponder()
        }).disposed(by: rx.disposeBag)

        return toolbar
    }
}
