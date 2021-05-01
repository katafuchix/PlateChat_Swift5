//
//  BlockListViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/01.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SVProgressHUD

class BlockListViewController: UIViewController {

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    var chatRoomService: ChatRoomService?
    var uids = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()
        self.tableView.tableHeaderView  = UIView()
        self.tableView.rowHeight = 80
        tableView.estimatedRowHeight = 80 // これはStoryBoardの設定で無視されるかも？
        //tableView.rowHeight = UITableViewAutomaticDimension

        self.bind()
    }

    func bind() {
        self.backButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)

        self.refreshButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.observeBlockList()
        }).disposed(by: rx.disposeBag)

        self.observeBlockList()
    }

    func observeBlockList() {
        UserBlockService.getBlockUser(completionHandler: { [weak self] (userBlock, error) in
            if let error = error {
                Log.error(error)
                return
            }
            guard let userBlock = userBlock else { return }
            print(userBlock.members)
            print(userBlock.members.filter( { $0.1 == true }))
            self?.uids = Array(userBlock.members.filter( { $0.1 == true }).keys)
            self?.tableView.reloadData()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.networkChecking()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - UITableViewDataSource

extension BlockListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.uids.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(BlockListCell.self, indexPath: indexPath)
        if self.uids.count > 0 {
            let data = self.uids[indexPath.row]
            cell.configure(data)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension BlockListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        print(self.uids.count)
        /*
        if self.uids.count == 0 { return }
        let chatRoom = self.chatRooms[indexPath.row]
        let vc = ChatMessageViewController()
        vc.chatRoom     = chatRoom
        let other_uid   = Array(chatRoom.members.filter { $0.0 != AccountData.uid }.keys)[0]
        vc.other_uid    = other_uid
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        */
    }


    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let block = UITableViewRowAction(style: .normal, title: "ブロック\n解除") { (action, indexPath) in
            self.showAlertOKCancel("確認", "このユーザーのブロックを解除しますか？", "はい", "いいえ") { _ in
                self.blockUserRelease(indexPath)
            }
        }
        block.backgroundColor = UIColor.hexStr(hexStr: "#4286f4", alpha: 1.0)
        /*
         let hide = UITableViewRowAction(style: .normal, title: "表示\nしない") { (action, indexPath) in
         //self.hideRoom(indexPath)
         }
         hide.backgroundColor = UIColor.hexStr(hexStr: "#999999", alpha: 1.0)
         */
        return [block]
    }


    // MARK: セル編集関数
    private func blockUserRelease(_ indexPath: IndexPath) {
        SVProgressHUD.show(withStatus: "Loading...")
        
        let other_uid = self.uids[indexPath.row]

        UserBlockService.releaseBlockUser(other_uid, completionHandler: { [weak self] (_, error) in
            if let error = error {
                Log.error(error)
                SVProgressHUD.dismiss()
                return
            }
            UserBlockedService.releaseBlockedUser(other_uid, completionHandler: { [weak self] (_, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    Log.error(error)
                    return
                }
                //self?.observeBlockList()
                self?.uids = Array(UsersData.userBlock.filter( { $0.1 == true }).keys)
                self?.tableView.reloadData()
                return
            })
        })
    }
 }

