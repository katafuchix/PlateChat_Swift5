//
//  ChatMessageCell.swift
//  matching
//
//  Created by Work on 2017/11/06.
//  Copyright © 2017年 NOWALL, Inc. All rights reserved.
//

import MessageKit
import SDWebImage
import UIKit

class ChatMessageKitCell: TextMessageCell {
    /*
    var blurDelegate: ChatBlurViewDelegate? {
        get { return blurView.delegate }
        set { blurView.delegate = newValue }
    }
    */
    let readimgView: UIImageView = {
        let imgView = UIImageView()
        imgView.isHidden = true
        //imgView.image = R.image.read_check_icon()
        imgView.frame = CGRect(x: 0, y: 0, width: 11, height: 8)
        return imgView
    }()
    let timeLabel: UILabel = {
        let lb = UILabel()
        //lb.font = R.font.notoSansCJKjpSubMedium(size: 11)
        //lb.textColor = UIColor.rgba(170, 170, 170)
        lb.text = nil
        lb.frame = CGRect(x: 0, y: 0, width: 30, height: 12)
        return lb
    }()
    let indicator: UIActivityIndicatorView = {
        let ind = UIActivityIndicatorView()
        ind.style = .gray
        ind.hidesWhenStopped = true
        ind.isHidden = true
        return ind
    }()
    /*
    private let blurView: ChatBlurView = {
        let v = UIView.instantiateFromNib(ChatBlurView.self)
        v.isHidden = true
        return v
    }()
    */
    private var isMyMessage: Bool = false   // 自身の投稿ならtrue (configureで値決定)
    //private var isDisabledChat: Bool { return ChatViewController.isDisabledChat }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let oldframe = self.avatarView.frame
        //self.avatarView = CustomAvatarView(frame: oldframe)
        self.contentView.addSubview(readimgView)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(indicator)
        //self.messageContainerView.addSubview(blurView)
        self.contentView.addSubview(avatarView)
        
        //updateAvatar()
    }
    
    required public convenience init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRect.zero)
    }
    
    // MARK: - Methods
    
    //override
    open class func reuseIdentifier() -> String { return "ChatMessageKitCell" /*self.nameOfClass*/ }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //if isDisabledChat &&
        if !isMyMessage {
            if messageContainerView.frame.size.width < 210 { messageContainerView.frame.size.width = 210 }
            if messageContainerView.frame.size.height < 34 { messageContainerView.frame.size.height = 34 }
        }
        layoutAppendedViews()
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        
        messageContainerView.isUserInteractionEnabled = false
        timeLabel.text = nil
        readimgView.isHidden = true
        indicator.stopAnimating()
        //blurView.isHidden = true
    }


    /*
    func configure(with message: PatersMessageData, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView, userData: UserData?, senderId: String, blurDelegate: ChatBlurViewDelegate?) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        isMyMessage = (message.sender.id == senderId)
        
        self.blurDelegate = blurDelegate
        if blurDelegate != nil && !isMyMessage {
            blurView.isHidden = !isDisabledChat
            messageContainerView.isUserInteractionEnabled = !blurView.isHidden
        }
        
        timeLabel.text = message.sentDate.hourAndMinites()
        
        if !isMyMessage,
            let avatar = avatarView as? CustomAvatarView  {
            if let url = userData?.main_profile_image, !url.isEmpty {
                avatar.avatarImage.loadWebImage(url) {  image in
                    avatar.avatarImage.image = image
                }
            } else if let emptyImg = userData?.emptyImage {
                avatar.avatarImage.image = emptyImg
            } else {
                avatar.avatarImage.image = R.image.avatar()!
            }
        } else if AccountData.premium_charging_member {
            readimgView.isHidden = !message.isRead
        }
        
        if let message = message as? APIMessage, message.isSending {
            indicator.isHidden = false
            indicator.startAnimating()
        }
    }
    */

    private func layoutAppendedViews() {
        let m: CGFloat = 4
        let containerBottom = messageContainerView.frame.origin.y + messageContainerView.frame.height
        timeLabel.frame.origin.y = containerBottom + m
        //既読の水平の中心点を時刻ラベルに合わせる
        readimgView.center.y = timeLabel.center.y
        indicator.frame.origin.y = messageContainerView.center.y
        
        if isMyMessage {
            let containerLeft = messageContainerView.frame.origin.x
            timeLabel.frame.origin.x = containerLeft
            timeLabel.textAlignment = .left
            readimgView.frame.origin.x = timeLabel.frame.origin.x + timeLabel.frame.width
            indicator.frame.origin.x = timeLabel.frame.origin.x - m
            
        } else {
            let containerRight = messageContainerView.frame.origin.x + messageContainerView.frame.width
            timeLabel.frame.origin.x = containerRight - timeLabel.frame.width
            timeLabel.textAlignment = .left
            indicator.frame.origin.x = timeLabel.frame.origin.x + timeLabel.frame.width + m
        }
    }
    
}
