//
//  WriteViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/17.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SVProgressHUD

protocol writeVCprotocol {
    func close()
}

class WriteViewController: UIViewController {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var nicknameBaseView: UIView!
    @IBOutlet weak var nicknameBaseViewHeight: NSLayoutConstraint!
    @IBOutlet weak var articleNicknameLabel: PaddingLabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!

    var delegate: writeVCprotocol?
    let articleService = ArticleService()
    var article: Article?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.textView.becomeFirstResponder()
        self.textView.rx.didChange.subscribe(onNext: { [weak self] _ in
            self?.placeholderLabel.isHidden = true
        }).disposed(by: rx.disposeBag)
        //self.textView.becomeFirstResponder()

        self.closeButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.delegate?.close()
        }).disposed(by: rx.disposeBag)

        if let article = self.article {
            if let nickname = UsersData.nickNames[article.uid] {
                articleNicknameLabel.isHidden = false
                articleNicknameLabel.text = " to: \(nickname) "
            }
            self.nicknameBaseViewHeight.constant = 24.0
        } else {
            articleNicknameLabel.isHidden = true
            articleNicknameLabel.text = ""
            self.nicknameBaseViewHeight.constant = 0.0
        }
        self.postButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            guard let text = self?.textView.text else { return }
            if text.description.count > 200 {
                Alert.init("200文字以内で入力してください").show(self)
                return
            }

            self?.postButton.isEnabled = false
            SVProgressHUD.show(withStatus: "Posting...")
            self?.articleService.createArticle(text, self?.article, completionHandler: { error in
                SVProgressHUD.dismiss()
                if let error = error {
                    self?.textView.resignFirstResponder()
                    Alert.init(error.localizedDescription)
                        .addAction("OK", completion: { _ in self?.delegate?.close() })
                        .show(self)
                    /*
                    let errAlert = UIAlertController(title: "エラー", message: "error.localizedDescription", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self?.delegate?.close()
                    })
                    errAlert.addAction(okAction)
                    self?.present(errAlert, animated: true, completion: nil)
                    */
                } else {
                    self?.delegate?.close()
                }
            })
        }).disposed(by: rx.disposeBag)

        self.textView.rx.text.orEmpty.asDriver().drive(onNext:{ [weak self] str in
            self?.countLabel.text = "\(String(describing: str.description.count))/200"
            self?.postButton.isEnabled = str.description.count >= 10 && str.description.count <= 200
        }).disposed(by: rx.disposeBag)
        /*
        let tapGesture = UITapGestureRecognizer()
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.rx.event.bind(onNext: { [weak self] recognizer in
            self?.delegate?.close()
        }).disposed(by: rx.disposeBag)
        */
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
