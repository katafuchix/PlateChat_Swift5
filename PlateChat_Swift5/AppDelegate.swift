//
//  AppDelegate.swift
//  PlateChat_Swift5
//
//  Created by cano on 2021/05/01.
//

import UIKit
import Firebase
import FirebaseCrashlytics
import UserNotifications
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    var window: UIWindow?
    private let notification: PushNotification = PushNotification()
    //let color = "#40e0d0"
    let color = "#7DD8C7"

    open var passcodeWindow: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // チャット一覧のバッヂ
    func showChatUnreadCount( _ value: String ) {
        /*
        guard let rootVC = self.window?.rootViewController else { return }
        guard let tabVC = rootVC as? MainTabViewController else { return }
        if let tabItems = tabVC.tabBar.items {
            tabItems[2].badgeValue = value
        }
        */
    }

    func openPasscodeLock() {
        /*
        // パスコードが設定されていればパスコード画面を出す
        if let pass = AccountData.passcode, !pass.isEmpty, !AccountData.isShowingPasscordLockView {
            self.passcodeWindow = UIWindow.createNewWindow(
                R.storyboard.passcodeLock.passcodeLockViewController()!
            )
            self.passcodeWindow?.open()
        }
 */
    }
}

