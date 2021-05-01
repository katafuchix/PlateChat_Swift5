//
//  UIPlaceHolderTextView.swift
//  PlateChat
//
//  Created by cano on 2018/08/18.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

class UIPlaceHolderTextView: UITextView {


    lazy var placeHolderLabel:UILabel = UILabel()
    var placeHolderColor:UIColor      = UIColor.lightGray
    var placeHolder:NSString          = ""

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textChanged(_:)),
                                               name: UITextView.textDidChangeNotification,
                                                //NSNotification.Name.UITextView.textDidChangeNotification,
                                               object: nil)
    }

    func setText(text:NSString) {
        super.text = text as String?
        self.textChanged(nil)
    }

    override public func draw(_ rect: CGRect) {
        if(self.placeHolder.length > 0) {
            //self.placeHolderLabel.frame           = CGRect(8,8,self.bounds.size.width - 16,0)
            self.placeHolderLabel.lineBreakMode   = NSLineBreakMode.byWordWrapping
            self.placeHolderLabel.numberOfLines   = 0
            self.placeHolderLabel.font            = self.font
            self.placeHolderLabel.backgroundColor = UIColor.clear
            self.placeHolderLabel.textColor       = self.placeHolderColor
            self.placeHolderLabel.alpha           = 0
            self.placeHolderLabel.tag             = 999
            self.placeHolderLabel.text = self.placeHolder as String
            self.placeHolderLabel.sizeToFit()
            self.addSubview(placeHolderLabel)
        }

        self.sendSubviewToBack(placeHolderLabel)

        if(self.text.utf16.count == 0 && self.placeHolder.length > 0){
            self.viewWithTag(999)?.alpha = 1
        }

        super.draw(rect)
    }

    @objc func textChanged(_ notification:NSNotification?) -> (Void) {
        if(self.placeHolder.length == 0){
            return
        }

        if self.text.count == 0 {
            self.viewWithTag(999)?.alpha = 1
        } else {
            self.viewWithTag(999)?.alpha = 0
        }
    }

}
