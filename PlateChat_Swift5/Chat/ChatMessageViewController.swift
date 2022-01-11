//
//  MessageViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/23.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import MessageUI
import MessageKit
import Firebase
import MobileCoreServices
import AVFoundation
import SwiftDate
import SafariServices
//import Nuke
import Rswift
import SKPhotoBrowser
import SVProgressHUD

fileprivate extension UIEdgeInsets {
    init(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
}

class ChatMessageViewController: MessagesViewController {

    let cellId = "CellID"
    var messages = [ChatMessage]()
    var chatRoomService = ChatRoomService()
    private var chatMessageService: ChatMessageService!
    var chatRoom: ChatRoom! {
        didSet {
            self.chatMessageService = ChatMessageService(chatRoom)
            self.chatMessageService.updateChatUnreadCounts()        // unread
        }
    }
    var other_uid: String? {
        didSet {
            UserService.getUserInfo(other_uid!, completionHandler: { [weak self] (user, error) in
                if let err = error {
                    self?.showAlert(err.localizedDescription)
                    return
                }
                guard let user = user else{ return }
                self?.title = user.nickname
            })
        }
    }
    private let refreshControl = UIRefreshControl()

    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        //let formatter = DateFormatter(withFormat: "M/d", locale: Locale.current.languageCode ?? "en_US_POSIX")
        //formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: Locale.current.languageCode!)
        formatter.dateFormat = "M/d"
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    lazy var clockFormatter: DateFormatter = {
        let formatter = DateFormatter()
        //let formatter = DateFormatter(withFormat: "M/d", locale: Locale.current.languageCode ?? "en_US_POSIX")
        //formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: Locale.current.languageCode!)
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        //self.navigationItem.rightBarButtonItem =

        self.prepareButtons()

        // 自分のアイコンの表示を消し、その分ラベルを移動させる
        if let layout = self.messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            //layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)

            //layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(left: 10)))
            //layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(left: 10)))
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: insets))
            layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: insets))

            // メッセージのフォント
            layout.textMessageSizeCalculator.messageLabelFont = R.font.notoSansCJKjpSubRegular(size: 12.0)!
        }

        DispatchQueue.main.async {
            // messageListにメッセージの配列をいれて
            //self.messageList = self.getMessages()
            // messagesCollectionViewをリロードして
            self.messagesCollectionView.reloadData()
            // 一番下までスクロールする
            self.messagesCollectionView.scrollToBottom()
        }
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self

        messageInputBar.delegate = self

        // メッセージ入力時に一番下までスクロール
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        messagesCollectionView.register(ChatMessageKitCell.self)
        messagesCollectionView.register(ChatPhotoCell.self)

        // メッセージ表示
        self.observeMessages(callbackHandler: { self.messagesCollectionView.scrollToBottom() })
        self.messagesCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(ChatMessageViewController.refresh(sender:)), for: .valueChanged)

        setupMessageInputBarButtons()
        /*
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event.map{ $0 }
            .subscribe(onNext: {
                print("gestureのtapイベントを取得")
            })
            .disposed(by: rx.disposeBag)
        messagesCollectionView.addGestureRecognizer(tapGesture)*/
        messagesCollectionView.keyboardDismissMode = .onDrag
    }

    func prepareButtons() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"back"), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem?.rx.tap.asDriver().drive(onNext: { [unowned self] in
            self.chatMessageService.bindTalkHandler?.remove()
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)

        let menuButton = UIBarButtonItem(image: UIImage(named:"menu"), style: .plain, target: self, action: nil)

        let profileImageButton = UIButton(type: .custom)
        profileImageButton.frame = CGRect(x: 0, y: 0, width: 30.0, height: 30.0)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.imageView?.frame = CGRect(x: 0, y: 0, width: 30.0, height: 30.0)
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.borderWidth = 1
        profileImageButton.borderColor = UIColor.rgba(205, 205, 205)
        profileImageButton.layer.cornerRadius = profileImageButton.frame.size.width * 0.5
        profileImageButton.clipsToBounds = true

        if let profile_image_url = UsersData.profileImages[other_uid!] {
            profileImageButton.sd_setImage(with: URL(string:profile_image_url), for: .normal) { (image, error, cacheType, url) in
                guard let image = image else { return }
                profileImageButton.setImage(image.resize(size: profileImageButton.bounds.size), for: .normal)
                if error != nil {
                    profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                }
            }
        }
        profileImageButton.rx.tap.asDriver().drive(onNext: { [unowned self] _ in
            let vc = R.storyboard.uderDetail.userDetailViewController()!
            vc.uid = self.other_uid
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        let profileButton = UIBarButtonItem(customView: profileImageButton)

        self.navigationItem.rightBarButtonItems = [profileButton ,menuButton]

        let actions = [ActionSheetAction<UserMenu>(title: "ブロック", actionType: .block,
                                                   style: .default),
                       ActionSheetAction<UserMenu>(title: "通報", actionType: .report,
                                                   style: .default)
        ]
        menuButton.rx.tap.asDriver().drive(onNext: { [unowned self] _ in
            self.showActionSheet(title: "", message: "Menu", actions: actions).subscribe({ [unowned self] event in
                if let sourceType = event.element {
                    switch sourceType {
                    case .block:
                        self.showAlertOKCancel("確認", "このユーザーをブロックしますか？", "はい", "いいえ") { _ in
                            self.blockUser(other_uid: self.other_uid!)
                        }
                    case .report:
                        self.reportUser(other_uid: self.other_uid!)
                    }
                }
            })
        }).disposed(by: rx.disposeBag)
    }

    private func blockUser(other_uid: String) {
        SVProgressHUD.show(withStatus: "Loading...")

        UserBlockService.addBlockUser(other_uid, completionHandler: { [unowned self] (_, error) in
            if let error = error {
                Log.error(error)
                SVProgressHUD.dismiss()
                return
            }
            UserBlockedService.addBlockedUser(other_uid, completionHandler: { [unowned self] (_, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    Log.error(error)
                    return
                }
                self.navigationController?.popViewController(animated: true)
            })
        })
    }

    func reportUser(other_uid: String) {
        if MFMailComposeViewController.canSendMail() {
            guard let nickName = UsersData.nickNames[other_uid] else { return }

            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([Constants.adminEmail]) // 宛先アドレス
            mail.setSubject("通報！") // 件名
            let body = "\(other_uid)\n\(nickName) さんに関する通報です。\n-------------------\n ＊この下に通報内容をお書きください。\n\n"
            mail.setMessageBody(body, isHTML: false) // 本文
            present(mail, animated: true, completion: nil)
        } else {
            print("送信できません")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.networkChecking()
        
        self.setStatusBarBackgroundColor()
        self.setAppearance()
    }
    
    func setupMessageInputBarButtons() {
        let height: CGFloat = 28  // 送信ボタンと同じ高さ
        let button = InputBarButtonItem().configure {
            $0.setSize(CGSize(width: height, height: height), animated: false)
            $0.isEnabled = true
            $0.setImage(UIImage(named: "camera"), for: .normal)
            }.onTouchUpInside { [weak self] _ in
                //self?.messageInputBar.inputTextView.becomeFirstResponder()
                //button.setImage(UIImage(named: "text-icon-selected"), for: .normal)
                ActionSheet(title: "写真を送る", message: nil)
                    .addAction("写真を撮る") { self?.selectCamera() }
                    .addAction("フォトアルバムから選ぶ") { self?.selectPhotoLibrary() }
                    .setCancelAction("キャンセル")
                    .show(self!)
        }
        messageInputBar.leftStackView.addArrangedSubview(button)
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        messageInputBar.leftStackView.addArrangedSubview(spacerView)
        var leftStackViewWidth: CGFloat {
            return 40//self.view.frame.width - ( messageInputBar.padding.left + button.frame.width + messageInputBar.rightStackViewWidthConstant + messageInputBar.padding.right + 200)
        }
        messageInputBar.setLeftStackViewWidthConstant(to: height+10, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.inputTextView.placeholder = ""
        messageInputBar.inputTextView.layer.cornerRadius = 8
        messageInputBar.inputTextView.layer.borderColor = UIColor.lightGray.cgColor
        //messageInputBar.inputTextView.delegate = self
        messageInputBar.inputTextView.font = R.font.notoSansCJKjpSubRegular(size: 12.0)!
        messageInputBar.sendButton.tintColor = UIColor.black
        messageInputBar.sendButton.setTitleColor(UIColor.black, for: .normal)

        var keyboardToolBar: UIView {
                let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                toolbar.barStyle = UIBarStyle.default
                toolbar.bounds.size.height = 28

            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

            let done: UIBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.done, target: self, action: nil)
                done.tintColor = UIColor.black
                done.rx.tap.asDriver().drive(onNext: { [unowned self] in
                    self.messageInputBar.inputTextView.resignFirstResponder()
                }).disposed(by: rx.disposeBag)
            let clear: UIBarButtonItem = UIBarButtonItem(title: "Clear", style: UIBarButtonItem.Style.plain, target: self, action: nil)
                clear.tintColor = UIColor.black
                clear.rx.tap.asDriver().drive(onNext: { [unowned self] in
                    self.messageInputBar.inputTextView.text = ""
                }).disposed(by: rx.disposeBag)

                var items = [UIBarButtonItem]()

                items.append(clear)
                items.append(flexSpace)
                items.append(done)
                toolbar.items = items
                toolbar.sizeToFit()
                return toolbar
        }
        //messageInputBar.inputTextView.inputAccessoryView = keyboardToolBar
    }

    func observeMessages(callbackHandler: @escaping () -> Void) {
        chatMessageService.bindChatMessage(callbackHandler: { [weak self] (chatMessageModels, error) in
            switch error {
            case .none:
                if let models = chatMessageModels {
                    let preMessageCount = self?.messages.count
                    self?.messages = models + (self?.messages)! // キャッシュのせいかたまに重複することがあるのでユニークにしておく
                    self?.messages = (self?.messages.unique { $0.messageId == $1.messageId }.sorted(by: { $0.sentDate < $1.sentDate}))!
/*
                    if preMessageCount == self?.messages.count {  // 更新数チェック
                        self?.refreshControl.endRefreshing()
                        return
                    }*/
                    DispatchQueue.main.async {
                        self?.messagesCollectionView.reloadData()
                        callbackHandler()
                    }
                }
            case .some(.error(let error)):
                Log.error(error!)
            case .some(.noExistsError):
                Log.error("データ見つかりません")
            }
            self?.refreshControl.endRefreshing()
        })
    }

    @objc func refresh(sender: UIRefreshControl) {
        if  messages.count == 0 {
            self.refreshControl.endRefreshing()
            return
        }
        self.observeMessages(callbackHandler: { self.refreshControl.endRefreshing() })
    }


    override func viewWillDisappear(_ animated: Bool) {
        self.chatMessageService.removeSnapshotListener()  // 一覧へ戻る際にSnapshotのリスナーを止める
        super.viewWillDisappear(animated)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        let message = self.messageForItem(at: indexPath, in: messagesCollectionView)

        if let unreds = (message as! ChatMessage).unreads as? [String: Bool] {
            if unreds[AccountData.uid!]! == true {
            self.chatMessageService.updateChatMessageUnread(chatMessage: message as! ChatMessage, callbackHandler: { [weak self] error in
                if let error = error {
                    Log.error(error)
                    return
                }
                //self?.chatRoomService.updateLastChatTime((self?.chatRoom)!)
            })
        }
        }
        switch message.kind {
        case .text, .attributedText, .emoji:
            let cell = messagesCollectionView.dequeueReusableCell(TextMessageCell.self, for: indexPath)
            //let cell = messagesCollectionView.dequeueReusableCell(ChatMessageKitCell.self, for: indexPath)
            //cell.messageLabel.mes//font = R.font.notoSansCJKjpSubRegular(size: 12.0)!
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .photo, .video:
            //let cell = messagesCollectionView.dequeueReusableCell(MediaMessageCell.self, for: indexPath)
            let cell = messagesCollectionView.dequeueReusableCell(ChatPhotoCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .location:
            let cell = messagesCollectionView.dequeueReusableCell(LocationMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .custom:
            //fatalError(MessageKitError.customDataUnresolvedCell)
            return UICollectionViewCell()
        }
    }

}

extension ChatMessageViewController {
    // カメラ選択
    fileprivate func selectCamera() {
        PhotoRequester.requestPhotoFromCamera(self) { [weak self] result in
            switch result {
            case .success(let image):
                self?.showLoading()
                self?.chatMessageService.postImage(image, callbackHandler: {[weak self] error in
                    if let error = error {
                        Log.error(error)
                        self?.hideLoading()
                        return
                    }
                    self?.aftterImagePost()
                })
            case .faild:
                self?.showAlert("カメラへアクセスできません", "設定アプリにてカメラへのアクセス許可してください")
            case .cancel:
                break
            }
        }
    }

    // 画像選択
    fileprivate func selectPhotoLibrary() {
        PhotoRequester.requestPhotoLibrary(self) { [weak self] result in
            switch result {
            case .success(let image):
                self?.showLoading()
                self?.chatMessageService.postImage(image, callbackHandler: {[weak self] error in
                    if let error = error {
                        Log.error(error)
                        self?.hideLoading()
                        return
                    }
                    self?.aftterImagePost()
                })
            case .faild:
                self?.showAlert("フォトアルバムへアクセスできません", "設定アプリにてフォトアルバムへのアクセスを許可してください")
            case .cancel:
                break
            }
        }
    }

    // 画像投稿後にメッセージ画面に戻った場合、下のスクロールが少しずれるので調整
    fileprivate func aftterImagePost() {
        DispatchQueue.main.async {
            self.chatRoomService = ChatRoomService()
            self.chatRoomService.updateLastChatTime(self.chatRoom, "画像を投稿しました")
            self.chatMessageService = ChatMessageService(self.chatRoom)
            self.chatMessageService.updateChatUnreadCounts()
            self.observeMessages(callbackHandler: { [weak self] in
                //self?.messagesCollectionView.reloadData()
                //self?.messagesCollectionView.scrollToBottom()
                self?.messageInputBar.inputTextView.becomeFirstResponder()
                self?.messageInputBar.inputTextView.resignFirstResponder()
                self?.hideLoading()
            })
        }
    }
}

extension ChatMessageViewController: MessagesDataSource {

    func isFromCurrentSender(message: MessageType) -> Bool {
        //return message.sender == currentSender()
        return message.sender.id == (Auth.auth().currentUser?.uid)!
    }

    func currentSender() -> Sender {
        //return Sender(id: "123", displayName: "自分")
        return Sender(id: Auth.auth().currentUser!.uid, displayName: "")
    }

    func otherSender() -> Sender {
        return Sender(id: "", displayName: "")
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    // メッセージの上に文字を表示
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        var dateFlg = false
        if indexPath.section % 5 == 0 {
            dateFlg = true
        } else {
            let preMessage = self.messages[indexPath.section-1]
            dateFlg = formatter.string(from: preMessage.sentDate) != formatter.string(from: message.sentDate)
        }
        //if indexPath.section % 3 == 0 {
        if dateFlg {
            let stringAttributes1: [NSAttributedString.Key : Any] = [
                .foregroundColor : UIColor.clear,
                //.font : UIFont.systemFont(ofSize: 10.0),
                .font : R.font.notoSansCJKjpSubRegular(size: 10.0)!
            ]
            let string1 = NSMutableAttributedString(string: "----------", attributes: stringAttributes1)
            string1.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: 10))
            string1.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.lightGray, range: NSRange(location: 0, length: 10))
            let calendar = Calendar(identifier: .gregorian)
            let weekdayIndex = calendar.component(Calendar.Component.weekday, from: message.sentDate)-1
            let string2 = NSAttributedString(
                string: " \(formatter.string(from: message.sentDate))(\(formatter.shortWeekdaySymbols[weekdayIndex])) ",
                attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                             NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
            let mutableAttributedString = NSMutableAttributedString()
            mutableAttributedString.append(string1)
            mutableAttributedString.append(string2)
            mutableAttributedString.append(string1)
            return mutableAttributedString
        }

        return nil
    }
    /*
     // メッセージの上に文字を表示（名前）
     func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
     let name = message.sender.displayName
     return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
     }
     */
    // メッセージの下に文字を表示（日付）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = clockFormatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// メッセージのdelegate
extension ChatMessageViewController: MessagesDisplayDelegate {

    // メッセージの色を変更（デフォルトは自分：白、相手：黒）
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    // メッセージの背景色を変更している（デフォルトは自分：緑、相手：グレー）
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
            //UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
            UIColor.hexStr(hexStr: "#58CE91", alpha: 1.0) : 
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }

    // メッセージの枠にしっぽを付ける
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    // アイコンをセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // 自分のアイコンは表示しない
        if isFromCurrentSender(message: message) { return }
        
        avatarView.image = R.image.personIcon()!
        avatarView.backgroundColor = .clear
        if let url = UsersData.profileImages[message.sender.id] {
            if url != "" {
                avatarView.sd_setImage(with: URL(string: url)!, completed: nil)
            }
        } else {
            UserService.getUserInfo(message.sender.id, completionHandler: { (user, error) in
                guard let url = user?.profile_image_url else {
                    Log.error(error!)
                    return
                }
                avatarView.sd_setImage(with: URL(string: url)!, completed: nil)
            })
        }
    }

    // リンクメッセージの場合青色、下線の設定
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {

        let detectorAttributes: [NSAttributedString.Key: Any] = {
            [
                NSAttributedString.Key.foregroundColor: UIColor.blue,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.underlineColor: UIColor.blue,
                NSAttributedString.Key.font: R.font.notoSansCJKjpSubRegular(size: 12.0)!
            ]
        }()

        MessageLabel.defaultAttributes = detectorAttributes
        return MessageLabel.defaultAttributes
    }

    // メッセージのURLをリンクとして判定
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url]
    }
}

// 各ラベルの高さを設定（デフォルト0なので必須）
extension ChatMessageViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        //if indexPath.section % 3 == 0 { return 10 }

        var dateFlg = false
        if indexPath.section % 5 == 0 {
            dateFlg = true
        } else {
            let preMessage = self.messages[indexPath.section-1]
            dateFlg = formatter.string(from: preMessage.sentDate) != formatter.string(from: message.sentDate)
        }
        if dateFlg {
            return 15
        }
        return 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension ChatMessageViewController: MessageCellDelegate {
    // メッセージをタップした時の挙動
    func didTapMessage(in cell: MessageCollectionViewCell) {
        if let cell = cell as? ChatPhotoCell, let image = cell.imageView.image {
            //if !cell.isVisibleImage { return }
            // SKPhotoBrowserを利用して別ウィンドウで開く
            var images = [SKPhoto]()
            let photo = SKPhoto.photoWithImage(image)
            images.append(photo)
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(0)
            self.present(browser, animated: true, completion: {})
        }
    }
}

// MARK: - MessageLabelDelegate

extension ChatMessageViewController: MessageLabelDelegate {

    func didSelectAddress(_ addressComponents: [String : String]) {
        print("Address Selected: \(addressComponents)")
    }

    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }

    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }

    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")

        // 念のため開ける形式か判定
        guard UIApplication.shared.canOpenURL(url) else { return }
        //メールアドレスと弾く
        if url.absoluteString.hasPrefix("mailto") { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }

}

extension ChatMessageViewController: MessageInputBarDelegate {
    // メッセージ送信ボタンをタップした時の挙動
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {
                /*
                 let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                 messageList.append(imageMessage)
                 messagesCollectionView.insertSections([messageList.count - 1])
                 */
            } else if let text = component as? String {

                self.chatMessageService.postChatMessage(text: text, callbackHandler: { [weak self] error in
                    if let error = error {
                        Log.error(error)
                        return
                    }
                    self?.chatRoomService.updateLastChatTime((self?.chatRoom)!, text)
                    DispatchQueue.main.async {
                        self?.messageInputBar.inputTextView.text = ""
                        self?.messageInputBar.inputTextView.resignFirstResponder()
                        self?.messagesCollectionView.reloadData()
                        self?.messagesCollectionView.scrollToBottom()
                    }
                })
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}

extension ChatMessageViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("キャンセル")
        case .saved:
            print("下書き保存")
        case .sent:
            print("送信成功")
            self.showAlert("送信しました")
        default:
            print("送信失敗")
        }
        dismiss(animated: true, completion: nil)
    }
}
