//
//  UIWindow+Extended.swift
//  PlateChat
//
//  Created by cano on 2018/08/17.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

fileprivate var _windowStack: [UIWindow] = []

extension UIWindow {

    public static var windowStack: [UIWindow] {
        return _windowStack
    }

    public static func createNewWindow(_ rootViewController: UIViewController, _ windowLevel: Level = UIWindow.Level.alert) -> UIWindow {

        // デバイスサイズのUIWindowを生成
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.alpha = 0.0
        window.windowLevel = windowLevel
        window.rootViewController = rootViewController

        return window
    }

    public static func insertWindowStack(_ window: UIWindow, at index: Int) {
        guard let root = window.rootViewController else {
            return
        }
        window.alpha = 1.0
        root.view.frame.origin = CGPoint(x: 0, y: 0)
        window.addSubview(root.view)
        _windowStack.insert(window, at: index)
    }

    open func open(_ animation: ((_ window: UIWindow) -> Void)? = nil) {

        guard let root = rootViewController else {
            return
        }

        self.alpha = 0.0
        root.view.frame.origin = CGPoint(x: 0, y: 0)
        addSubview(root.view)

        let delegate = UIApplication.shared.delegate as! AppDelegate
        if _windowStack.count == 0 {
            _windowStack.append(delegate.window!)
        }

        let nowWindow = delegate.window
        nowWindow?.rootViewController?.viewWillDisappear(true)

        _windowStack.append(self)
        delegate.window = self
        self.makeKeyAndVisible()

        if let anim = animation {
            anim(self)
        } else {
            UIView.transition(with: self, duration: 0.4, options: [.transitionCrossDissolve, .curveLinear], animations:
                { () -> Void in
                    self.alpha = 1.0
                    self.transform = CGAffineTransform.identity

            }, completion: { (finished) in
                nowWindow?.rootViewController?.viewDidDisappear(true)
            })
        }
    }

    open func close(_ animation: ((_ window: UIWindow) -> Void)? = nil, completion: ((Bool) -> Swift.Void)? = nil) {
        guard let idx = _windowStack.index(of: self) else {
            return
        }

        if _windowStack.count <= 1 {
            return
        }

        let before = _windowStack[idx - 1]

        let delegate = UIApplication.shared.delegate as! AppDelegate

        _windowStack.remove(at: idx)

        if before == _windowStack.last {
            delegate.window = before
            before.rootViewController?.viewWillAppear(true)
        }

        if let anim = animation {
            anim(before)
        } else {
            UIView.transition(with: self, duration: 0.4, options: [.transitionCrossDissolve, .curveLinear], animations:
                { () -> Void in
                    self.alpha = 0.0
                    self.transform = CGAffineTransform.identity
            }, completion: { (finished) in
                self.rootViewController?.view.removeFromSuperview()
                self.removeFromSuperview()
                if before == _windowStack.last {
                    before.makeKeyAndVisible()
                    before.rootViewController?.viewDidAppear(true)
                }
                completion?(finished)
            })
        }
    }
}
