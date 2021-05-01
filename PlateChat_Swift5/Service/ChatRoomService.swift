//
//  ChatRoomService.swift
//  PlateChat
//
//  Created by cano on 2018/08/26.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

enum ChatRoomBindStatus: String {
    case loading
    case done
    case failed
    case none
}

enum ChatRoomBindError: Error {
    case error(Error?)
    case noExistsError
}

enum ChatRoomServiceUpdateError: Error {
    case updateError(Error?)
}

enum PostChatRoomError: Error {
    case error(Error?)
}

class ChatRoomService {

    private let store   = Firestore.firestore()
    private let storage = Storage.storage()
    private var bindChatRoomHandler: ListenerRegistration?
    private let limit = 1000          // １ページあたりの表示数 仮の値
    private var lastChatRoomDocument: QueryDocumentSnapshot? // クエリカーソルの開始点
    private var status: ChatRoomBindStatus

    init() {
        self.lastChatRoomDocument = nil
        self.status = .none
    }

    func bindChatRoom(callbackHandler: @escaping ([ChatRoom]?, ChatRoomBindError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        if self.status == .loading { return }
        self.status = .loading

        let query: Query
        if let lastDocument = self.lastChatRoomDocument {
            query = self.store
                .collection("/chat_room/")
                .whereField("members.\(uid)", isEqualTo: true)
                //.whereField("status", isEqualTo: 1)
                //.order(by: "updated_at", descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: limit)
        } else {
            query = self.store
                .collection("/chat_room/")
                .whereField("members.\(uid)", isEqualTo: true)
                //.whereField("status", isEqualTo: 1)
                //.order(by: "updated_at", descending: true)
                .limit(to: limit)
        }

        bindChatRoomHandler = query.addSnapshotListener(includeMetadataChanges: true) { [weak self] (querySnapshot, error) in
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

            self?.lastChatRoomDocument = snapshot.documents.last
            do {
                let chatrooms = try snapshot.documents.compactMap { try ChatRoom(from: $0) }.sorted(by: { $0.updated_date < $1.updated_date}).filter { $0.status == 1 }
                self?.status = .done
                callbackHandler(chatrooms, nil)
            } catch {
                self?.status = .failed
                callbackHandler(nil, .error(error))
            }
        }
    }

    func removeBindChatRoomList() {
        self.bindChatRoomHandler?.remove()
        self.lastChatRoomDocument = nil
    }

    // 作成
    func cerateChatRoom (_ other_uid: String, _ completionHandler: @escaping (_ chatRoom: ChatRoom?, _ error: ChatRoomServiceUpdateError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if uid == other_uid { return }

        let query = self.store.collection("chat_room")
            .whereField("members.\(uid)", isEqualTo: true)
            .whereField("members.\(other_uid)", isEqualTo: true)
            .whereField("status", isEqualTo: 1)
            //.order(by: "created_at", descending: true)

        query.addSnapshotListener(includeMetadataChanges: false) { (querySnapshot, error) in
        //query.getDocuments() { (querySnapshot, error) in // 何故か作成後に動かない
            do {
                if let snapshot = querySnapshot {
                    if snapshot.count == 0 {
                        var data = [String: Any]()
                        data["owner"]               = uid
                        data["members"]             = [uid: true, other_uid: true]
                        data["unreadCounts"]        = [uid: 0, other_uid: 0]
                        data["created_at"]          = FieldValue.serverTimestamp()
                        data["updated_at"]          = FieldValue.serverTimestamp()
                        data["status"]              = 1
                        data["last_update_message"] = ""

                        self.store.collection("chat_room").addDocument(data:data, completion: {
                            error in
                            if let err = error {
                                print("Error adding document: \(err)")
                                completionHandler(nil, .updateError(error))
                                return
                            }

                            query.getDocuments() { (docSnapshot, error) in
                                if let err = error {
                                    print("Error adding document: \(err)")
                                    completionHandler(nil, .updateError(error))
                                    return
                                }
                                if let snapshot = querySnapshot, snapshot.count > 0 {
                                do{
                                    let chatRoom = try snapshot.documents.compactMap{ try ChatRoom(from: $0) }
                                    completionHandler(chatRoom[0],nil)
                                } catch {}
                                    completionHandler(nil,nil)
                                }
                            }
                        })
                    } else {
                        do{
                            let chatRoom = try snapshot.documents.compactMap{ try ChatRoom(from: $0) }
                            completionHandler(chatRoom[0],nil)
                        } catch {}
                    }
                }
            }
            if let _ = error {
                completionHandler(nil, .updateError(error))
            }
        }
    }

    // 各メンバーの未読数＆最終更新日時更新
    func updateLastChatTime(_ chatRoom: ChatRoom, _ text: String? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var data = ["updated_at": FieldValue.serverTimestamp()] as [String: Any]
        if let text = text {
            data["last_update_message"] = text
        }
        print( data)
        print(chatRoom.key)
        self.store.collection("/chat_room/").document(chatRoom.key).setData(data, merge: true, completion: { error in
            if let error = error {
                Log.error(error)
                return
            }
        })

        /*
        var unreadCounts = [String: Int]()
        for uid in chatRoom.members.keys {
            self.store
                .collection("/chat_room/\(chatRoom.key)/messages/")
                .whereField("unreads.\(uid)", isEqualTo: true)
                .getDocuments(completion: { [weak self] (querySnapshot, error) in
                //.addSnapshotListener(includeMetadataChanges: true) { [weak self] (querySnapshot, error) in
                    if let error = error {
                        Log.error(error)
                        return
                    }
                    guard let snapshot = querySnapshot else { return }
                    unreadCounts[uid] = snapshot.documents.count
                    if unreadCounts.count == chatRoom.members.count {
                        var data = ["updated_at": FieldValue.serverTimestamp(), "unreadCounts": unreadCounts] as [String: Any]
                        if let text = text {
                            data["last_update_message"] = text
                        }
                        print( data)
                        print(chatRoom.key)
                        self?.store.collection("/chat_room/").document(chatRoom.key).setData(data, merge: true, completion: { error in
                            if let error = error {
                                Log.error(error)
                                return
                            }
                        })
                    }
            })
        }
        */
    }
}
