//
//  ChatPhotoCell.swift
//  matching
//
//  Created by Work on 2017/11/06.
//  Copyright © 2017年 NOWALL, Inc. All rights reserved.
//

import UIKit
import MessageKit
import SDWebImage
//import Nuke
import Firebase

/// A subclass of `MessageContentCell` used to display video and audio messages.
open class ChatPhotoCell: MessageContentCell {

    /// The play button view to display on video messages.
    open lazy var playButtonView: PlayButtonView = {
        let playButtonView = PlayButtonView()
        return playButtonView
    }()

    /// The image view display the media content.
    open var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let indicator: UIActivityIndicatorView = {
        let ind = UIActivityIndicatorView()
        ind.style = .gray
        ind.hidesWhenStopped = true
        ind.isHidden = true
        return ind
    }()

    // 画像を別ウィンドウで閲覧できるか？
    var isVisibleImage: Bool = false

    // MARK: - Methods

    //override
    open class func reuseIdentifier() -> String { return "ChatPhotoCell" /*self.nameOfClass*/ }

    /// Responsible for setting up the constraints of the cell's subviews.

    open func setupConstraints() {
        imageView.fillSuperview()
        //playButtonView.centerInSuperview()
        //playButtonView.constraint(equalTo: CGSize(width: 35, height: 35))
        indicator.centerInSuperview()
    }

    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(indicator)
        messageContainerView.addSubview(imageView)
        //messageContainerView.addSubview(playButtonView)
        setupConstraints()
    }

    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            //fatalError(MessageKitError.nilMessagesDisplayDelegate)
            return
        }
        self.isVisibleImage = false
        self.imageView.image = UIImage()

        switch message.kind {
            /*case .photo(let mediaItem):
             imageView.image = mediaItem.image ?? mediaItem.placeholderImage
             playButtonView.isHidden = true*/
        case .photo(let chatMedia):
            self.loadImage((chatMedia.url?.absoluteString)!)
            playButtonView.isHidden = true
            indicator.isHidden = false
        case .video(let mediaItem):
            imageView.image = mediaItem.image ?? mediaItem.placeholderImage
            playButtonView.isHidden = false
        default:
            break
        }

        displayDelegate.configureMediaMessageImageView(imageView, for: message, at: indexPath, in: messagesCollectionView)
    }

/*
    private func loadImage(_ url: String) {
        indicator.center = messageContainerView.center
        indicator.startAnimating()
        imageView.loadWebImage(url) { [weak self] image in
            self?.indicator.stopAnimating()
            if image == nil {
                /*
                 self?.errorView.isHidden = false
                 self?.errorView.retryHandler = {
                 self?.errorView.isHidden = true
                 self?.loadImage(url)
                 }*/
                return
            }
        }
    }
*/

    private func loadImage(_ url: String) {
        indicator.center = self.imageView.center //messageContainerView.center
        indicator.startAnimating()

        self.imageView.loadWebImage(url, UIImage(), completion: { [weak self] _ in
            self?.indicator.isHidden = true
            self?.indicator.stopAnimating()
            self?.isVisibleImage = true
        })
/*
        self.imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(), options: SDWebImageOptions(rawValue: 0), completed:{[weak self] (image, error, cacheType, imageURL) in
            // Perform operation.
            self?.indicator.stopAnimating()
            self?.indicator.isHidden = true
            self?.isVisibleImage = true
        })
*/
        /*
        let urlString: String = "\(url)"
        let storage = Storage.storage()
        let reference: StorageReference!
        reference = storage.reference(forURL: urlString)
        reference.downloadURL { [weak self] (url, _) in
            guard let url = url else { return }
            self?.indicator.stopAnimating()
            Manager.shared.loadImage(with: url, into: (self?.imageView)!)
            self?.isVisibleImage = true
        }*/
    }
}

extension UIView {

    internal func fillSuperview() {
        guard let superview = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false

        let constraints: [NSLayoutConstraint] = [
            leftAnchor.constraint(equalTo: superview.leftAnchor),
            rightAnchor.constraint(equalTo: superview.rightAnchor),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    internal func centerInSuperview() {
        guard let superview = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    internal func constraint(equalTo size: CGSize) {
        guard superview != nil else { return }
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ]
        NSLayoutConstraint.activate(constraints)

    }

    @discardableResult
    internal func addConstraints(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {

        if self.superview == nil {
            return []
        }
        translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()

        if let top = top {
            let constraint = topAnchor.constraint(equalTo: top, constant: topConstant)
            constraint.identifier = "top"
            constraints.append(constraint)
        }

        if let left = left {
            let constraint = leftAnchor.constraint(equalTo: left, constant: leftConstant)
            constraint.identifier = "left"
            constraints.append(constraint)
        }

        if let bottom = bottom {
            let constraint = bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant)
            constraint.identifier = "bottom"
            constraints.append(constraint)
        }

        if let right = right {
            let constraint = rightAnchor.constraint(equalTo: right, constant: -rightConstant)
            constraint.identifier = "right"
            constraints.append(constraint)
        }

        if widthConstant > 0 {
            let constraint = widthAnchor.constraint(equalToConstant: widthConstant)
            constraint.identifier = "width"
            constraints.append(constraint)
        }

        if heightConstant > 0 {
            let constraint = heightAnchor.constraint(equalToConstant: heightConstant)
            constraint.identifier = "height"
            constraints.append(constraint)
        }

        NSLayoutConstraint.activate(constraints)
        return constraints
    }
}
