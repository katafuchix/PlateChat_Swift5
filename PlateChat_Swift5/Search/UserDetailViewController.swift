//
//  UserDetailViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/23.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import MessageUI
import RxSwift
import RxCocoa
import NSObject_Rx
import Rswift
import SVProgressHUD
import SKPhotoBrowser

enum UserMenu {
    case block
    case report
}


class UserDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var articleService: ArticleService?
    var articles = [Article]()
    var uid: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.bind()
        
        FootprintService.addFootprint(self.uid!, completionHandler: { _ in })

        self.prepareButtons()

        if let nickName = UsersData.nickNames[self.uid!] {
            self.title = nickName
        }

        if AccountData.uid == self.uid {
            self.navigationItem.rightBarButtonItem?.image = UIImage()
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }

    }

    func bind() {
        self.tableView.register(R.nib.articleTableViewCell)
        self.tableView.register(R.nib.profileCell)
        self.tableView.register(R.nib.talkButtonTableViewCell)
        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()
        //tableView.estimatedRowHeight = 170 // これはStoryBoardの設定で無視されるかも？
        self.tableView.rowHeight = UITableView.automaticDimension

        self.articleService = ArticleService()
        self.articleService?.lastUidArticle = nil
        self.observeArticle()
        // ページング
        tableView.rx.willDisplayCell.subscribe(onNext: { [unowned self] (cell, indexPath) in
            if indexPath.section == 1 && self.isEndOfSections(indexPath) {
                self.observeArticle()
            }
        }).disposed(by: rx.disposeBag)

        guard let uid = uid else { return }
        UserService.getUserInfo(uid, completionHandler: { [unowned self] (user, error) in
            if let user = user {
                var dict = UsersData.profileImages
                dict[user.key] = user.profile_image_url
                UsersData.profileImages = dict

                dict = UsersData.nickNames
                dict[user.key] = user.nickname
                UsersData.nickNames = dict
                self.title = user.nickname

                dict = UsersData.profileTexts
                dict[user.key] = user.profile_text
                UsersData.profileTexts = dict

                var dict2 = UsersData.ages
                dict2[user.key] = user.age
                UsersData.ages = dict2

                dict2 = UsersData.genders
                dict2[user.key] = user.sex
                UsersData.genders = dict2

                dict2 = UsersData.prefecture_ids
                dict2[user.key] = user.prefecture_id
                UsersData.prefecture_ids = dict2

                self.tableView.reloadData()
            }
        })
    }

    func prepareButtons() {

        self.navigationItem.leftBarButtonItem?.rx.tap.asDriver().drive(onNext: { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)

        let actions = [ActionSheetAction<UserMenu>(title: "ブロック", actionType: .block,
                                                   style: .default),
                       ActionSheetAction<UserMenu>(title: "通報", actionType: .report,
                                                   style: .default)
        ]
        self.navigationItem.rightBarButtonItem?.rx.tap.asDriver().drive(onNext: { [unowned self] _ in
            self.showActionSheet(title: "", message: "Menu", actions: actions).subscribe({ [unowned self] event in
                if let sourceType = event.element {
                    switch sourceType {
                    case .block:
                        self.showAlertOKCancel("確認", "このユーザーをブロックしますか？", "はい", "いいえ") { _ in
                            self.blockUser(other_uid: self.uid!)
                        }
                    case .report:
                        self.reportUser(other_uid: self.uid!)
                    }
                }
            })
        }).disposed(by: rx.disposeBag)
    }

    private func blockUser(other_uid: String) {
        SVProgressHUD.show(withStatus: "Loading...")

        UserBlockService.addBlockUser(other_uid, completionHandler: { [unowned self] (_, error) in
            if let error = error {
                Log.error(error)
                SVProgressHUD.dismiss()
                return
            }
            UserBlockedService.addBlockedUser(other_uid, completionHandler: { [unowned self] (_, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    Log.error(error)
                    return
                }
                self.navigationController?.popViewController(animated: true)
            })
        })
    }

    func reportUser(other_uid: String) {
        if MFMailComposeViewController.canSendMail() {
            guard let nickName = UsersData.nickNames[other_uid] else { return }

            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([Constants.adminEmail]) // 宛先アドレス
            mail.setSubject("通報！") // 件名
            let body = "\(other_uid)\n\(nickName) さんに関する通報です。\n-------------------\n ＊この下に通報内容をお書きください。\n\n"
            mail.setMessageBody(body, isHTML: false) // 本文
            present(mail, animated: true, completion: nil)
        } else {
            print("送信できません")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.networkChecking()
        self.tableView.reloadData()
        self.observeArticle()
    }

    func observeArticle() {
        SVProgressHUD.show(withStatus: "Loading...")
        self.articleService?.bindUidArticle(self.uid!, callbackHandler: { [weak self] (models, error) in
            SVProgressHUD.dismiss()
            switch error {
            case .none:
                if let models = models {
                    let preMessageCount = self?.articles.count
                    self?.articles = models + (self?.articles)!
                    self?.articles = (self?.articles.unique { $0.key == $1.key }.filter {$0.status == 1 }.sorted(by: { $0.created_date > $1.created_date}))!
                    if preMessageCount == self?.articles.count {  // 更新数チェック
                        return
                    }
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            case .some(.error(let error)):
                Log.error(error!)
            case .some(.noExistsError):
                Log.error("データ見つかりません")
            }
        })
    }

    /// セクション配列・セクション内の末尾位置か調べる
    /// - return: Bool (true -> End of Sections and Rows)
    func isEndOfSections(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == self.articles.lastIndex
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UserDetailViewController : MFMailComposeViewControllerDelegate {
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

extension UserDetailViewController : UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return articles.count
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView .dequeueReusableCell(withIdentifier: String(describing: ArticleTableViewCell.self), for: indexPath) as! ArticleTableViewCell
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileCell, for: indexPath)!
            cell.configure(self.uid!)
            cell.profileImageButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
                if let image = cell.profileImageButton.backgroundImage(for: .normal) {
                    // SKPhotoBrowserを利用して別ウィンドウで開く
                    var images = [SKPhoto]()
                    let photo = SKPhoto.photoWithImage(image)
                    images.append(photo)
                    let browser = SKPhotoBrowser(photos: images)
                    browser.initializePageIndex(0)
                    self?.present(browser, animated: true, completion: {})
                }
            }).disposed(by: cell.disposeBag)

            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.width, bottom: 0, right: 0)
            return cell

        case 1:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.talkButtonTableViewCell, for: indexPath)!
            if self.uid == AccountData.uid {
                cell.talkButton.isEnabled = false
                //cell.talkButton.backgroundColor = UIColor.lightGray
                cell.talkButton.backgroundColor = UIColor.hexStr(hexStr: "#d1d6d5", alpha: 1.0)
            }
            cell.talkButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
                SVProgressHUD.show(withStatus: "Loading...")

                let chatRoomService = ChatRoomService()

                let vc = ChatMessageViewController()
                // ChatRoom 取得 なければ作成
                if let uid = self?.uid {
                    chatRoomService.cerateChatRoom(uid, { [weak self] (chatroom, error) in
                        SVProgressHUD.dismiss()
                        if let err = error {
                            self?.showAlert(err.localizedDescription)
                            return
                        }
                        guard let chatRoom = chatroom else { return }
                        // snapshotでコールバックが複数回実行されるのを回避
                        let bool = self?.navigationController?.topViewController is ChatMessageViewController
                        if !bool {
                            vc.chatRoom     = chatRoom
                            vc.other_uid    = uid
                            vc.hidesBottomBarWhenPushed = true
                            self?.navigationController?.pushViewController(vc, animated: true)
                        }
                    })
                }
            }).disposed(by: cell.disposeBag)
            
            return cell

        default:

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articleTableViewCell, for: indexPath)!
        //cell.set(content: datasource[indexPath.row])
        cell.configure(self.articles[indexPath.row])

        /*rx.tap.subscribe(onNext: { _ in
         print("ボタンを押しました！")
         }).disposed(by: rx.disposeBag)*/

        cell.talkButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            SVProgressHUD.show(withStatus: "Loading...")

            let chatRoomService = ChatRoomService()

            let vc = ChatMessageViewController()
            if let article = cell.article {
                // ChatRoom 取得 なければ作成
                chatRoomService.cerateChatRoom(article.uid, { [weak self] (chatroom, error) in
                    SVProgressHUD.dismiss()
                    if let err = error {
                        self?.showAlert(err.localizedDescription)
                        return
                    }
                    guard let chatRoom = chatroom else { return }

                    // snapshotでコールバックが複数回実行されるのを回避
                    let bool = self?.navigationController?.topViewController is ChatMessageViewController
                    if !bool {
                        vc.chatRoom     = chatRoom
                        vc.other_uid    = article.uid
                        vc.hidesBottomBarWhenPushed = true
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            }
        }).disposed(by: cell.disposeBag)

        cell.replyButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            let vc = R.storyboard.write.writeViewController()!
            vc.delegate = self
            vc.article = self?.articles[indexPath.row]
            //UIWindow.createNewWindow(vc).open()
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true, completion: nil)
        }).disposed(by: cell.disposeBag)

        return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = R.storyboard.article.articleListViewController()!
        let bool = self.navigationController?.topViewController is ArticleListViewController
        if !bool {
            vc.article = self.articles[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}

extension UserDetailViewController: writeVCprotocol {
    func close() {
        (UIApplication.shared.delegate as! AppDelegate).window?.close()
    }
}

