//
//  ChatMessageService.swift
//  PlateChat
//
//  Created by cano on 2018/08/26.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase

enum ChatMessageBindError: Error {
    case error(Error?)
    case noExistsError
}

enum PostChatMessageError: Error {
    case error(Error?)
}

enum ChatMessageBindStatus: String {
    case loading
    case done
    case failed
    case none
}

class ChatMessageService {
    private let store   = Firestore.firestore()
    //private
    var bindTalkHandler: ListenerRegistration?
    private let chatRoom: ChatRoom
    private let limit = 20          // １ページあたりの表示数 仮の値
    private var lastChatMessageDocument: QueryDocumentSnapshot? // クエリカーソルの開始点
    private var status: ChatMessageBindStatus
    private let compressibility: CGFloat = 0.9   // jpeg圧縮率
    private var bindUpdateChatHandler: ListenerRegistration?

    init(_ chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        self.lastChatMessageDocument = nil
        self.status = .none
    }

    deinit {
        bindTalkHandler?.remove()
        bindUpdateChatHandler?.remove()
    }

    func removeSnapshotListener() {
        bindTalkHandler?.remove()
        bindUpdateChatHandler?.remove()
    }

    func bindChatMessage(callbackHandler: @escaping ([ChatMessage]?, ChatMessageBindError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //guard let chatRoomKey: String = self.chatRoom.key else { return }
        let chatRoomKey: String = self.chatRoom.key
        
        if self.status == .loading { return }
        self.status = .loading

        let query: Query
        if let lastDocument = self.lastChatMessageDocument {
            query = self.store
                .collection("/chat_room/\(chatRoomKey)/messages/")
                .order(by: "created_at", descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: limit)
        } else {
            query = self.store
                .collection("/chat_room/\(chatRoomKey)/messages/")
                .order(by: "created_at", descending: true)
                .limit(to: limit)
        }

        bindTalkHandler = query.addSnapshotListener(includeMetadataChanges: true) { [weak self] (querySnapshot, error) in
            if let error = error {
                self?.status = .failed
                callbackHandler(nil, .error(error))
                return
            }

            guard let snapshot = querySnapshot else {
                self?.status = .failed
                callbackHandler(nil, .noExistsError)
                return
            }

            self?.lastChatMessageDocument = snapshot.documents.last
            do {
                let messages = try snapshot.documents.compactMap { try ChatMessage(from: $0) }.sorted(by: { $0.sentDate < $1.sentDate})
                self?.status = .done
                callbackHandler(messages, nil)
            } catch {
                self?.status = .failed
                callbackHandler(nil, .error(error))
            }
        }
    }

    func postChatMessage(text: String, callbackHandler: @escaping (PostChatMessageError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //guard let chatRoomKey: String = self.chatRoom.key else { return }
        
        let chatRoomKey: String = self.chatRoom.key
        var unreads = self.chatRoom.members
        unreads[uid] = false
        let data: [String: Any] = [
            "sender"    : uid,
            "text"      : text,
            "created_at": FieldValue.serverTimestamp(),
            "status"    : 1,
            "unreads"   : unreads
        ]
        self.store.collection("/chat_room/\(chatRoomKey)/messages/").addDocument(data: data) { error in
            if let error = error {
                callbackHandler(.error(error))
                return
            }
            callbackHandler(nil)
        }
    }

    func updateChatMessageUnread(chatMessage: ChatMessage, callbackHandler: @escaping (PostChatMessageError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //guard let chatRoomKey = self.chatRoom.key else { return }
        let chatRoomKey = self.chatRoom.key
        
        var unreads = chatMessage.unreads
        let trues = unreads.filter { $0.1 == true }
        if trues.count == 0 || unreads[uid] == false { return }  // 全て既読か自分が既読
        
        unreads[uid] = false
        let data = ["unreads"   : unreads] as [String : Any]
        self.store.collection("/chat_room/\(chatRoomKey)/messages/").document(chatMessage.messageId).setData(data, merge: true, completion: { error in
            if let error = error {
                callbackHandler(.error(error))
                return
            }
            callbackHandler(nil)
        })
    }

    func postImage(_ image: UIImage?, callbackHandler: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid,
              let image = image, let jpeg = image.jpegData(compressionQuality: self.compressibility) else { return }

        let chatRoomKey = self.chatRoom.key
        // 画像アップロード
        let text = "画像を送信しました"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let imageName = self.getRandomString(12)
        let path = "chat_room/\(chatRoomKey)/\(imageName).jpg"
        let imageStoragePath = Storage.storage().reference().child(path)
        imageStoragePath.putData(jpeg, metadata: metadata) { [weak self] _, error in
            if nil != error {
                callbackHandler(error)
                return
            }
            imageStoragePath.downloadURL(completion: { [weak self] url, error in

                guard let imageURL = url else {
                    callbackHandler(error)
                    return
                }
                // 画像アップロード後にチャットの発言としてレコード作成
                var unreads = self?.chatRoom.members
                unreads![uid] = false
                let data: [String: Any] = [
                    "sender"    : uid,
                    "text"      : text,
                    "imageURL"  : imageURL.absoluteString, //"\(Storage.storage().reference())\(path)",
                    "created_at": FieldValue.serverTimestamp(),
                    "status"    : 1,
                    "unreads"   : unreads
                ]

                self?.store.collection("/chat_room/\(chatRoomKey)/messages/").addDocument(data: data) { error in
                    if let error = error {
                        callbackHandler(error)
                        return
                    }
                    let chatRoomService = ChatRoomService()
                    chatRoomService.updateLastChatTime((self?.chatRoom)!, text)
                    callbackHandler(nil)
                }
            })
        }
    }

    private func getRandomString(_ length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }

    // 自分の未読→既読処理
    func updateChatUnreadCounts() {
        guard let uid = Auth.auth().currentUser?.uid, let unreadCounts = chatRoom.unreadCounts else { return }
        if unreadCounts[uid] == 0 { return }
        let chatRoomKey: String = self.chatRoom.key
        
        let query = self.store
            .collection("/chat_room/\(chatRoom.key)/messages/")
            .whereField("unreads.\(uid)", isEqualTo: true)

        bindUpdateChatHandler = query.addSnapshotListener { [weak self] (querySnapshot, error) in
            if let error = error {
                Log.error(error)
                return
            }
            guard let snapshot = querySnapshot else { return }

            var newUnreadCounts = unreadCounts
            guard let count = newUnreadCounts[uid] else { return }
            newUnreadCounts[uid] = snapshot.documents.count < count ? snapshot.documents.count : count      // [uid: 未読数] の配列を作成 キャッシュで戻ることがあるので < 判定を入れておく
            let data = ["updatedAt": FieldValue.serverTimestamp(), "unreadCounts": newUnreadCounts] as [String: Any]
            self?.store.collection("/chat_room").document(chatRoomKey).setData(data, merge: true, completion: { error in
                if let error = error {
                    Log.error(error)
                    return
                }
            })
        }
    }
}
