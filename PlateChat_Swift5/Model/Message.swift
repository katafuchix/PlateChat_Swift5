//
//  Message.swift
//  PlateChat
//
//  Created by cano on 2018/08/07.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import FirebaseAuth

class Message {

    @objc var fromId: String?
    @objc var text: String?
    @objc var timeStamp: NSNumber?
    @objc var toId: String?
    @objc var imageUrl: String?
    @objc var imageWidth: NSNumber?
    @objc var imageHeight: NSNumber?
    @objc var videoUrl: String?

    func chatPartnerId() -> String {
        return (fromId == Auth.auth().currentUser?.uid ? toId : fromId)!
    }
}
