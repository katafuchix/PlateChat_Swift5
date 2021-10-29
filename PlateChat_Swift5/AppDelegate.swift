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
import SVProgressHUD

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
        
        NetworkReachability.startListening()
        
        // Firebase
        if let options = FirebaseOptions(contentsOfFile: Constants.GoogleServiceInfoPlistPath) {
            FirebaseConfiguration.shared.setLoggerLevel(.min)
            FirebaseApp.configure(options: options)
            Crashlytics.crashlytics()
            
            // as? Timestamp
            let database = Firestore.firestore()
            let settings = database.settings
            settings.areTimestampsInSnapshotsEnabled = true
            // オフラインキャッシュ
            //settings.isPersistenceEnabled = false
            database.settings = settings
        }

        //UITabBar.appearance().barTintColor = UIColor.hexStr(hexStr: "#40e0d0", alpha: 1.0)
        //ナビゲーションアイテムの色を変更
        UINavigationBar.appearance().tintColor = UIColor.white
        //ナビゲーションバーの背景を変更
        UINavigationBar.appearance().barTintColor = UIColor.hexStr(hexStr: color as NSString, alpha: 1.0)
        //ナビゲーションのタイトル文字列の色を変更
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: R.font.notoSansCJKjpSubBold(size: 15.0)!,
            .foregroundColor: UIColor.white]
        // remove bottom shadow
        UINavigationBar.appearance().shadowImage = UIImage()
        //UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationController.self]).tintColor = .white

        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = R.color.main()!
            appearance.titleTextAttributes = [
                NSAttributedString.Key.font: R.font.notoSansCJKjpSubBold(size: 15.0)!,
                .foregroundColor: UIColor.white]
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        // 通知用処理
        self.notification.requestAuthorization()

        // パスコード画面表示状態のチェック用パラメータをリセット
        AccountData.isShowingPasscordLockView = false

        // for ImagePicker
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }

        // パスコードロック画面オープン
        //self.openPasscodeLock()
        
        //キーボードの上の、next/prev/doneボタン
        IQKeyboardManager.shared.enable = true
        
        SVProgressHUD.setOffsetFromCenter(
            UIOffset(horizontal: UIScreen.main.bounds.width/2,
                       vertical: UIScreen.main.bounds.height/2)
        )
        
        // iOS 13以降はデフォルトの処理が効かないのでこうする
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive(_:)), name: UIScene.willDeactivateNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIScene.didActivateNotification, object: nil)
        
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

    @objc func appWillResignActive(_ application: UIApplication) {
        //AccountData.refreshTokenData()
        
        // パスコード画面オープン
        openPasscodeLock()
    }
    
    @objc func appDidBecomeActive(_ application: UIApplication) {
        //AccountData.refreshTokenData()
        
        //バッチを消す
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Block
        if let uid = Auth.auth().currentUser?.uid {
            UserBlockService.syncBlockUser(completionHandler: { (_,_) in })
            UserBlockedService.syncBlockedUser(uid, completionHandler: { (_,_) in })
        }
    }
    
    // チャット一覧のバッヂ
    func showChatUnreadCount( _ value: String ) {
        guard let rootVC = self.window?.rootViewController else { return }
        guard let tabVC = rootVC as? MainTabViewController else { return }
        if let tabItems = tabVC.tabBar.items {
            tabItems[2].badgeValue = value
        }
    }

    func openPasscodeLock() {
        // パスコードが設定されていればパスコード画面を出す
        if let pass = AccountData.passcode, !pass.isEmpty, !AccountData.isShowingPasscordLockView {
            /*self.passcodeWindow = UIWindow.createNewWindow(
                R.storyboard.passcodeLock.passcodeLockViewController()!
            )
            self.passcodeWindow?.open()*/
            
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                // 現在のrootViewControllerにおいて一番上に表示されているViewControllerを取得する
                var topViewController: UIViewController = rootViewController
                while let presentedViewController = topViewController.presentedViewController {
                    topViewController = presentedViewController
                }

                // すでにパスコードロック画面がかぶせてあるかを確認する
                let isDisplayedPasscodeLock: Bool = topViewController.children.map{
                    return $0 is PasscodeLockViewController
                }.contains(true)

                // パスコードロック画面がかぶせてなければかぶせる
                if !isDisplayedPasscodeLock {
                    let nav = R.storyboard.passcodeLock.passcodeLockViewController()!
                    nav.modalPresentationStyle = .overFullScreen
                    nav.modalTransitionStyle   = .crossDissolve
                    topViewController.present(nav, animated: false, completion: nil)
                }
            }
        }

    }
}
