//
//  ViewController+Extended.swift
//  PlateChat
//
//  Created by cano on 2018/08/13.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import SVProgressHUD
import RxSwift
import RxCocoa
import Reachability

private let indicatorViewTag = 100928

extension UIViewController {

    func showAlert(_ title: String, _ message: String? = nil, _ buttonTitle: String? = nil, completion: AlertCompletion? = nil) {
        let alert = Alert(title, message)
        _ = alert.addAction(buttonTitle ?? "OK", completion: completion)
        alert.show(self)
    }

    func showAlertOKCancel(
        _ title: String, _ message: String? = nil, _ buttonTitle: String? = nil, _ cancelbuttonTitle: String? = nil, completion: AlertCompletion? = nil

        ){
        let alert = Alert(title, message)
        _ = alert.addAction(buttonTitle ?? "OK", completion: completion)
        _ = alert.setCancelAction(cancelbuttonTitle ?? "Cancel", completion: nil)
        alert.show(self)
    }

    func showIndicatorView() {
        guard let indicatorView = R.nib.indicatorView.firstView(owner: nil) else { fatalError() }
        indicatorView.frame = view.bounds
        indicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicatorView.translatesAutoresizingMaskIntoConstraints = true
        indicatorView.tag = indicatorViewTag
        view.addSubview(indicatorView)
        view.bringSubviewToFront(indicatorView)
    }

    func hideIndicatorView() {
        if let indicatorView = view.viewWithTag(indicatorViewTag) {
            // TODO: トランジション追加
            indicatorView.removeFromSuperview()
        }
    }

    func showLoading(_ message: String? = nil) {
        //SVProgressHUD.setMinimumSize(CGSize(width: 200, height: 200))
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: message ?? "Loading...")
    }

    func hideLoading() {
        SVProgressHUD.dismiss()
    }
}

extension UIViewController {
    // Observable化したアクションシートの表示
    func showActionSheet<T>(title: String?, message: String?, cancelMessage: String = "キャンセル", actions: [ActionSheetAction<T>]) -> Observable<T> {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        return actionSheet.addAction(actions: actions, cancelMessage: cancelMessage, cancelAction: nil)
            .do(onSubscribed: { [weak self] in
                self?.present(actionSheet, animated: true, completion: nil)
            })
    }
}

extension UIViewController {
    func networkChecking()
    {
        // ネットワークに接続されていない場合
        let reachability = try! Reachability()
        
        //if !NetworkReachability.isReachable {
        reachability.whenUnreachable = { _ in
            self.showAlert("ネットワークに接続されていません")
            SVProgressHUD.dismiss()
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}


extension UIViewController {
    private final class StatusBarView: UIView { }

    func setStatusBarBackgroundColor() {
        for subView in self.view.subviews where subView is StatusBarView {
            subView.removeFromSuperview()
        }
        let statusBarView = StatusBarView()
        statusBarView.backgroundColor = R.color.main()!
        self.view.addSubview(statusBarView)
        statusBarView.translatesAutoresizingMaskIntoConstraints = false
        statusBarView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        statusBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        statusBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        statusBarView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    
    func setAppearance() {
        //UITabBar.appearance().barTintColor = UIColor.hexStr(hexStr: "#40e0d0", alpha: 1.0)
        //ナビゲーションアイテムの色を変更
        UINavigationBar.appearance().tintColor = UIColor.white
        //ナビゲーションバーの背景を変更
        UINavigationBar.appearance().barTintColor = R.color.main()! //UIColor.hexStr(hexStr: color as NSString, alpha: 1.0)
        //ナビゲーションのタイトル文字列の色を変更
        UINavigationBar.appearance().titleTextAttributes = [
            //NSAttributedString.Key.font: R.font.notoSansCJKjpSubBold(size: 15.0)!,
            .foregroundColor: UIColor.white]
        // remove bottom shadow
        UINavigationBar.appearance().shadowImage = UIImage()
        //UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationController.self]).tintColor = .white

        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = R.color.main()!
            appearance.titleTextAttributes = [
                //NSAttributedString.Key.font: R.font.notoSansCJKjpSubBold(size: 15.0)!,
                .foregroundColor: UIColor.white]
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        self.navigationController?.navigationBar.barTintColor = R.color.main()! // その他UIColor.white等好きな背景色
        // ナビゲーションバーのアイテムの色　（戻る　＜　とか　読み込みゲージとか）
        self.navigationController?.navigationBar.tintColor = .white
        // ナビゲーションバーのテキストを変更する
        self.navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.white
        ]
    }
}
