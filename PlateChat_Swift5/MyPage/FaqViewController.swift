//
//  FaqViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/18.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class FaqViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var datasource = [FaqTableViewCellContent]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // 戻るボタン
        self.backButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)

        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension

        datasource = [
                    FaqTableViewCellContent(title: "アプリの利用に費用はかかりますか？ ",
                                    subtitle: "本サービスは完全無料で利用できます。"),
                    FaqTableViewCellContent(title: "ローディングが長いことがあります。 ",
                                            subtitle: "通信状態やサーバーの混み具合で時間がかかることもあります。しばらく待ってからお試しください。"),
                    FaqTableViewCellContent(title: "書き込みを削除するにはどうすればいいですか？ ",
                                            subtitle: "マイページの書き込みのリストのセルを左にスワイプしてください。削除ボタンから削除できます。\n削除した後にアプリに反映されるまで若干時間がかかることがあります。"),
                    FaqTableViewCellContent(title: "機種変更後にアカウントの引き継ぎはできますか？ ",
                                                    subtitle: "［設定］ー［アカウントの保存とログイン］よりメールアドレスとパスワードでログインしてください。メールアドレスとパスワードはあらかじめここで登録しておく必要があります。"),
                      FaqTableViewCellContent(title: "メールアドレス、パスワードを忘れてしまいました。 ",
                                                    subtitle: "運営事務局ではユーザーのデータは全て暗号化して保存しています。運営事務局側でデータの復号はできませんので、ご自身で管理しておいてください。"),
                      FaqTableViewCellContent(title: "プロフィール画像が消えてしまっています。 ",
                                                    subtitle: "運営事務局で不適切と判断した画像は削除することがあります。\n再度ご登録おください。"),
                      FaqTableViewCellContent(title: "退会したいのですが？ ",
                                subtitle: "［設定］ー［アカウント削除］から退会できます。\nさアカウントに関するデータはすべて削除しされます。"),
                      FaqTableViewCellContent(title: "プッシュ通知を止めたいのですが？ ",
                                              subtitle: "［設定］からプッシュ通知のON／OFFを設定できます。"),
                      FaqTableViewCellContent(title: "迷惑なユーザーがいます。 ",
                                              subtitle: "ユーザーの詳細画面やチャット画面で該当ユーザーをブロックすることができます。ブロックすると双方でアカウントに参照できなくなります。\nそれでも気になるようでしたら、［設定］ー［お問い合わせ］から運営事務局までご連絡ください。"),
                      FaqTableViewCellContent(title: "チャットは他のユーザーにも見えますか？ ",
                                              subtitle: "チャットのやり取りはが他のユーザーに後悔されることはありません。"),
                    ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.networkChecking()
        
        self.setStatusBarBackgroundColor()
        self.setAppearance()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension FaqViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: String(describing: FaqTableViewCell.self), for: indexPath) as! FaqTableViewCell
        cell.set(content: datasource[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = datasource[indexPath.row]
        content.expanded = !content.expanded
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
