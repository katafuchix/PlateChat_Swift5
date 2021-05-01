//
//  UserBlockedService.swift
//  PlateChat
//
//  Created by cano on 2018/09/01.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

enum UserBlockedServiceFetchError: Error {
    case fetchError(Error?)
    case noExistsError
}

enum UserBlockedServiceUpdateError: Error {
    case updateError(Error?)
    case fetchError(Error?)
}

struct UserBlockedService {

    // なぜか無限ループになるのでaddSnapshotListenerを使う場合はメソッドを分ける
    static func syncBlockedUser(_ other_uid: String, completionHandler: @escaping (_ userBlocked: UserBlocked?, _ error: UserBlockServiceFetchError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let documentRef = Firestore.firestore().collection("user_blocked").document(other_uid)
        documentRef//.getDocument { (document, error) in
            .addSnapshotListener { document, error in
                if error != nil {
                    completionHandler(nil, .fetchError(error))
                } else if let document = document, document.exists {
                    do {
                        let userBlocked = try UserBlocked(from: document)
                        if other_uid == AccountData.uid {
                            UsersData.userBlocked = userBlocked.members         // ud
                        }
                        completionHandler(userBlocked, nil)
                    } catch {
                        completionHandler(nil, .fetchError(error))
                    }
                } else {
                    completionHandler(nil, .fetchError(error))
                }
        }
    }

    static func getBlockedUser(_ other_uid: String, completionHandler: @escaping (_ userBlocked: UserBlocked?, _ error: UserBlockServiceFetchError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let documentRef = Firestore.firestore().collection("user_blocked").document(other_uid)
        documentRef.getDocument { (document, error) in
            //.addSnapshotListener { document, error in
            if error != nil {
                completionHandler(nil, .fetchError(error))
            } else if let document = document, document.exists {
                do {
                    let userBlocked = try UserBlocked(from: document)
                    if other_uid == AccountData.uid {
                        UsersData.userBlocked = userBlocked.members         // ud
                    }
                    completionHandler(userBlocked, nil)
                } catch {
                    completionHandler(nil, .fetchError(error))
                }
            } else {
                completionHandler(nil, .fetchError(error))
            }
        }
    }

    static func addBlockedUser(_ other_uid: String, completionHandler: @escaping (_ userBlocked: UserBlocked?, _ error: UserBlockServiceUpdateError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        self.getBlockedUser(other_uid, completionHandler:{ (userBlocked, error) in
            var members: [String: Bool] = ["": true]
            if let userBlocked = userBlocked {
                members = userBlocked.members
            }
            members[uid] = true
            let data = ["members"    :   members.filter { $0.0 != "" }]
            Firestore.firestore().collection("user_blocked").document(other_uid).setData(data, merge: true,  completion: { error in

                if let error = error {
                    completionHandler(nil, .fetchError(error))
                    return
                }
                if other_uid == AccountData.uid {
                    UsersData.userBlocked = data["members"]!         // ud
                }
                completionHandler(userBlocked, nil)
            })
        })
    }

    static func releaseBlockedUser(_ other_uid: String, completionHandler: @escaping (_ userBlocked: UserBlocked?, _ error: UserBlockServiceUpdateError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        self.getBlockedUser(other_uid, completionHandler:{ (userBlocked, error) in
            var members: [String: Bool] = ["": true]
            if let userBlocked = userBlocked {
                members = userBlocked.members
            }
            members[uid] = false
            let data = ["members"    :   members.filter { $0.0 != "" }]
            Firestore.firestore().collection("user_blocked").document(other_uid).setData(data, merge: true,  completion: { error in

                if let error = error {
                    completionHandler(nil, .fetchError(error))
                    return
                }
                if other_uid == AccountData.uid {
                    UsersData.userBlocked = data["members"]!         // ud
                }
                completionHandler(userBlocked, nil)
            })
        })
    }
}
