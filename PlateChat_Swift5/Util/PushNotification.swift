//
//  PushNotification.swift
//  PlateChat
//
//  Created by cano on 2018/08/28.
//  Copyright © 2018年 deskplate. All rights reserved.
//
// 参考：https://qiita.com/mshrwtnb/items/3135e931eedc97479bb5
// 通知用処理関連クラス
//

import Foundation
import UserNotifications
import Firebase
import SwiftMessages
//import Compass

class PushNotification: NSObject {  // Type 'PushNotification' does not conform to protocol 'NSObjectProtocol'

    override init() {
        super.init()

        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
        }

        // Firebase Cloud Message
        Messaging.messaging().delegate = self

        /*
        // Compass
        Navigator.scheme = "p-chat"
        Navigator.routes = ["chatroomlist"]
        Navigator.handle = { location in
            //let arguments = location.arguments

            // タブ画面をセットし直す
            let tabViewController = R.storyboard.main.mainTabViewController()!
            if let firstWindow = UIApplication.shared.windows.first {
                firstWindow.rootViewController = tabViewController
            } else {
                AppDelegate.appDelegate?.window?.rootViewController = tabViewController
            }
            // 通知内のpush-linkのパスで処理を分岐
            switch location.path {
            case "chatroomlist":    // chatroom一覧画面を表示
                tabViewController.selectedIndex = 2
            default:
                break
            }
        }
        */
    }

    func requestAuthorization(_ completion: ((Bool) -> Void)? = nil) {
        if #available(iOS 10.0, *) {
            // iOS 10
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { granted, error in
                if let error = error {
                    Log.debug(error.localizedDescription)
                    return
                }

                DispatchQueue.main.async(execute: {
                    if granted {
                        Log.debug("通知 許可")
                        center.delegate = self
                        UIApplication.shared.registerForRemoteNotifications()
                    } else {
                        Log.debug("通知 拒否")
                    }
                    completion?(granted)
                })
            })
        } else {
            // iOS 9
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
            completion?(false)
        }
    }

    // 通知受信後の処理
    func handlePushNotification(_ userInfo: [AnyHashable: Any], isBackground: Bool = false) {
        print("handlePushNotification")
        guard let linkHostURL = self.linkHost(userInfo) else { return }
        Log.debug("linkHostURL : \(linkHostURL)")
        do {
            //try Navigator.navigate(url: linkHostURL)
        } catch { }
    }

    // 通知のリンクを解析
    //  data: {
    //      push_link: 'firenze://massage', // などでPush通知受信後の処理
    //  },
    func linkHost(_ userInfo: [AnyHashable: Any]) -> URL? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil}
        // リンクをチェックしリダイレクト
        guard let pushLink = userInfo["push_link"] as? String else { return nil }
        guard let url = URL(string: pushLink) else { return nil }
        guard let scheme = url.scheme else { return nil }
        if scheme == "p-chat" || scheme == "http" || scheme == "https" {
            Log.debug("push_link : \(url)")
            return url
        }
        return nil
    }

    // 通知のタイトルを解析
    func linkTitle(_ userInfo: [AnyHashable: Any]) -> String? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        guard let title = userInfo["push_title"] as? String else { return nil }
        Log.debug("push_title : \(title)")
        return title
    }
}

@available(iOS 10.0, *)
extension PushNotification: UNUserNotificationCenterDelegate {

    // フォアグラウンドで通知受信
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {

        //let userInfo = notification.request.content.userInfo

        // Print full message.
        Log.debug("\(notification.request.content.userInfo)")

        //completionHandler([.alert, .sound])
        //self.handlePushNotification(userInfo)

        // ステータスバーの上だけに通知タイトルを表示
        let title: String = notification.request.content.title
        let status = MessageView.viewFromNib(layout: .statusLine)
        status.backgroundView.backgroundColor = UIColor.black
        status.bodyLabel?.textColor = UIColor.white
        status.configureContent(body: title)
        var statusConfig = SwiftMessages.defaultConfig
        statusConfig.presentationContext = .window(windowLevel: UIWindow.Level.statusBar.rawValue)
        SwiftMessages.show(config: statusConfig, view: status)

        let userInfo = notification.request.content.userInfo

        print(userInfo["aps"])
        //print(useInfo["aps"]!["badge"])
        if let aps = userInfo["aps"] as? [String:Any?]{
            if let badge = aps["badge"] as? Int {
                if badge == 0 { return }
                guard let linkHostUrl = self.linkHost(userInfo) else { return }
                switch linkHostUrl.host {
                case "chatroomlist":
                        AppDelegate.appDelegate?.showChatUnreadCount("\(badge)")
                default:
                    break
                }
            }
        }
    }

    // リモート通知の開封時に発火
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {

        let userInfo = response.notification.request.content.userInfo
        self.handlePushNotification(userInfo)
        // 通知内のURLによって処理を分ける
        // self.linkHost(userInfo), self.linkTitle(userInfo)
    }

    // バックグラウンドプッシュ通知受信
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        // アプリのバッジ数を+1
        let number = UIApplication.shared.applicationIconBadgeNumber
        UIApplication.shared.applicationIconBadgeNumber = number > 0 ? number + 1 : 1
    }

    // リモート通知 これは使わずにFirebaseのTokenを利用する
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //let deviceTokenString: String = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        //Log.debug("deviceTokenString \(deviceTokenString)")
    }

    // リモート通知を拒否したときの動作
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.debug("リモート通知の設定は拒否されました")
    }
}

extension PushNotification: MessagingDelegate {
    // FireBase側で通知送信に必要な端末識別子を取得 Firestoreに保存する必要あり
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        Log.debug("Firebase registration token: \(fcmToken)")
        AccountData.fcmToken = fcmToken
        UserService.setLastLogin()
    }

    // Firebase Cloud Message で送信した通知を受信した際の処理 おそらく使わない
    func applicationReceivedRemoteMessage(received remoteMessage: MessagingRemoteMessage) {
        Log.debug("\(remoteMessage.appData)")
    }
}
