//
//  ProfileCell.swift
//  PlateChat
//
//  Created by cano on 2018/09/07.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileCell: UITableViewCell {

    @IBOutlet weak var profileImageButton: CircleButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var profileAttrLabel: UILabel!
    @IBOutlet weak var profileTextLabel: PaddingProfileLabel!

    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ uid: String) {
        self.clear()
        
        if uid == AccountData.uid {
            self.nicknameLabel.text = AccountData.nickname
            //self.setUserAttr(uid)

            let sex = Constants.genders[AccountData.sex]
            let age = AccountData.age > 0 ? "\(AccountData.age) " : "未設定"
            let address = Constants.prefs.keys.contains(AccountData.prefecture_id) ? Constants.prefs[AccountData.prefecture_id]! : "未設定"
            self.profileAttrLabel.text = "\(sex), \(age), \(address)"

            if let profileText = AccountData.profile_text {
                self.profileTextLabel.text = profileText
                if profileText != "" {
                    self.profileTextLabel.borderColor = UIColor.hexStr(hexStr: "#7DD8C7", alpha: 0.6)
                    self.profileTextLabel.borderWidth = 1.0
                }
            }

            if let url = AccountData.my_profile_image {
                self.profileImageButton.sd_setBackgroundImage(with: URL(string:url), for: .normal) { [weak self] (image, error, cacheType, url) in
                    if error != nil {
                        self?.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                    }
                }
            } else {
                self.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
            }

        } else {
            self.setUserAttr(uid)
            /*
            if let toNickName = UsersData.nickNames[uid] {
                self.nicknameLabel.text = toNickName
                if let profile_image_url = UsersData.profileImages[uid] {
                    self.profileImageButton.sd_setBackgroundImage(with: URL(string:profile_image_url), for: .normal) { [weak self] (image, error, cacheType, url) in
                        if error != nil {
                            self?.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                        }
                    }
                }
            } else {
                UserService.getUserInfo(uid, completionHandler: { [unowned self] (user, error) in
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

                        self.nicknameLabel.text = user.nickname

                        print("user.profile_text")
                        print(user.profile_text)
                        self.setUserAttr(user.key)

                        self.profileImageButton.sd_setBackgroundImage(with: URL(string:user.profile_image_url), for: .normal) { (image, error, cacheType, url) in
                            if error != nil {
                                self.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                            }
                        }
                    }
                })
            }*/
        }
    }

    func setUserAttr(_ uid: String ) {
        if let nickName = UsersData.nickNames[uid] {
            self.nicknameLabel.text = nickName
        }

        if let profile_image_url = UsersData.profileImages[uid] {
            self.profileImageButton.sd_setBackgroundImage(with: URL(string:profile_image_url), for: .normal) { [weak self] (image, error, cacheType, url) in
                if error != nil {
                    self?.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                }
            }
        }

        if  let age = UsersData.ages[uid], let gender = UsersData.genders[uid], let prefecture_id = UsersData.prefecture_ids[uid] {
            let sex = Constants.genders[gender]
            let age = age > 0 ? "\(age) " : "未設定"
            let address = Constants.prefs.keys.contains(prefecture_id) ? Constants.prefs[prefecture_id]! : "未設定"
            self.profileAttrLabel.text  = "\(sex), \(age), \(address)"
        }

        if let profileText = UsersData.profileTexts[uid] {
            self.profileTextLabel.text = profileText
            if profileText != "" {
                self.profileTextLabel.borderColor = UIColor.hexStr(hexStr: "#7DD8C7", alpha: 0.6)
                self.profileTextLabel.borderWidth = 1.0
            }
        }

    }

    func clear() {
        self.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
        self.nicknameLabel.text = ""
        self.profileAttrLabel.text = ""
        self.profileTextLabel.text = ""
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
