//
//  ChatMessage.swift
//  PlateChat
//
//  Created by cano on 2018/08/07.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase
import MessageKit

class ChatMessage: MessageType {

    enum Status: String {
        case success
        case sending
        case failed
    }

    // MessageKit MessageType variables
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var kind: MessageKind
    // MessageKit MessageType variables

    let unreads: [String: Bool]
    var status: Int

    init(kind: MessageKind, sender: Sender, messageId: String, date: Date, unreads: [String: Bool], status: Int) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.unreads = unreads
        self.status = status
    }

    init(from document: DocumentSnapshot) throws {
        guard
            let senderId = document.get("sender") as? String,
            let status  = document.get("status") as? Int
            else { throw ModelError.parseError }

        // MessageKit object
        self.messageId = document.documentID
        self.sender    = Sender(id: senderId, displayName: "")
        self.sentDate  = (document.get("created_at") as? Timestamp)?.dateValue() ?? Date()
        self.kind      = MessageKind.text("")
        self.unreads  = (document.get("unreads") as? [String: Bool]) ?? ["": false]
        self.status    = status

        // メッセーッジがテキストか画像か分ける
        let text = document.get("text") as? String
        let imageUrl = document.get("imageURL") as? String
        if let text = text {
            self.kind      = MessageKind.text(text)
        }
        if let imageUrl = imageUrl {
            self.kind = .photo(ChatMedia(url: URL(string: imageUrl)!))
        }
        
        // サーバーに保存できていないければ送信中とする
        //self.status = document.metadata.isFromCache && document.metadata.hasPendingWrites ? .sending : .success
    }
    /*
    func chatPartnerId() -> String {
        return (fromId == Auth.auth().currentUser?.uid ? toId : fromId)!
    }
    */
}

extension ChatMessage: Equatable {
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}
