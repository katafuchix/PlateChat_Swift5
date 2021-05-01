//
//  SearchViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/15.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import SVProgressHUD
import Rswift
import NSObject_Rx

class SearchViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var collectionTypeButton: UIBarButtonItem!

    var userService: UserService?
    var users = [LoginUser]()
    var users_org = [LoginUser]()
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _ = UserSearchData.init()
        
        self.collectionView.register(R.nib.searchWideCell)
        self.collectionView.register(R.nib.searchGridCell)
        self.collectionView.collectionViewLayout = self.flowLayout()
        self.collectionView.alwaysBounceVertical = true

        self.userService = UserService()
        self.observeUser()

        self.bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.networkChecking()
        if let flag = AccountData.search_collection_is_grid {
            if flag == true {
                self.collectionTypeButton.image = R.image.menu()
            } else {
                self.collectionTypeButton.image = R.image.grid()
            }
        }
    }

    func bind() {
        
        self.searchButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            let vc = R.storyboard.searchWindow.searchWindowViewController()!
            vc.delegate = self
            //UIWindow.createNewWindow(vc).open()
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)

        self.collectionTypeButton.rx.tap.asDriver().drive(onNext:{ [weak self] _ in
            AccountData.search_collection_is_grid = !(AccountData.search_collection_is_grid!)
            if AccountData.search_collection_is_grid! {
                self?.collectionTypeButton.image = R.image.menu()
            } else {
                self?.collectionTypeButton.image = R.image.grid()
            }
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }).disposed(by: rx.disposeBag)

        // ページング
        self.collectionView.rx.willDisplayCell.subscribe(onNext: { [unowned self] (cell, indexPath) in
            if self.isEndOfSections(indexPath) {
                self.observeUser()
            }
        }).disposed(by: rx.disposeBag)

        self.collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(SearchViewController.refresh(sender:)), for: .valueChanged)
    }

    private func flowLayout() -> UICollectionViewFlowLayout {
        let flow = UICollectionViewFlowLayout()

        let inset: CGFloat = 4.0
        //let width = view.bounds.width / 2 - inset * 2
        flow.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        flow.minimumLineSpacing = 10
        flow.minimumInteritemSpacing = 10
        //flow.itemSize = CGSize(width: width, height: 250)
        flow.sectionInset = UIEdgeInsets(top: 0,left: 20,bottom: 0,right: 20)

        return flow
    }

    func observeUser() {
        SVProgressHUD.show(withStatus: "Loading...")
        self.userService?.bindUser(callbackHandler: { [weak self] (models, error) in
            SVProgressHUD.dismiss()
            switch error {
            case .none:
                if let models = models {
                    let preMessageCount = self?.users.count
                    self?.users_org = models + (self?.users_org)!
                    self?.users_org = (self?.users_org.unique { $0.key == $1.key }.sorted(by: { $0.created_date > $1.created_date}))!
                    self?.filterBlock()
                    //self?.users = self?.users_org ?? []
                    if preMessageCount == self?.users.count {  // 更新数チェック
                        return
                    }
                    DispatchQueue.main.async {
                        //self?.tableView.reloadData()
                        self?.collectionView.reloadData()
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
        self.users = self.users_org
            .filter { !blockUsers.contains( $0.key ) }
            .filter { !blockedUsers.contains(  $0.key ) }
            .filter { $0.key != AccountData.uid! }
            .filter { $0.age >= UserSearchData.ageLower}
            .filter { $0.age <= UserSearchData.ageUpper}

        if UserSearchData.sex > 0 {
            self.users = self.users.filter { $0.sex == UserSearchData.sex }
        }
        if UserSearchData.prefecture_id > 0 {
            self.users = self.users.filter { $0.prefecture_id == UserSearchData.prefecture_id }
        }
    }

    @objc func refresh(sender: UIRefreshControl) {
        if  self.users.count == 0 {
            self.refreshControl.endRefreshing()
            return
        }
        SVProgressHUD.show(withStatus: "Loading...")
        self.userService?.bindUser(callbackHandler: { [weak self] (models, error) in
            SVProgressHUD.dismiss()
            switch error {
            case .none:
                if let models = models {
                    let preMessageCount = self?.users.count
                    self?.users_org = models + (self?.users_org)!
                    self?.users_org = (self?.users_org.unique { $0.key == $1.key }.sorted(by: { $0.created_date > $1.created_date}))!
                    self?.filterBlock()
                    //self?.users = self?.users_org ?? []
                    if preMessageCount == self?.users.count {  // 更新数チェック
                        return
                    }
                    DispatchQueue.main.async {
                        //self?.tableView.reloadData()
                        self?.collectionView.reloadData()
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
        return indexPath.row == self.users.lastIndex
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
// MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 10)
    }
/*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = (view.bounds.width - SearchCell.defaultSize.width * 2) / 3
        return UIEdgeInsetsMake(0, inset, 0, inset)
    }
*/
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if AccountData.search_collection_is_grid! {
            let width = (self.view.bounds.width - 60)/3
            return CGSize(width: width, height: width)
        }
        let width = self.view.bounds.width - 20
        return CGSize(width: width, height: 160)//SearchCell.defaultSize
    }
}

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("self.users.count")
        print(self.users.count)
        return self.users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if AccountData.search_collection_is_grid! {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.searchGridCell, for: indexPath)!
            cell.configure(self.users[indexPath.row])
            cell.profileImageButton.rx.tap.asDriver().drive(onNext: { [unowned self] _ in
                let vc = R.storyboard.uderDetail.userDetailViewController()!
                vc.uid = self.users[indexPath.row].key
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: cell.disposeBag)

            return cell
        }

        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.searchWideCell, for: indexPath)!
        cell.configure(self.users[indexPath.row])
        cell.profileImageButton.rx.tap.asDriver().drive(onNext: { [unowned self] _ in
            let vc = R.storyboard.uderDetail.userDetailViewController()!
            vc.uid = self.users[indexPath.row].key
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: cell.disposeBag)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController : UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.deselectItem(at: indexPath, animated: true)
        print(indexPath)
    }
}

extension SearchViewController: searchWindowVCprotocol {
    func close() {
        (UIApplication.shared.delegate as! AppDelegate).window?.close()
    }

    func search() {
        self.users = []
        self.users_org = []
        self.userService?.lastLoginUserDocument = nil
        self.collectionView.reloadData()    // セルが残っているかもしれないのでリセット
        self.observeUser()
        (UIApplication.shared.delegate as! AppDelegate).window?.close()
    }
}
