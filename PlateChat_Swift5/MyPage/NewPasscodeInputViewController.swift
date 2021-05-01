//
//  NewPasscodeInputViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/26.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import THPinViewController
//import FontAwesome

fileprivate protocol NewPasscodeInputProtocol {

    var passcodeLength: UInt { get }
    var parentNavigationController: UINavigationController? { get set }
    var completion: ((Bool, String?) -> Void)? { get set }
    func setupComponents()
    func pressCloseButton(_ sender: UIButton)
}

fileprivate extension NewPasscodeInputProtocol where Self: THPinViewController {

    var passcodeLength: UInt { return 4 }

    func setupComponents() {
        self.promptColor = UIColor.white
        self.backgroundColor = UIColor.rgba(37, 36, 36)
        self.view.tintColor = UIColor.white
        self.disableCancel = true
        self.hideLetters = true

        let closeButton = UIButton(frame: CGRect(x: 12, y: 24, width: 40, height: 40))
        let image = UIImage(named: "x")?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(image, for: .normal)
        //closeButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        closeButton.addTarget(self, action: #selector(NewPasscodeInputViewController.pressCloseButton(_:)), for: .touchUpInside)
        self.view.addSubview(closeButton)
    }
}

// MARK: -

class NewPasscodeInputViewController: THPinViewController, NewPasscodeInputProtocol, THPinViewControllerDelegate {

    var parentNavigationController: UINavigationController?
    var completion: ((Bool, String?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupComponents()
        self.promptTitle = "パスコードを入力してください"
    }

    @objc func pressCloseButton(_ sender: UIButton) {
        self.parentNavigationController?.dismiss(animated: true) {
            self.completion?(false, nil)
        }
    }

    func pinLength(for pinViewController: THPinViewController) -> UInt {
        return self.passcodeLength
    }

    func pinViewController(_ pinViewController: THPinViewController, isPinValid pin: String) -> Bool {
        let vc = ConfirmNewPasscodeInputViewController()
        vc.delegate = vc
        vc.parentNavigationController = self.parentNavigationController
        vc.inputPasscode = pin
        vc.completion = self.completion
        self.parentNavigationController?.pushViewController(vc, animated: false)

        return true
    }

    func pinViewControllerDidDismiss(afterPinEntryWasCancelled pinViewController: THPinViewController) {
        self.completion?(false, nil)
    }

    func userCanRetry(in pinViewController: THPinViewController) -> Bool {
        return true
    }
}

// MARK: -

class ConfirmNewPasscodeInputViewController: THPinViewController, NewPasscodeInputProtocol, THPinViewControllerDelegate {

    fileprivate var parentNavigationController: UINavigationController?
    fileprivate var inputPasscode = ""
    fileprivate var completion: ((Bool, String?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupComponents()
        self.promptTitle = "確認のため再入力してください"
    }

    @objc func pressCloseButton(_ sender: UIButton) {
        self.parentNavigationController?.dismiss(animated: true) {
            self.completion?(false, nil)
        }
    }

    func pinLength(for pinViewController: THPinViewController) -> UInt {
        return self.passcodeLength
    }

    func pinViewController(_ pinViewController: THPinViewController, isPinValid pin: String) -> Bool {
        guard pin == self.inputPasscode else {
            return false
        }
        AccountData.passcode = inputPasscode

        return true
    }

    func pinViewControllerDidDismiss(afterPinEntryWasSuccessful pinViewController: THPinViewController) {
        self.completion?(true, inputPasscode)
    }

    func pinViewControllerDidDismiss(afterPinEntryWasCancelled pinViewController: THPinViewController) {
        self.completion?(false, nil)
    }

    func userCanRetry(in pinViewController: THPinViewController) -> Bool {
        return true
    }
}

