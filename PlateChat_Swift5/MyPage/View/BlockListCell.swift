//
//  BlockListCell.swift
//  PlateChat
//
//  Created by cano on 2018/09/01.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

class BlockListCell: UITableViewCell {

    @IBOutlet weak var userProfileImageButton: CircleButton!
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var userAttrLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ other_uid: String) {
        self.clear()

        if let nickName = UsersData.nickNames[other_uid] {
            self.userNicknameLabel.text = nickName
        }
        if let url = UsersData.profileImages[other_uid] {
            self.userProfileImageButton.sd_setBackgroundImage(with: URL(string:url), for: .normal) { [weak self] (image, error, cacheType, url) in
                if let error = error {
                    Log.error(error)
                    self?.userProfileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                }
            }
        }

        UserService.getUserInfo(other_uid, completionHandler: { [weak self] (user, error) in
            if let error = error {
                Log.error(error)
                return
            }
            guard let user = user else  { return }

            self?.userProfileImageButton.sd_setBackgroundImage(with: URL(string:user.profile_image_url), for: .normal) { [weak self] (image, error, cacheType, url) in
                if let error = error {
                    Log.error(error)
                    self?.userProfileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                }
            }
            self?.userNicknameLabel.text = user.nickname
        })
    }

    func clear() {
        self.userProfileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
        self.userNicknameLabel.text = ""
        self.userAttrLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
