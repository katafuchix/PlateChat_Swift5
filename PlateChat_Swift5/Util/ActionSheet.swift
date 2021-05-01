//
//  ActionSheet.swift
//  PlateChat
//
//  Created by k.katafuchi on 2018/08/16.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import UIKit

public typealias ActionSheetCompletion = (() -> Void)

private struct ActionInfo {
    
    let type: UIAlertAction.Style
    let title: String
    let completion: ActionSheetCompletion?
    
    init(_ type: UIAlertAction.Style, _ title: String, _ completion: ActionSheetCompletion?) {
        self.type = type
        self.title = title
        self.completion = completion
    }
}

public final class ActionSheet {
    
    public let title: String?
    public let message: String?
    
    fileprivate var actionInfo: [ActionInfo] = []
    fileprivate var cancelInfo: ActionInfo?
    
    // MARK: - Initializer
    
    public init(title: String? = nil, message: String? = nil) {
        self.title = title
        self.message = message
    }
    
    // MARK: - Instance Functions
    
    @discardableResult func setCancelAction(_ title: String, completion: ActionSheetCompletion? = nil) -> ActionSheet {
        self.cancelInfo = ActionInfo(.cancel, title, completion)
        return self
    }
    
    @discardableResult func addAction(_ title: String, completion: ActionSheetCompletion?) -> ActionSheet {
        let ainfo = ActionInfo(.default, title, completion)
        self.actionInfo.append(ainfo)
        return self
    }
    
    @discardableResult func addDestructiveAction(_ title: String, completion: ActionSheetCompletion?) -> ActionSheet {
        let ainfo = ActionInfo(.destructive, title, completion)
        self.actionInfo.append(ainfo)
        return self
    }
    
    public func show(_ owner: UIViewController) {
        let alertController = UIAlertController(title: self.title, message: self.message, preferredStyle: .actionSheet)
        
        if let cancelInfo = self.cancelInfo {
            self.actionInfo.append(cancelInfo)
            self.cancelInfo = nil
        }
        
        self.actionInfo.forEach { info in
            let action = UIAlertAction(title: info.title, style: info.type) { _ in
                info.completion?()
            }
            alertController.addAction(action)
        }
        
        if self.actionInfo.count == 0 {
            let action = UIAlertAction(title: "キャンセル", style: .cancel) { _ in }
            alertController.addAction(action)
        }
        
        owner.present(alertController, animated: true, completion: nil)
    }
}
