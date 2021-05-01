//
//  UnderlineTextField.swift
//  PlateChat
//
//  Created by cano on 2018/08/18.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UnderlineTextField: PaddingTextField {

    @IBInspectable var underlineHeight: CGFloat = 0
    @IBInspectable var underlineColor: UIColor?


    private var _underline: CALayer?

    override func awakeFromNib() {
        super.awakeFromNib()

        if let lineColor = underlineColor {
            setUnderline(lineColor, height: underlineHeight)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let lineColor = underlineColor {
            setUnderline(lineColor, height: underlineHeight)
        }
    }

    func setUnderline(_ color: UIColor, height: CGFloat? = nil) {
        let h = height ?? self.underlineHeight
        _underline?.removeFromSuperlayer()
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.bounds.height - h, width: self.bounds.width, height: h)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
        _underline = border
        underlineHeight = h
        underlineColor = color

        self._setInputAccessoryView()
    }

}

extension UnderlineTextField {

    func _setInputAccessoryView() {
        self.inputAccessoryView = self._generateInputAccessoryView()
    }

    // キーボード上部の完了ボタン
    func _generateInputAccessoryView() -> UIView {
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
