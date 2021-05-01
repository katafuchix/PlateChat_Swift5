//
//  ArticleListViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/07.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import SVProgressHUD

class ArticleListViewController: UIViewController {

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    var articleService: ArticleService?
    var articles = [Article]()
    var articles_org = [Article]()
    var article: Article! {
        didSet {
            self.articles.append(article)
            self.articles_org.append(article)
        }
    }
    
    var writeVC: WriteViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.networkChecking()
    }
    
    func bind(){

        self.backButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)

        self.refreshButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
        }).disposed(by: rx.disposeBag)

        self.tableView.register(R.nib.articleTableViewCell)
        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()
        //tableView.estimatedRowHeight = 170 // これはStoryBoardの設定で無視されるかも？
        tableView.rowHeight = UITableView.automaticDimension

        self.articleService = ArticleService()
        if self.article != nil && self.article.parentKey != "" {
            self.observeArticle( true )
            // ページング
            tableView.rx.willDisplayCell.subscribe(onNext: { [unowned self] (cell, indexPath) in
                if self.isEndOfSections(indexPath) {
                    self.observeArticle()
                }
            }).disposed(by: rx.disposeBag)
        }

    }

    func observeArticle(_ isSetIndex: Bool = false ) {
        SVProgressHUD.show(withStatus: "Loading...")
        self.articleService?.bindArticleList(article:self.article, callbackHandler: { [weak self] (models, error) in
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
                        if isSetIndex{
                            if let index = self?.articles.index(of:(self?.article)!) {
                                print(index)
                                self?.tableView.scrollToRow(at: IndexPath(item: index, section: 0), at: .top, animated: false)
                            }
                        }
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// セクション配列・セクション内の末尾位置か調べる
    /// - return: Bool (true -> End of Sections and Rows)
    func isEndOfSections(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == self.articles.lastIndex
    }
}

extension ArticleListViewController : UITableViewDataSource, UITableViewDelegate {

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

            self.writeVC = R.storyboard.write.writeViewController()!
            self.writeVC?.delegate = self
            self.writeVC?.article = self.articles[indexPath.row]
            //UIWindow.createNewWindow(vc).open()
            self.writeVC?.modalPresentationStyle = .overFullScreen
            self.writeVC?.modalTransitionStyle   = .crossDissolve
            self.present(self.writeVC!, animated: true, completion: nil)
        }).disposed(by: cell.disposeBag)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension ArticleListViewController: writeVCprotocol {
    func close() {
        //(UIApplication.shared.delegate as! AppDelegate).window?.close()
        self.writeVC?.dismiss(animated: true, completion: nil)
    }
}
