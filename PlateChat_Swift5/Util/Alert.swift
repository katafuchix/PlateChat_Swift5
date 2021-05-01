//
//  Alert.swift
//  PlateChat
//
//  Created by k.katafuchi on 2018/08/16.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import UIKit

public typealias AlertCompletion = ((AlertResult) -> Void)

public enum AlertButtonType {
    case cancel(title: String)
    case other(title: String)
    case textField(text: String, placeholder: String?)
}

public enum AlertResult {
    case cancel
    case other(inputText: [String])
}

private struct AlertInfo {
    
    let type: AlertButtonType
    let completion: AlertCompletion?
    
    init(_ type: AlertButtonType, _ completion: AlertCompletion?) {
        self.type = type
        self.completion = completion
    }
}

public final class Alert {
    
    public let title: String
    public let message: String
    
    private var alertInfo: [AlertInfo] = []
    private var cancelInfo: AlertInfo?
    
    public init(_ title: String, _ message: String? = nil) {
        self.title = title
        self.message = message ?? ""
    }
    
    public func setCancelAction(_ buttonTitle: String = "Cancel", completion: AlertCompletion? = nil) -> Alert {
        self.cancelInfo = AlertInfo(.cancel(title: buttonTitle), completion)
        return self
    }
    
    public func addAction(_ buttonTitle: String, completion: AlertCompletion?) -> Alert {
        let alertInfo = AlertInfo(.other(title: buttonTitle), completion)
        self.alertInfo.append(alertInfo)
        return self
    }
    
    public func addTextField(_ text: String, _ placeholder: String?) -> Alert {
        let alertInfo = AlertInfo(.textField(text: text, placeholder: placeholder), nil)
        self.alertInfo.append(alertInfo)
        return self
    }
    
    public func show(_ owner: UIViewController?) {
        guard let owner = owner else { return }
        
        let alertController = UIAlertController(title: self.title, message: self.message, preferredStyle: .alert)
        
        if let cancelInfo = self.cancelInfo {
            self.alertInfo.append(cancelInfo)
            self.cancelInfo = nil
        }
        
        self.alertInfo.forEach { info in
            switch info.type {
            case .cancel(let buttonTitle):
                let action = UIAlertAction(title: buttonTitle, style: .cancel) { _ in
                    info.completion?(.cancel)
                }
                alertController.addAction(action)
            case .other(let buttonTitle):
                let action = UIAlertAction(title: buttonTitle, style: .default) { _ in
                    var inputText: [String] = []
                    alertController.textFields?.forEach {
                        inputText.append($0.text ?? "")
                    }
                    info.completion?(.other(inputText: inputText))
                }
                alertController.addAction(action)
            case .textField(let text, let placeholder):
                alertController.addTextField { textField in
                    textField.text = text
                    textField.placeholder = placeholder
                }
            }
        }
        
        if self.alertInfo.count == 0 {
            let action = UIAlertAction(title: "OK", style: .default) { _ in }
            alertController.addAction(action)
        }
        
        owner.present(alertController, animated: true, completion: {
            Log.debug("ALERT {\(self.title) + \(self.message)}")
        })
    }
}
