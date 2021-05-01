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

        // 通知用処理
        self.notification.requestAuthorization()

        // パスコード画面表示状態のチェック用パラメータをリセット
        AccountData.isShowingPasscordLockView = false

        // パスコードロック画面オープン
        self.openPasscodeLock()

        // for ImagePicker
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }

        //キーボードの上の、next/prev/doneボタン
        IQKeyboardManager.shared.enable = true
        
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
        guard let rootVC = self.window?.rootViewController else { return }
        guard let tabVC = rootVC as? MainTabViewController else { return }
        if let tabItems = tabVC.tabBar.items {
            tabItems[2].badgeValue = value
        }
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

