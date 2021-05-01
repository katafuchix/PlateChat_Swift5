//
//  PasscodeLockViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/26.
//  Copyright © 2018年 deskplate. All rights reserved.
//


import UIKit
import THPinViewController

fileprivate class CustomTHPinViewController: THPinViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.promptTitle = "パスコードを入力してください"
        self.promptColor = UIColor.white
        self.backgroundColor = UIColor.rgba(37, 36, 36)
        self.view.tintColor = UIColor.white
        self.disableCancel = true
        self.hideLetters = true

        // パスコード忘れた場合の待避ボタンを配置
        let button = UIButton()
        button.setTitle("パスコードを忘れた場合はアプリを再インストールしてください", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        button.sizeToFit()
        button.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height - 35)
        //button.addTarget(self, action: #selector(CustomTHPinViewController.pressForgotPasscodeButton(_:)), for: .touchUpInside)
        button.isEnabled = false
        self.view.addSubview(button)
        self.view.bringSubviewToFront(button)
    }

    @objc func pressForgotPasscodeButton(_ sender: UIButton) {
        // ウィンドウが1枚になるまでcloseし、最後にログイン画面に切り替える
        for (_, w) in UIWindow.windowStack.reversed().enumerated() {
            w.close({ window in
                w.alpha = 0.0
                w.rootViewController?.view.removeFromSuperview()
                w.removeFromSuperview()
                if window == UIWindow.windowStack.last {
                    // 起動時の画面をログイン画面に固定
                    //ApplicationConfigData.isLaunchToLoginVC = true
                    // ログアウト処理
                    //BaseViewController().logout()
                }
            })
        }
    }
}

class PasscodeLockViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        AccountData.isShowingPasscordLockView = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let _ = AccountData.passcode else {
            self.close()
            return
        }

        if AccountData.isShowingPasscordLockView {
            let vc = CustomTHPinViewController(delegate: self)
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)

        } else {
            self.close()
        }
    }

    private func close() {
        if let w = AppDelegate.appDelegate?.passcodeWindow {
            w.close()
            AccountData.isShowingPasscordLockView = false
            AppDelegate.appDelegate?.passcodeWindow = nil
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension PasscodeLockViewController: THPinViewControllerDelegate {

    func pinLength(for pinViewController: THPinViewController) -> UInt {
        return 4
    }

    func pinViewController(_ pinViewController: THPinViewController, isPinValid pin: String) -> Bool {
        guard pin == AccountData.passcode else {
            return false
        }

        AccountData.isShowingPasscordLockView = false
        return true
    }

    func userCanRetry(in pinViewController: THPinViewController) -> Bool {
        return true
    }
}

