//
//  SearchGridCell.swift
//  PlateChat
//
//  Created by cano on 2018/09/21.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SearchGridCell: UICollectionViewCell {

    @IBOutlet weak var profileImageButton: CircleButton!
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ user: LoginUser) {
        self.clear()
        
//        if user.profile_image_url.description.count > 0 {
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
//           }
        }
    }

    func clear() {
        self.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
}
