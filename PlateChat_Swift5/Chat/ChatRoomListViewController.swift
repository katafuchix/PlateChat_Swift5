//
//  ChatRoomListViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/30.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import SVProgressHUD

class ChatRoomListViewController: UIViewController {

    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var chatRoomService: ChatRoomService?
    var chatRooms = [ChatRoom]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()
        self.tableView.tableHeaderView  = UIView()
        self.tableView.rowHeight = 80
        tableView.estimatedRowHeight = 80 // これはStoryBoardの設定で無視されるかも？
        //tableView.rowHeight = UITableViewAutomaticDimension

        self.refreshButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.observeChatRoomLIst()
        }).disposed(by: rx.disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.networkChecking()
        self.chatRoomService = ChatRoomService()
        self.observeChatRoomLIst()
    }

    func observeChatRoomLIst() {
        self.chatRoomService?.bindChatRoom(callbackHandler: { [weak self] (models, error) in
            switch error {
            case .none:
                if let models = models {
                    //let preMessageCount = self?.chatRooms.count
                    //self?.articles = models
                    self?.chatRooms = models + (self?.chatRooms)! //Array([models, self?.articles].joined()) // キャッシュのせいかたまに重複することがあるのでユニークにしておく
                    self?.chatRooms = (self?.chatRooms.unique { $0.key == $1.key }.filter {$0.last_update_message != "" }.sorted(by: { $0.updated_date > $1.updated_date}))!

                    self?.filterBlock()

                    //self?.chatRooms = (self?.chatRooms.filter{ [""].contains($0.key)})!
                    /*if preMessageCount == self?.chatRooms.count {  // 更新数チェック
                        //self?.refreshControl.endRefreshing()
                        return
                    }*/
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        //callbackHandler()
                    }
                }
            case .some(.error(let error)):
                Log.error(error!)
            case .some(.noExistsError):
                Log.error("データ見つかりません")
            }
        })
    }

    func filterBlock() {
        let blockUsers = Array(UsersData.userBlock.filter {$0.1 == true}.keys)
        let blockedUsers = Array(UsersData.userBlocked.filter {$0.1 == true}.keys)
        self.chatRooms = self.chatRooms
            .filter { !blockUsers.contains(Array($0.members.filter { $0.0 != AccountData.uid }.keys)[0]) }
            .filter { !blockedUsers.contains(Array($0.members.filter { $0.0 != AccountData.uid }.keys)[0]) }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - UITableViewDataSource

extension ChatRoomListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("self.chatRooms.count")
        //print(self.chatRooms.count)
        return self.chatRooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ChatRoomListCell.self, indexPath: indexPath)
        if self.chatRooms.count > 0 {
            let data = self.chatRooms[indexPath.row]
            cell.configure(data, indexPath)
        }
        /*cell.userProfileImageButton.rx.tap.asDriver().drive(onNext: { [unowned self] _ in
            let vc = R.storyboard.uderDetail.userDetailViewController()!
            let other_uid   = Array(self.chatRooms[indexPath.row].members.filter { $0.0 != AccountData.uid }.keys)[0]
            vc.uid = other_uid
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: cell.disposeBag)*/
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatRoomListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.chatRooms.count == 0 { return }
        let chatRoom = self.chatRooms[indexPath.row]

        // snapshotでコールバックが複数回実行されるのを回避
        let bool = self.navigationController?.topViewController is ChatMessageViewController
        if !bool {
            let vc = ChatMessageViewController()
            vc.chatRoom     = chatRoom
            let other_uid   = Array(chatRoom.members.filter { $0.0 != AccountData.uid }.keys)[0]
            vc.other_uid    = other_uid
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.tabBarItem.badgeValue = nil
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }


    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let block = UITableViewRowAction(style: .normal, title: "ブロック\nする") { (action, indexPath) in
            self.showAlertOKCancel("確認", "このユーザーをブロックしますか？", "はい", "いいえ") { _ in
                self.blockUser(indexPath)
            }
        }
        block.backgroundColor = UIColor.hexStr(hexStr: "#f44242", alpha: 1.0)
        /*
        let hide = UITableViewRowAction(style: .normal, title: "表示\nしない") { (action, indexPath) in
            //self.hideRoom(indexPath)
        }
        hide.backgroundColor = UIColor.hexStr(hexStr: "#999999", alpha: 1.0)
        */
        return [block]
    }

    // MARK: セル編集関数
    private func blockUser(_ indexPath: IndexPath) {
        SVProgressHUD.show(withStatus: "Loading...")

        let other_uid = Array(self.chatRooms[indexPath.row].members.filter {$0.0 != AccountData.uid}.keys)[0]

        UserBlockService.addBlockUser(other_uid, completionHandler: { [weak self] (_, error) in
            if let error = error {
                Log.error(error)
                SVProgressHUD.dismiss()
                return
            }
            UserBlockedService.addBlockedUser(other_uid, completionHandler: { [weak self] (_, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    Log.error(error)
                    return
                }
                self?.filterBlock()
                self?.tableView.reloadData()
            })
        })
    }

    // MARK: セル編集関数
    /*
    private func blockUser(_ indexPath: IndexPath) {
        guard let userId = self.messageList[indexPath.row].userId else { return }

        let unreadCnt: Int = self.messageList[indexPath.row].unreadCount ?? 0

        AnyRequest.createOutcommingBlock(userId) { [weak self] (result) in
            switch(result) {
            case .success:
                // ブロックリストAPI
                AccountData.updateBlockingUserList(refreshUnreadCount: true) { () in
                    self?.tableView.beginUpdates()
                    self?.messageList.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self?.updateHeaderView()
                    self?.tableView.endUpdates()

                    self?.updateTabBadgeValue(minusUnreadCount: unreadCnt)
                }

            case .failure(let error):
                self?.showAlert("エラー", error.description)
            }
        }

    }

    private func hideRoom(_ indexPath: IndexPath) {
        guard let roomId = self.messageList[indexPath.row].roomId else { return }

        let unreadCnt: Int = self.messageList[indexPath.row].unreadCount ?? 0
        let table = SqliteManager<HideRoomIdTable>.newTableInstance()
        var rec = HideRoomIdTableData()
        rec._roomId = roomId
        let _ = table.upsert(rec)
        tableView.beginUpdates()
        self.messageList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        self.updateHeaderView()
        tableView.endUpdates()

        self.updateTabBadgeValue(minusUnreadCount: unreadCnt)
    }

    func updateTabBadgeValue(unreadCount: Int) {
        guard let tabVC = AppDelegate.appDelegate?.window?.rootViewController as? TabBarController else { return }
        UIApplication.shared.applicationIconBadgeNumber = unreadCount
        tabVC.thirdVC?.isDotBadgeHidden = (unreadCount <= 0)
    }

    private func updateTabBadgeValue(minusUnreadCount: Int) {
        // バッジ数の更新
        guard minusUnreadCount > 0 else { return }
        guard let tabVC = AppDelegate.appDelegate?.window?.rootViewController as? TabBarController else { return }
        UIApplication.shared.applicationIconBadgeNumber -= minusUnreadCount
        if let tabBadge = Int(tabVC.thirdVC?.tabBarItem.badgeValue ?? "") {
            let val = tabBadge - minusUnreadCount
            tabVC.thirdVC?.isDotBadgeHidden = (val <= 0)
        }
    }
    */
}
