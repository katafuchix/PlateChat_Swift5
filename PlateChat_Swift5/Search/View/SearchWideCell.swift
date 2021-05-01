//
//  SearchWideCell.swift
//  PlateChat
//
//  Created by cano on 2018/09/18.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SearchWideCell: UICollectionViewCell {

    @IBOutlet weak var profileImageButton: CircleButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var attrLabel: UILabel!
    @IBOutlet weak var profileTextLabel: UILabel!
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ user: LoginUser) {
        self.clear()

        self.nicknameLabel.text = user.nickname

        let text = user.profile_text.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .whitespacesAndNewlines)
        self.profileTextLabel.text = text

        if let profile_image_url = UsersData.profileImages[user.key] {
            self.profileImageButton.sd_setBackgroundImage(with: URL(string:profile_image_url), for: .normal) { [weak self] (image, error, cacheType, url) in
                if error != nil {
                    self?.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                }
            }
        } else {
            UserService.getUserInfo(user.key, completionHandler: { [weak self] (user, error) in
                if let user = user {
                    var dict = UsersData.profileImages
                    dict[user.key] = user.profile_image_url
                    UsersData.profileImages = dict

                    dict = UsersData.nickNames
                    dict[user.key] = user.nickname
                    UsersData.nickNames = dict

                    self?.profileImageButton.sd_setBackgroundImage(with: URL(string:user.profile_image_url), for: .normal) { [weak self] (image, error, cacheType, url) in
                        if error != nil {
                            self?.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                        }
                    }
                }
            })
        }
    }


    func clear() {
        self.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
        self.nicknameLabel.text = ""
        self.attrLabel.text = ""
        self.profileTextLabel.text = ""
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
}
