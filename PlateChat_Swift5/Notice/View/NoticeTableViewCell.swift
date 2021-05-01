//
//  NoticeTableViewCell.swift
//  PlateChat
//
//  Created by cano on 2018/09/24.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class NoticeTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageButton: CircleButton!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var disposeBag = DisposeBag()

    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        //let formatter = DateFormatter(withFormat: "M/d", locale: Locale.current.languageCode ?? "en_US_POSIX")
        //formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: Locale.current.languageCode!)
        formatter.dateFormat = "M/d"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ uid: String, _ timeStamp: Int ) {
        self.clear()

        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        self.timeLabel.text = Date.timeAgoString(date)


        if let nickName = UsersData.nickNames[uid] {
            self.noticeLabel.text = "\(nickName)さんがあたなの投稿に返信しました"
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

                    self?.noticeLabel.text = "\(user.nickname)さんがあたなの投稿に返信しました"
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
        self.noticeLabel.text = ""
        self.timeLabel.text = ""
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
}
