//
//  ArticleReplyLogViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/24.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SVProgressHUD
import Rswift
import XLPagerTabStrip

class ArticleReplyLogViewController: UIViewController, IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!
    var uids = [String]()
    var timeStamps = [Int]()
    var itemInfo: IndicatorInfo = "返信"

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
        self.observeArticleReplyLog()
        
        self.setStatusBarBackgroundColor()
        self.setAppearance()
    }

    func observeArticleReplyLog() {
        ArticleReplyLogService.getArticleReply(AccountData.uid!, completionHandler: { [weak self] (articleReplyLog, error) in
            if let articleReplyLog = articleReplyLog {
                self?.uids = []
                self?.timeStamps = []
                let tmp = articleReplyLog.history.sorted(by: { Int($0.0)! > Int($1.0)! }).prefix(50)
                tmp.forEach { (key, value) in
                    let split = value.components(separatedBy: ",")
                    self?.uids.append(split[0])
                    self?.timeStamps.append(Int(key) ?? 0)
                }
                self?.tableView.reloadData()
            }
        })
    }

    // MARK: - IndicatorInfoProvider

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

// MARK: - UITableViewDataSource

extension ArticleReplyLogViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.uids.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noticeTableViewCell, for: indexPath)!
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

extension ArticleReplyLogViewController: UITableViewDelegate {

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

}

