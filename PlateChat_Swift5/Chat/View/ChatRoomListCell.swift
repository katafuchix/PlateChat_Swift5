//
//  ChatRoomListCell.swift
//  PlateChat
//
//  Created by cano on 2018/08/31.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import SDWebImage
import RxSwift
import RxCocoa
import NSObject_Rx
import Firebase

class ChatRoomListCell: UITableViewCell {

    @IBOutlet weak var userProfileImageButton: CircleButton!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var chatTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!

    var chatRoom: ChatRoom?
    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ chatRoom: ChatRoom, _ indexPath: IndexPath) {
        self.clear()
        self.chatRoom = chatRoom
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let other_uid = Array(chatRoom.members.filter { $0.0 != uid }.keys)[0]

        if let count = self.chatRoom?.unreadCounts![uid] {
            self.unreadCountLabel.isHidden = count < 1
            self.unreadCountLabel.text = "\(count)"
            if count > 0 && indexPath.row == 0 {
                //AppDelegate.appDelegate?.showChatUnreadCount("\(count)")
            }
        }

        if let nickName = UsersData.nickNames[other_uid] {
            self.nickNameLabel.text = nickName
        }
        if let text = chatRoom.last_update_message {
            self.chatTextLabel.text = text
        }
        self.dateLabel.text = Date.timeAgoString(chatRoom.updated_date)
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

            var dict = UsersData.profileImages
            dict[other_uid] = user.profile_image_url
            UsersData.profileImages = dict

            self?.userProfileImageButton.sd_setBackgroundImage(with: URL(string:user.profile_image_url), for: .normal) { [weak self] (image, error, cacheType, url) in
                if let error = error {
                    Log.error(error)
                    self?.userProfileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                }
            }
            self?.nickNameLabel.text = user.nickname
        })
    }

    func clear() {
        self.chatRoom = nil
        self.userProfileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
        self.nickNameLabel.text = ""
        self.chatTextLabel.text = ""

        /*self.userNicknameLabel.text = ""
        self.userAttrLabel.text = ""
        self.articleLabel.text = ""
        self.buttonBaseViewHeight.constant = 30.0
        self.buttonBaseView.isHidden = false
        self.talkButton.isEnabled = false
        self.dateLabel.text = ""
 */
        self.unreadCountLabel.text = ""
        self.unreadCountLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
