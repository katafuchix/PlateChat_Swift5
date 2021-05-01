//
//  SettingTableViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/04.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import MessageUI
import RxSwift
import RxCocoa
import NSObject_Rx
import Rswift
import SVProgressHUD

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var notificationSwitch: UISwitch!

    @IBOutlet weak var replyNotificationSwitch: UISwitch!
    @IBOutlet weak var messageNotificationSwitch: UISwitch!
    @IBOutlet weak var footprintNotificationSwitch: UISwitch!
    
    @IBOutlet weak var passcodeSwitch: UISwitch!

    var articleService: ArticleService?
    var chatRoomService: ChatRoomService?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()
        
        self.bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.networkChecking()
    }
    
    func bind(){
        closeButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)

        if let boolr = AccountData.notification_reply {
            replyNotificationSwitch.isOn = boolr
        }
        replyNotificationSwitch.rx.value.asDriver()
            .skip(1)
            .drive(onNext: {
                UserService.setNotification("notification_reply", $0)
            }).disposed(by: rx.disposeBag)

        if let boolm = AccountData.notification_message {
            messageNotificationSwitch.isOn = boolm
        }
        messageNotificationSwitch.rx.value.asDriver()
            .skip(1)
            .drive(onNext: {
                 UserService.setNotification("notification_message", $0)
            }).disposed(by: rx.disposeBag)

        if let boolf = AccountData.notification_footprint {
            footprintNotificationSwitch.isOn = boolf
        }
        footprintNotificationSwitch.rx.value.asDriver()
            .skip(1)
            .drive(onNext: {
                 UserService.setNotification("notification_footprint", $0)
            }).disposed(by: rx.disposeBag)
        /*
         if let bool = AccountData.notification_on {
         notificationSwitch.isOn = bool
         }
        notificationSwitch.rx.value.asDriver()
            .skip(1)
            .drive(onNext: {
                UserService.setNotificationON($0)
            }).disposed(by: rx.disposeBag)
        */
        // パスコード
        self.passcodeSwitch.isOn = !(AccountData.passcode ?? "").isEmpty
        passcodeSwitch.rx.value.asDriver()
            .skip(1)
            .drive(onNext: { [weak self] value in
                if value {
                    let nvc = R.storyboard.newPasscodeInput.newPasscodeNVC()!
                    nvc.modalPresentationStyle = .fullScreen
                    if let vc = nvc.viewControllers.first as? NewPasscodeInputViewController {
                        vc.delegate = vc
                        vc.parentNavigationController = nvc
                        vc.completion = { (isSuccess, pin) in
                            self?.passcodeSwitch.isOn = isSuccess
                            if !isSuccess {
                                return
                            }
                            self?.showAlert("設定が完了しました。")
                        }
                    }
                    self?.present(nvc, animated: true, completion: nil)
                } else {
                    AccountData.passcode = nil
                }
            }).disposed(by: rx.disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        print(indexPath)

        switch indexPath.row {
        // 0: ヘッダ
        case 1: // プロフィール設定
            let vc = R.storyboard.profile.profileEditTableViewController()!
            self.navigationController?.pushViewController(vc, animated: true)
        case 2: // ブロックリスト
            let vc = R.storyboard.blockList.blockListViewController()!
            self.navigationController?.pushViewController(vc, animated: true)
        case 3: // アカウントの保存とログイン
            let vc = R.storyboard.account.accountTableViewController()!
            self.navigationController?.pushViewController(vc, animated: true)
        // 返信通知設定
        // メッセージ通知設定
        // 足あと通知設定
        // パスコードロック
        // 詳細
        case 9: // 利用規約
            let vc = R.storyboard.rule.ruleViewController()!
            vc.hideCloseButton()
            self.navigationController?.pushViewController(vc, animated: true)
        case 10: // プライバシーポリシー
            //let vc = R.storyboard.privacy.privacyViewController()!
            //self.navigationController?.pushViewController(vc, animated: true)
            let vc = R.storyboard.privacyPoricy.privacyPoricyViewController()!
            self.navigationController?.pushViewController(vc, animated: true)
        case 11: // FAQ
            let vc = R.storyboard.faq.faqViewController()!
            self.navigationController?.pushViewController(vc, animated: true)
        case 12: // お問い合わせ
            self.contactUS()
        case 13: // アカウント削除
            self.deleteAccount()
        default:
            break
        }
    }

    func contactUS() {
        if MFMailComposeViewController.canSendMail() {
            guard let nickName = AccountData.nickname, let uid = AccountData.uid else { return }

            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([Constants.adminEmail]) // 宛先アドレス
            mail.setSubject("お問い合わせ") // 件名
            let body = "\(uid)\n\(nickName) さんからのお問い合わせです。\n-------------------\n ＊この下にお問い合わせ内容をお書きください。\n\n"
            mail.setMessageBody(body, isHTML: false) // 本文
            present(mail, animated: true, completion: nil)
        } else {
            print("送信できません")
        }
    }

    func deleteAccount() {
        Alert("確認", "アカウントを削除してよろしいですか？\nデータは全て削除されます。")
            .addAction("OK" , completion: { [unowned self] (AlertResult) in
                print(AlertResult)

                SVProgressHUD.show(withStatus: "Loading...")

                if let mainVC = self.presentingViewController as? MainTabViewController {
                    // home
                    if let nvc = mainVC.viewControllers?[0] as? UINavigationController {
                        if let vc = nvc.viewControllers[0] as? HomeViewController {
                            vc.articleService?.removeBindArticleList()
                            vc.articles = []
                            vc.articles_org = []
                        }
                    }
                    // チャットルーム
                    if let nvc = mainVC.viewControllers?[2] as? UINavigationController {
                        if let vc = nvc.viewControllers[0] as? ChatRoomListViewController {
                            vc.chatRoomService?.removeBindChatRoomList()
                            vc.chatRooms = []
                        }
                    }
                    // 自分の記事
                    if let nvc = mainVC.viewControllers?[4] as? UINavigationController {
                        if let vc = nvc.viewControllers[0] as? MyProfileViewController {
                            vc.articleService?.removeBindArticleList()
                            vc.articles = []
                        }
                    }
                }

                UserService.deleteLoginUser(completionHandler: { error in
                    if let err = error {
                        Log.error(err)
                        SVProgressHUD.dismiss()
                        self.showAlert("削除できませんでした", err.localizedDescription, "OK", completion: { _ in })
                        return
                    }
                    UserService.createUser(completionHandler: { (uid, _) in print(" create \(String(describing: uid))")
                        UserService.setLastLogin()
                        SVProgressHUD.dismiss()
                        self.showAlert("削除しました")
                    })
                })
            })
            .setCancelAction("キャンセル")
            .show(self)
    }
    /*
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SettingTableViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("キャンセル")
        case .saved:
            print("下書き保存")
        case .sent:
            print("送信成功")
            self.showAlert("送信しました")
        default:
            print("送信失敗")
        }
        dismiss(animated: true, completion: nil)
    }
}
