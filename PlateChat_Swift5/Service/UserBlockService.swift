//
//  UserBlockService.swift
//  PlateChat
//
//  Created by cano on 2018/09/01.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

enum UserBlockServiceFetchError: Error {
    case fetchError(Error?)
    case noExistsError
}

enum UserBlockServiceUpdateError: Error {
    case updateError(Error?)
    case fetchError(Error?)
}

struct UserBlockService {

    // なぜか無限ループになるのでaddSnapshotListenerを使う場合はメソッドを分ける
    static func syncBlockUser(completionHandler: @escaping (_ userBlock: UserBlock?, _ error: UserBlockServiceFetchError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let documentRef = Firestore.firestore().collection("user_block").document(uid)
        documentRef//.getDocument { (document, error) in
            .addSnapshotListener { document, error in
                if error != nil {
                    completionHandler(nil, .fetchError(error))
                } else if let document = document, document.exists {
                    do {
                        let userBlock = try UserBlock(from: document)
                        UsersData.userBlock = userBlock.members         // ud
                        completionHandler(userBlock, nil)
                    } catch {
                        completionHandler(nil, .fetchError(error))
                    }
                } else {
                    completionHandler(nil, .fetchError(error))
                }
        }
    }

    static func getBlockUser(completionHandler: @escaping (_ userBlock: UserBlock?, _ error: UserBlockServiceFetchError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let documentRef = Firestore.firestore().collection("user_block").document(uid)
        documentRef.getDocument { (document, error) in
            //.addSnapshotListener { document, error in
            if error != nil {
                completionHandler(nil, .fetchError(error))
            } else if let document = document, document.exists {
                do {
                    let userBlock = try UserBlock(from: document)
                    UsersData.userBlock = userBlock.members         // ud
                    completionHandler(userBlock, nil)
                } catch {
                completionHandler(nil, .fetchError(error))
                }
            } else {
                completionHandler(nil, .fetchError(error))
            }
        }
    }

    static func addBlockUser(_ other_uid: String, completionHandler: @escaping (_ userBlock: UserBlock?, _ error: UserBlockServiceUpdateError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        self.getBlockUser(completionHandler:{ (userBlock, error) in
            var members: [String: Bool] = ["": true]
            if let userBlock = userBlock {
                members = userBlock.members
            }
            members[other_uid] = true
            let data = ["members"    :   members.filter {$0.0 != ""} ]
            Firestore.firestore().collection("user_block").document(uid).setData(data, merge: true,  completion: { error in

                if let error = error {
                    completionHandler(nil, .fetchError(error))
                    return
                }
                UsersData.userBlock = data["members"]!         // ud
                completionHandler(userBlock, nil)
            })
        })
    }

    static func releaseBlockUser(_ other_uid: String, completionHandler: @escaping (_ userBlock: UserBlock?, _ error: UserBlockServiceUpdateError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        self.getBlockUser(completionHandler:{ (userBlock, error) in
            var members: [String: Bool] = ["": true]
            if let userBlock = userBlock {
                members = userBlock.members
            }
            members[other_uid] = false
            let data = ["members"    :   members.filter {$0.0 != ""} ]
            Firestore.firestore().collection("user_block").document(uid).setData(data, merge: true,  completion: { error in

                if let error = error {
                    completionHandler(nil, .fetchError(error))
                    return
                }
                UsersData.userBlock = data["members"]!         // ud
                completionHandler(userBlock, nil)
            })
        })
    }
}
