//
//  ArticleTableViewCell.swift
//  PlateChat
//
//  Created by cano on 2018/08/18.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import SDWebImage
import RxSwift
import RxCocoa
import NSObject_Rx
import Firebase

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImageButton: CircleButton!
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var userAttrLabel: UILabel!


    @IBOutlet weak var toButtonBaseView: UIView!
    @IBOutlet weak var toButtonBaseViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var toLabel: PaddingLabel!
    @IBOutlet weak var articleLabel: UILabel!

    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var talkButton: UIButton!
    @IBOutlet weak var buttonBaseView: UIView!
    @IBOutlet weak var buttonBaseViewHeight: NSLayoutConstraint!

    @IBOutlet weak var dateLabel: UILabel!

    var article: Article?
    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ article: Article) {
        self.clear()

        self.article = article

        if article.user_profile_image_url.description.count > 0 {
            self.userProfileImageButton.sd_setBackgroundImage(with: URL(string:article.user_profile_image_url), for: .normal) { [unowned self] (image, error, cacheType, url) in
                if error != nil {
                    self.userProfileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                }
            }
            var dict = UsersData.profileImages
            dict[article.uid] = article.user_profile_image_url
            UsersData.profileImages = dict

            dict = UsersData.nickNames
            dict[article.uid] = article.user_nickname
            UsersData.nickNames = dict
        }
        self.userNicknameLabel.text = article.user_nickname
        self.setUserAttr(article.uid)

        UserService.getUserInfo(article.uid, completionHandler: { [unowned self] (user, error) in
            if let user = user {
                var dict = UsersData.profileImages
                dict[user.key] = user.profile_image_url
                UsersData.profileImages = dict

                dict = UsersData.nickNames
                dict[user.key] = user.nickname
                UsersData.nickNames = dict

                dict = UsersData.profileTexts
                dict[user.key] = user.profile_text
                UsersData.profileTexts = dict

                var dict2 = UsersData.ages
                dict2[user.key] = user.age
                UsersData.ages = dict2

                dict2 = UsersData.genders
                dict2[user.key] = user.sex
                UsersData.genders = dict2

                dict2 = UsersData.prefecture_ids
                dict2[user.key] = user.prefecture_id
                UsersData.prefecture_ids = dict2

                self.setUserAttr(user.key)
            }
        })
        
        let text = article.text.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .whitespacesAndNewlines)
        self.articleLabel.text = text

        //print(Constants.prefs.filter {$0.0 == article.user_prefecture_id }.map { $0.1 }[0])
        //print(Constants.genders[article.user_sex])
        if Auth.auth().currentUser?.uid == article.uid {
            self.buttonBaseViewHeight.constant = 34.0
            self.buttonBaseView.isHidden = false
            self.talkButton.isHidden = true
        } else {
            self.buttonBaseViewHeight.constant = 34.0
            self.buttonBaseView.isHidden = false
            self.talkButton.isHidden = false
        }
        self.talkButton.isEnabled = true

        if article.toUid != "" {
            self.toButtonBaseViewHeightConstraint.constant = 34.0
            self.toButtonBaseView.isHidden = false
            if let toNickName = UsersData.nickNames[article.toUid] {
                self.toLabel.text = toNickName
            } else {
                UserService.getUserInfo(article.toUid, completionHandler: { (user, error) in
                    if let user = user {
                        var dict = UsersData.profileImages
                        dict[user.key] = user.profile_image_url
                        UsersData.profileImages = dict

                        dict = UsersData.nickNames
                        dict[user.key] = user.nickname
                        UsersData.nickNames = dict
                        
                        dict = UsersData.profileTexts
                        dict[user.key] = user.profile_text
                        UsersData.profileTexts = dict

                        var dict2 = UsersData.ages
                        dict2[user.key] = user.age
                        UsersData.ages = dict2

                        dict2 = UsersData.genders
                        dict2[user.key] = user.sex
                        UsersData.genders = dict2

                        dict2 = UsersData.prefecture_ids
                        dict2[user.key] = user.prefecture_id
                        UsersData.prefecture_ids = dict2
                    }
                })
            }
        } else {
            self.toButtonBaseViewHeightConstraint.constant = 0
            self.toButtonBaseView.isHidden = true
        }


        let tapGesture = UITapGestureRecognizer()
        self.toLabel.addGestureRecognizer(tapGesture)
        tapGesture.rx.event.bind(onNext: { recognizer in
            print("touches: \(article.text)") //or whatever you like
        }).disposed(by: disposeBag)

        self.dateLabel.text = Date.timeAgoString(article.created_date)
    }

    func setUserAttr(_ uid: String ) {
        if  let age = UsersData.ages[uid], let gender = UsersData.genders[uid], let prefecture_id = UsersData.prefecture_ids[uid] {

            let sex = Constants.genders[gender]
            let age = age > 0 ? "\(age) " : "未設定"
            let address = Constants.prefs.keys.contains(prefecture_id) ? Constants.prefs[prefecture_id]! : "未設定"

            self.userAttrLabel.text  = "\(sex), \(age), \(address)"
        }

    }

    func clear() {
        self.article = nil
        self.userProfileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
        self.userNicknameLabel.text = ""
        self.userAttrLabel.text = ""
        self.articleLabel.text = ""
        self.buttonBaseViewHeight.constant = 30.0
        self.buttonBaseView.isHidden = false
        self.talkButton.isEnabled = false
        self.dateLabel.text = ""
        self.talkButton.isHidden = false
        self.toButtonBaseViewHeightConstraint.constant = 0
        self.toButtonBaseView.isHidden = true
        self.dateLabel.text = ""
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
