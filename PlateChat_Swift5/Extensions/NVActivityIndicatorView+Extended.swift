//
//  NVActivityIndicatorView+Extended.swift
//  matching
//
//  Created by james Lee on 2017/03/28.
//  Copyright © 2018年 Re:Quest Co.,Ltd. All rights reserved.
//

import UIKit
/*
import NVActivityIndicatorView
import SVProgressHUD

extension NVActivityIndicatorView {
    
    public static func setup() {
        NVActivityIndicatorView.DEFAULT_TYPE = .ballClipRotate//.ballScaleMultiple
        NVActivityIndicatorView.DEFAULT_COLOR = UIColor.rgba(232, 118, 131)
        //SVProgressHUD.setDefaultStyle(.dark)
        //SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setBackgroundColor(.white)
        //SVProgressHUD.setMinimumDismissTimeInterval(0)
        SVProgressHUD.setMinimumDismissTimeInterval(2)
    }
    
    public static func show(message: String? = nil) {
        setup()
        let data = ActivityData(message: message)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(data, nil)
        SVProgressHUD.show()
    }
    
    public static func dismiss() {
        //NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        //self.hide()
        SVProgressHUD.dismiss()
    }
    
    public static func updateMessage(_ message: String?) {
        NVActivityIndicatorPresenter.sharedInstance.setMessage(message)
    }
    
    public static func showSuccess(message: String? = nil) {
        SVProgressHUD.showSuccess(withStatus: message)
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
    }
    
    public static func showError(message: String? = nil) {
        SVProgressHUD.showError(withStatus: message)
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
    }

    // FIXME: NVActivityIndicatorを強制的に閉じる。かなり強引！
    private static func hide() {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        for item in keyWindow.subviews
            where item.restorationIdentifier == "NVActivityIndicatorViewContainer" {
            item.removeFromSuperview()
        }
    }
}
*/
