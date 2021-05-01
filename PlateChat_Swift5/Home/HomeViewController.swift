//
//  HomeViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/17.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Rswift
import RxCocoa
import NSObject_Rx
import SVProgressHUD
import FirebaseFunctions
import RxFirebase

class HomeViewController: UIViewController {

    @IBOutlet weak var writeButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    var articleService: ArticleService?
    var articles = [Article]()
    var articles_org = [Article]()
    private let refreshControl = UIRefreshControl()

    lazy var functions = Functions.functions()
    var selectedImage = BehaviorRelay<UIImage?>(value: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        if (AccountData.isFirst) {
            let vc = R.storyboard.rule.ruleViewController()!
            vc.delegate = self
            let nc = UINavigationController(rootViewController: vc)
            self.present(nc, animated: true, completion: nil)
        } else {
            self.checkProfile()
        }

        self.writeButton.rx.tap.asDriver().drive(onNext: { [unowned self] _ in

            if let name = AccountData.nickname {
                if name.trimmingCharacters(in: .whitespaces) == "" {
                    self.showAlert("［マイページ］ー［設定］ー［プロフィール設定］からニックネームを登録してください")
                    return
                }
            }

            let vc = R.storyboard.write.writeViewController()!
            vc.delegate = self
            UIWindow.createNewWindow(vc).open()
        }).disposed(by: rx.disposeBag)

        self.reloadButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            //self?.articles.removeAll()
            self?.observeArticle()
        }).disposed(by: rx.disposeBag)

        self.tableView.register(R.nib.articleTableViewCell)
        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.estimatedRowHeight = 170 // これはStoryBoardの設定で無視されるかも？
        tableView.rowHeight = UITableView.automaticDimension

        self.articleService = ArticleService()
        self.observeArticle()

        // ページング
        tableView.rx.willDisplayCell.subscribe(onNext: { [unowned self] (cell, indexPath) in
            if self.isEndOfSections(indexPath) {
                self.observeArticle()
            }
        }).disposed(by: rx.disposeBag)

        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(HomeViewController.refresh(sender:)), for: .valueChanged)
    }

    @objc func refresh(sender: UIRefreshControl) {
        if  self.articles.count == 0 {
            self.refreshControl.endRefreshing()
            return
        }
        SVProgressHUD.show(withStatus: "Loading...")
        self.articleService?.bindNewArticle(callbackHandler: { [weak self] (models, error) in
            SVProgressHUD.dismiss()
            switch error {
            case .none:
                if let models = models {
                    let preMessageCount = self?.articles.count
                    self?.articles_org = models + (self?.articles_org)!
                    self?.articles_org = (self?.articles_org.unique { $0.key == $1.key }.sorted(by: { $0.created_date > $1.created_date}))!
                    self?.filterBlock()
                    if preMessageCount == self?.articles.count {  // 更新数チェック
                        self?.refreshControl.endRefreshing()
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
            self?.refreshControl.endRefreshing()
        })
    }

    func observeArticle() {
        SVProgressHUD.show(withStatus: "Loading...")
        self.articleService?.bindArticle(callbackHandler: { [weak self] (models, error) in
            SVProgressHUD.dismiss()
            switch error {
            case .none:
                if let models = models {
                    let preMessageCount = self?.articles.count
                    self?.articles_org = models + (self?.articles_org)!
                    self?.articles_org = (self?.articles_org.unique { $0.key == $1.key }.filter {$0.status == 1 }.sorted(by: { $0.created_date > $1.created_date}))!
                    self?.filterBlock()
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

    func filterBlock() {
        let blockUsers = Array(UsersData.userBlock.filter {$0.1 == true}.keys)
        let blockedUsers = Array(UsersData.userBlocked.filter {$0.1 == true}.keys)
        self.articles = self.articles_org
            .filter { !blockUsers.contains( $0.uid ) }
            .filter { !blockedUsers.contains(  $0.uid ) }
            .filter { $0.status == 1 }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.networkChecking()

        if self.articles.count == 0 {
            self.observeArticle()
        }
        
        self.filterBlock()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func buttonTapped(sender: UIButton) {
        print("button tapped")
    }

    /// セクション配列・セクション内の末尾位置か調べる
    /// - return: Bool (true -> End of Sections and Rows)
    func isEndOfSections(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == self.articles.lastIndex
    }

    func checkProfile() {
        if let name = AccountData.nickname {
            if name.trimmingCharacters(in: .whitespaces) == "" {
                let vc = R.storyboard.registProfile.registProfileViewController()!
                vc.delegate = self
                UIWindow.createNewWindow(vc).open()
            }
        }
    }
}

extension HomeViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView .dequeueReusableCell(withIdentifier: String(describing: ArticleTableViewCell.self), for: indexPath) as! ArticleTableViewCell

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articleTableViewCell, for: indexPath)!
        //cell.set(content: datasource[indexPath.row])
        cell.configure(self.articles[indexPath.row])

        cell.userProfileImageButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            let vc = R.storyboard.uderDetail.userDetailViewController()!
            vc.uid = cell.article?.uid
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: cell.disposeBag)

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

        cell.replyButton.rx.tap.asDriver().drive(onNext: { [unowned self] _ in

            if let name = AccountData.nickname {
                if name.trimmingCharacters(in: .whitespaces) == "" {
                    self.showAlert("［マイページ］ー［設定］ー［プロフィール設定］からニックネームを登録してください")
                    return
                }
            }

            let vc = R.storyboard.write.writeViewController()!
            vc.delegate = self
            vc.article = self.articles[indexPath.row]
            UIWindow.createNewWindow(vc).open()
        }).disposed(by: cell.disposeBag)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        let vc = R.storyboard.article.articleListViewController()!
        let bool = self.navigationController?.topViewController is ArticleListViewController
        if !bool {
            //vc.chatRoom     = chatRoom
            //vc.other_uid    = article.uid
            //vc.hidesBottomBarWhenPushed = true
            vc.article = self.articles[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        /*
        let content = datasource[indexPath.row]
        content.expanded = !content.expanded
        tableView.reloadRows(at: [indexPath], with: .automatic)
        */
    }
}

extension HomeViewController: writeVCprotocol {
    func close() {
        (UIApplication.shared.delegate as! AppDelegate).window?.close()
        //let indexPath = IndexPath(row: 0, section: 0)
        //self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        /*
        let rect = CGRect(x:0, y:0, width:self.tableView.frame.size.width, height:self.tableView.frame.size.height)
        tableView.scrollRectToVisible(rect, animated: false) //スクロールのアニメーションなくす
        */
        /*
        self.tableView.reloadData()
        self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)

        self.tableView.setContentOffset(CGPoint(x:0, y:-self.tableView.contentInset.top), animated: false);

        self.tableView.contentOffset = .zero
        */
        //self.tableView.setContentOffset(CGPoint.zero, animated: true)

        /*// アクションシート選択項目
        var actions = [ActionSheetAction<UIImagePickerControllerSourceType>(title: "ライブラリから選択",
                                                                            actionType: UIImagePickerControllerSourceType.photoLibrary,
                                                                            style: .default)]
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actions.insert(ActionSheetAction<UIImagePickerControllerSourceType>(title: "カメラを起動",
                                                                                actionType: UIImagePickerControllerSourceType.camera,
                                                                                style: .default), at: 0)
        }
        self.shwoActionSheet(title: "アバター設定", message: "選択してください。", actions: actions)
        */
        /*
         self.selectedImage.asObservable().subscribe(onNext: { [unowned self] image in

         if let image = image, let jpeg = UIImageJPEGRepresentation(image, 0.9) {

         //if let data = data {
         let encodeString = jpeg.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
         //print(encodeString)

         self.functions.httpsCallable("addMessage").call(["text": encodeString, "companyKey": "smt"]) { (result, error) in
                if let error = error as NSError? {
                    print("error")
                    print(error)
                }
                print("result")
                print(result)
                if let text = (result?.data as? [String: Any])?["uid"] as? String {
                    print(text)
                }
            }
         }).disposed(by: rx.disposeBag)
         */
        /*
        let (updatedResult, updateError) = Driver.split(result:

            self.selectedImage.asDriver()
                .filter { $0 != nil }
                .map { $0?.resizeImage(maxSize: 10485760) }
                .map { UIImageJPEGRepresentation($0! , 0.9) }
                .map { $0?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters) }
                .flatMapLatest { [unowned self] value in return

                    self.functions.httpsCallable("addMessage").rx.call(["text": value, "companyKey": "smt", "param":["text": value, "companyKey": "smt"]]).resultDriver()})

        updatedResult.asObservable().subscribe(onNext:{ result in
            print("updatedResult")
            print("result")
            print(result)
            if let data = result.data as? [String: Any] {
                print(data)
            }
            if let text = (result.data as? [String: Any])?["uid"] as? String {
                print(text)
            }
        }).disposed(by: rx.disposeBag)

        let (imageUpdatedResult, imageUpdateError) = Driver.split(result:updatedResult.asDriver().map { ($0.data as? [String: Any])?["downloadUrl"] as? String }
            .filter { $0 != nil && $0 != ""}
            .flatMapLatest { [unowned self] value in return
                self.functions.httpsCallable("updateProfileImage").rx.call(["profile_image_url": value, "companyKey": "smt"]).resultDriver()})

        imageUpdatedResult.asObservable().subscribe(onNext:{ result in
            print("imageUpdatedResult")
            print("result")
            print(result)
            if let data = result.data as? [String: Any] {
                print(data)
            }
            if let text = (result.data as? [String: Any])?["uid"] as? String {
                print(text)
            }
        }).disposed(by: rx.disposeBag)
        */
    }
}

extension HomeViewController : ruleDelegate {
    func dissmiss() {
        AccountData.isFirst = false
        self.observeArticle()
        self.filterBlock()
        self.tableView.reloadData()
        self.checkProfile()
    }
}

extension HomeViewController: registProfileVCprotocol {
    func closeRegist() {
        (UIApplication.shared.delegate as! AppDelegate).window?.close()
        self.showAlert("登録しました")
    }

    func closeOnly() {
        (UIApplication.shared.delegate as! AppDelegate).window?.close()
    }
}
