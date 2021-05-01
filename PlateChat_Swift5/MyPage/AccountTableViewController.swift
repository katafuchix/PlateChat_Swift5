//
//  AccountTableViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/18.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SVProgressHUD

class AccountTableViewController: UITableViewController {

    @IBOutlet weak var mailTextField: UnderlineTextField!
    @IBOutlet weak var passwordTextField: UnderlineTextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var otherLoginButton: UIButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    let login_email: Variable<String>       = Variable("")
    let login_password: Variable<String>    = Variable("")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorColor = .clear
        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()

        // 入力された文字を非表示モードにする.
        self.passwordTextField.isSecureTextEntry = true

        self.mailTextField.text     = AccountData.login_email
        self.passwordTextField.text = AccountData.login_password

        self.bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.networkChecking()
    }
    
    func bind() {
        // 戻るボタン
        self.backButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
        
        // login_email
        self.mailTextField.rx.text.orEmpty.bind(to: self.login_email).disposed(by: rx.disposeBag)
        // login_password
        self.passwordTextField.rx.text.orEmpty.bind(to: self.login_password).disposed(by: rx.disposeBag)

        // 保存
        saveButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in

            if (self?.login_email.value.isEmpty)! {
                Alert.init("メールアドレスを入力してください").show(self)
                return
            }
            if (self?.login_password.value.isEmpty)! {
                Alert.init("パスワードを入力してください").show(self)
                return
            }

            if (self?.isValidEmail((self?.login_email.value)!)) == false  {
                Alert.init("メールアドレスを正しく入力してください").show(self)
                return
            }

            let dic = [
                "login_email" : self?.login_email.value ?? "",
                "login_password" : self?.login_password.value ?? "",
                ] as [String : String]
            print(dic)
            SVProgressHUD.show(withStatus: "Updating...")
            UserService.updateLoginUser(dic,completionHandler: { ( _, error) in
                SVProgressHUD.dismiss()
                if error != nil {
                    self?.showAlert("Error!")
                    return
                } else {
                    self?.showAlert("更新しました")
                    self?.mailTextField.resignFirstResponder()
                    self?.passwordTextField.resignFirstResponder()
                }
            })
        }).disposed(by: rx.disposeBag)

        // ログイン
        otherLoginButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            Alert("", "別アカウントでログイン")
            .addAction("ログイン" , completion: { [weak self] (AlertResult) in
                print(AlertResult)
                switch AlertResult {
                case .other(let inputText):
                    SVProgressHUD.show(withStatus: "Loading...")
                    SVProgressHUD.dismiss()
                    let login_email: String = inputText[0]
                    let login_pass: String = inputText[1]
                    /*guard let login_email: String = inputText[0], let login_pass: String = inputText[1] else {
                        SVProgressHUD.dismiss()
                        self?.showAlert("メールアドレスとパスワードを正しく入力してください")
                        return
                    }*/
                    UserService.changeLoginUser(login_email, login_pass, completionHandler: {
                        (user, error) in
                        if let err = error {
                            Log.error(err)
                            SVProgressHUD.dismiss()
                            self?.showAlert("ログインできませんでした", "メールアドレスとパスワードをご確認ください", "OK", completion: { _ in })
                            return
                        }
                        SVProgressHUD.dismiss()
                        self?.showAlert("別アカウントでログインしました", "", "OK", completion: { _ in
                            self?.navigationController?.popViewController(animated: true)
                        })
                    })
                    //self?.navigationController?.popViewController(animated: true)
                default:
                break
                }
            })
            .setCancelAction("キャンセル")
            .addTextField("", "メールアドレス")
            .addTextField("", "パスワード")
            .show(self)
        }).disposed(by: rx.disposeBag)
    }

    func isValidEmail(_ string: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: string)
        return result
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
