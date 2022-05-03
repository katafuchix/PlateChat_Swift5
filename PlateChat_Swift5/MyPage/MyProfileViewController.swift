//
//  MyProfileViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/04.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Rswift
import SVProgressHUD
import SKPhotoBrowser
import GoogleMobileAds

class MyProfileViewController: UIViewController {

    @IBOutlet weak var settingBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adBaseView: UIView!
    
    var articleService: ArticleService?
    var articles = [Article]()

    let IMOBILE_BANNER_PID = "4323"
    let IMOBILE_BANNER_MID = "494993"
    let IMOBILE_BANNER_SID = "1766255"
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.bind()
        
        /*
        // スポット情報を設定します
        ImobileSdkAds.register(withPublisherID: IMOBILE_BANNER_PID, mediaID:IMOBILE_BANNER_MID, spotID:IMOBILE_BANNER_SID)
        // 広告の取得を開始します
        ImobileSdkAds.start(bySpotID: IMOBILE_BANNER_SID)
        
        // 表示する広告のサイズ
        let imobileAdSize = CGSize(width: 320, height: 50)
        // デバイスの画面サイズ
        let screenSize = UIScreen.main.bounds.size
        
        // 広告の表示位置を算出(画面中央下)
        let imobileAdPosX: CGFloat = (screenSize.width - imobileAdSize.width) / 2

        // 広告を表示するViewを作成します
        let imobileAdView = UIView(frame: CGRect(x: imobileAdPosX, y: 0, width: imobileAdSize.width, height: imobileAdSize.height))
        //imobileAdView.backgroundColor = .red
        //広告を表示するViewをViewControllerに追加します
        self.adBaseView.addSubview(imobileAdView)
        // 広告を表示します
        ImobileSdkAds.show(bySpotID: IMOBILE_BANNER_SID, view: imobileAdView)
        */
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)

        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-3442728876051584/4432732667"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }

    func addBannerViewToView(_ bannerView: GADBannerView) {
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(bannerView)
        view.addConstraints([          // 生成した制約を設定する
                NSLayoutConstraint(
                        item: bannerView,
                        attribute: .centerX,
                        relatedBy: .equal,
                        toItem: view,
                        attribute: .centerX,
                        multiplier: 1.0,
                        constant: 0.0
                ),
                NSLayoutConstraint(
                        item: bannerView,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: self.tableView,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: 0.0
                )
        ])
     }
    
    func bind() {
        settingBarButton.rx.tap.subscribe(onNext: { [unowned self] in
            guard let vc = R.storyboard.myPage.settingNVC() else { return }
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)

        self.tableView.register(R.nib.articleTableViewCell)
        self.tableView.register(R.nib.profileCell)
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.networkChecking()
        self.tableView.reloadData()
        if self.articles.count == 0 {
            self.observeArticle()
        }
        self.setStatusBarBackgroundColor()
        self.setAppearance()
    }

    func observeArticle() {
        SVProgressHUD.show(withStatus: "Loading...")
        self.articleService?.bindUidArticle(AccountData.uid!, callbackHandler: { [weak self] (models, error) in
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

extension MyProfileViewController : UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1}
        return articles.count
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView .dequeueReusableCell(withIdentifier: String(describing: ArticleTableViewCell.self), for: indexPath) as! ArticleTableViewCell
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileCell, for: indexPath)!
            cell.configure(AccountData.uid!)

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

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articleTableViewCell, for: indexPath)!
        cell.configure(self.articles[indexPath.row])

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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return 
        }
        let vc = R.storyboard.article.articleListViewController()!
        let bool = self.navigationController?.topViewController is ArticleListViewController
        if !bool {
            if self.articles.count > 0 {
                vc.article = self.articles[indexPath.row]
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let block = UITableViewRowAction(style: .normal, title: "削除") { (action, indexPath) in
            self.showAlertOKCancel("確認", "この書き込みを削除しますか？", "はい", "いいえ") { _ in
                self.deleteArticle(indexPath)
            }
        }
        block.backgroundColor = UIColor.hexStr(hexStr: "#f44242", alpha: 1.0)
        return [block]
    }

    // MARK: セル編集関数
    private func deleteArticle(_ indexPath: IndexPath) {
        SVProgressHUD.show(withStatus: "Loading...")
        let article = self.articles[indexPath.row]
        self.articleService?.deleteArticle(article, completionHandler: { [unowned self] error in
            if let error = error {
                Log.error(error)
                SVProgressHUD.dismiss()
                return
            }
            self.showAlert("削除しました")
            self.articles = []
            self.observeArticle()
            self.tableView.reloadData()
        })
    }
}

extension MyProfileViewController: writeVCprotocol {
    func close() {
        (UIApplication.shared.delegate as! AppDelegate).window?.close()
    }
}
