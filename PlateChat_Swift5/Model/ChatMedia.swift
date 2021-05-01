//
//  ChatMedia.swift
//  PlateChat
//
//  Created by cano on 2018/08/07.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import FirebaseAuth
import MessageKit

struct ChatMedia: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }

    init(url: URL) {
        self.url = url
        //self.image = UIImage()
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}
