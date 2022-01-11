//
//  PrivacyPoricyViewController.swift
//  PlateChat
//
//  Created by cano on 2018/12/18.
//  Copyright © 2018 deskplate. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
import NSObject_Rx

class PrivacyPoricyViewController: UIViewController {

    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.closeButton.image = UIImage()
        self.closeButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)

        // 戻るボタン
        self.backButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
        
        if let filePath = Bundle.main.path(forResource: "PrivacyPoricy", ofType: "html"),
            let str = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8) {
            webView.load(URLRequest(url: URL(fileURLWithPath: filePath, isDirectory: false)))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.networkChecking()
        
        self.setStatusBarBackgroundColor()
        self.setAppearance()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
