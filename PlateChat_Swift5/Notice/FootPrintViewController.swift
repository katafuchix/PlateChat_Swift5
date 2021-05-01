//
//  FootPrintViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/02.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SVProgressHUD
import Rswift
import XLPagerTabStrip

class FootPrintViewController: UIViewController, IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!
    var uids = [String]()
    var timeStamps = [Int]()
    var itemInfo: IndicatorInfo = "足あと"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()
        self.tableView.tableHeaderView  = UIView()
        self.tableView.rowHeight = 80
        self.tableView.estimatedRowHeight = 80
        self.tableView.register(R.nib.noticeTableViewCell)
        self.tableView.register(R.nib.footprintTableViewCell)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.networkChecking()
        self.observeFootprint()
    }

    func observeFootprint() {
        FootprintService.getFootprint(AccountData.uid!, completionHandler: { [weak self] (footprint, error) in
            if let footprint = footprint {
                self?.uids = []
                self?.timeStamps = []
                let tmp = footprint.history.sorted(by: { Int($0.0)! > Int($1.0)! }).prefix(50)
                tmp.forEach { (key, value) in
                    self?.uids.append(value)
                    self?.timeStamps.append(Int(key) ?? 0)
                }
                self?.tableView.reloadData()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - IndicatorInfoProvider

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

// MARK: - UITableViewDataSource

extension FootPrintViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.uids.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.footprintTableViewCell, for: indexPath)!
        if self.uids.count > 0 {
            let uid = self.uids[indexPath.row]
            let timeStamp = self.timeStamps[indexPath.row]
            cell.configure(uid, timeStamp)

            cell.profileImageButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
                let vc = R.storyboard.uderDetail.userDetailViewController()!
                vc.uid = uid
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: cell.disposeBag)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FootPrintViewController: UITableViewDelegate {

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

