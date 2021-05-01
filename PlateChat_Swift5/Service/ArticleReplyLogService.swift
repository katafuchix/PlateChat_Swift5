//
//  ArticleReplyLogService.swift
//  PlateChat
//
//  Created by cano on 2018/09/24.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

enum ArticleReplyLogFetchError: Error {
    case fetchError(Error?)
    case noExistsError
}

enum ArticleReplyLogUpdateError: Error {
    case updateError(Error?)
    case fetchError(Error?)
}

struct ArticleReplyLogService {

    static func getArticleReply(_ other_uid: String, completionHandler: @escaping (_ footprint: ArticleReplyLog?, _ error: ArticleReplyLogFetchError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let documentRef = Firestore.firestore().collection("article_reply_log").document(other_uid)
        documentRef.getDocument { (document, error) in
            //.addSnapshotListener { document, error in
            if error != nil {
                completionHandler(nil, .fetchError(error))
            } else if let document = document, document.exists {
                do {
                    let articleReplyLog = try ArticleReplyLog(from: document)
                    completionHandler(articleReplyLog, nil)
                } catch {
                    completionHandler(nil, .fetchError(error))
                }
            } else {
                completionHandler(nil, .fetchError(error))
            }
        }
    }

    static func addArticleReplyLog(_ other_uid: String, _ articleKey: String, completionHandler: @escaping ( _ error: ArticleReplyLogUpdateError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // 自分には返信ログを取らない
        if other_uid == uid { return }

        self.getArticleReply(other_uid, completionHandler:{ (articleReplyLog, error) in
            var history = [String: String]()
            if let articleReplyLog = articleReplyLog {
                history = articleReplyLog.history
            }
            history["\(Timestamp().seconds)"] = "\(uid),\(articleKey)"

            let tmp = history.sorted(by: { Int($0.0)! > Int($1.0)! }).prefix(50)  // ソートするとなぜか[(key:"", value:""),,,] tuple になってしまう
            var tmpDic = [String: String]()
            tmp.forEach { tmpDic["\($0.0)"] = $0.1 }
            history = tmpDic
            /* // このやり方でもよい
             let dictionary = tmp.compactMap { $0 }.reduce([String : String]()) { ( dict, tuple) in
             var tmp = dict
             tmp["\(tuple.0)"] = tuple.1
             return tmp
             }
             print(dictionary)
             */

            let data = ["history"    :   history]
            Firestore.firestore().collection("article_reply_log").document(other_uid).setData(data,  completion: { error in
                if let error = error {
                    completionHandler(.fetchError(error))
                    return
                }
                completionHandler(nil)
            })
        })
    }
}
