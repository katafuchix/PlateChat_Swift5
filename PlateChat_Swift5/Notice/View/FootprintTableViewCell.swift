//
//  FootprintTableViewCell.swift
//  PlateChat
//
//  Created by cano on 2018/09/24.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class FootprintTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageButton: CircleButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var attrLabel: UILabel!
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ uid: String, _ timeStamp: Int ) {
        self.clear()

        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        self.timeLabel.text = Date.timeAgoString(date)

        if let nickName = UsersData.nickNames[uid] {
            self.nameLabel.text = nickName
        }

        if let profile_image_url = UsersData.profileImages[uid] {
            self.profileImageButton.sd_setBackgroundImage(with: URL(string:profile_image_url), for: .normal) { [weak self] (image, error, cacheType, url) in
                if error != nil {
                    self?.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                }
            }
        } else {
            UserService.getUserInfo(uid, completionHandler: { [weak self] (user, error) in
                if let user = user {
                    var dict = UsersData.profileImages
                    dict[user.key] = user.profile_image_url
                    UsersData.profileImages = dict

                    dict = UsersData.nickNames
                    dict[user.key] = user.nickname
                    UsersData.nickNames = dict

                    self?.nameLabel.text = user.nickname
                    self?.profileImageButton.sd_setBackgroundImage(with: URL(string:user.profile_image_url), for: .normal) { [weak self] (image, error, cacheType, url) in
                        if error != nil {
                            self?.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                        }
                    }
                }
            })
        }

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func clear() {
        self.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
        self.nameLabel.text = ""
        self.attrLabel.text = ""
        self.timeLabel.text = ""
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
}
