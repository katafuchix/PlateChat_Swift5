//
//  MainTabViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/04.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SVProgressHUD
import Firebase

class MainTabViewController: UITabBarController, UITabBarControllerDelegate {

    fileprivate var dotBadges: [DotBadgeView] = []

    let color = "#7DD8C7"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.delegate = self
        self.tabBar.tintColor = UIColor.hexStr(hexStr: color as NSString, alpha: 1.0)
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.clipsToBounds = true
        //NVActivityIndicatorView.show(message: "loading...")
        SVProgressHUD.setDefaultStyle(.dark)
        
        print("Auth.auth().currentUser?.uid")
        print(Auth.auth().currentUser?.uid)
        print(Auth.auth().currentUser?.email)
        print(UserDeviceInfo.getDeviceInfo())
        
        if Auth.auth().currentUser?.uid == nil {
            AccountData.isFirst = true
            UserService.createUser(completionHandler: { (uid, _) in
                print(" create \(String(describing: uid))")
                UserService.setLastLogin()
            })
        }
        UserService.setLastLogin()
    }

    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        item.badgeValue = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 各タブにバッヂを配置 この時点ではhidden 通知が来たら表示する
        if dotBadges.count == 0 {
            addDotBadge(tabBar.subviews)
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        viewController.tabBarItem.badgeValue = nil
    }

    // 各タブに点灯するだけの小さいバッジアイコンをadd
    fileprivate func addDotBadge(_ subviews: [UIView]) {
        tabBar.items?.forEach {
            guard let view = $0.value(forKey: "view") as? UIView else { return }
            let dot = DotBadgeView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
            view.addSubview(dot)
            dotBadges.append(dot)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UITabBarController {

    var firstVC: UIViewController? {
        return self.viewControllers?.first
    }

    var secondVC: UIViewController? {
        if (self.viewControllers?.count ?? 0) < 2 { return nil }
        return self.viewControllers?[1]
    }

    var thirdVC: UIViewController? {
        if (self.viewControllers?.count ?? 0) < 3 { return nil }
        return self.viewControllers?[2]
    }

    var fourthVC: UIViewController? {
        if (self.viewControllers?.count ?? 0) < 4 { return nil }
        return self.viewControllers?[3]
    }

    var fifthVC: UIViewController? {
        if (self.viewControllers?.count ?? 0) < 5 { return nil }
        return self.viewControllers?[4]
    }

}
