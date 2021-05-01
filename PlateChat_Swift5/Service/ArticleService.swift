//
//  ArticleService.swift
//  PlateChat
//
//  Created by cano on 2018/08/17.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

enum ArticleBindStatus: String {
    case loading
    case done
    case failed
    case none
}

enum ArticleBindError: Error {
    case error(Error?)
    case noExistsError
}

enum PostArticleError: Error {
    case error(Error?)
}

class ArticleService {

    private let store   = Firestore.firestore()
    private let storage = Storage.storage()
    private var bindArticleHandler: ListenerRegistration?
    private let limit = 30          // １ページあたりの表示数 仮の値
    private var lastArticleDocument: QueryDocumentSnapshot? // クエリカーソルの開始点
    private var status: ArticleBindStatus
    private var bindArticleListHandler: ListenerRegistration?
    private var lastArticle: QueryDocumentSnapshot?

    private var bindUidArticleListHandler: ListenerRegistration?
    var lastUidArticle: QueryDocumentSnapshot?

    init() {
        self.status = .none
    }

    func bindArticle(callbackHandler: @escaping ([Article]?, ArticleBindError?) -> Void) {

        if self.status == .loading { return }
        self.status = .loading

        let query: Query
        if let lastDocument = self.lastArticleDocument {
            query = store
                .collection("/article/")
                .whereField("status", isEqualTo: 1)
                .order(by: "created_at", descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: limit)
        } else {
            query = store
                .collection("/article/")
                .whereField("status", isEqualTo: 1)
                .order(by: "created_at", descending: true)
                .limit(to: limit)
        }

        bindArticleHandler = query.addSnapshotListener(includeMetadataChanges: true) { [weak self] (querySnapshot, error) in
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

            self?.lastArticleDocument = snapshot.documents.last
            do {
                let articles = try snapshot.documents.compactMap { try Article(from: $0) }.sorted(by: { $0.created_date > $1.created_date}).filter {$0.status == 1 }
                self?.status = .done
                callbackHandler(articles, nil)
            } catch {
                self?.status = .failed
                callbackHandler(nil, .error(error))
            }
        }
    }

    func bindNewArticle(callbackHandler: @escaping ([Article]?, ArticleBindError?) -> Void) {

        if self.status == .loading { return }
        self.status = .loading

        let query: Query
             = store
                .collection("/article/")
                .whereField("status", isEqualTo: 1)
                .order(by: "created_at", descending: true)
                .limit(to: limit)

        bindArticleHandler = query.addSnapshotListener(includeMetadataChanges: true) { [weak self] (querySnapshot, error) in
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

            do {
                let articles = try snapshot.documents.compactMap { try Article(from: $0) }.sorted(by: { $0.created_date > $1.created_date}).filter {$0.status == 1 }
                self?.status = .done
                callbackHandler(articles, nil)
            } catch {
                self?.status = .failed
                callbackHandler(nil, .error(error))
            }
        }
    }

    func bindUidArticle(_ uid: String, callbackHandler: @escaping ([Article]?, ArticleBindError?) -> Void) {

        if self.status == .loading { return }
        self.status = .loading

        let query: Query
        if let lastDocument = self.lastUidArticle {
            query = store
                .collection("/article/")
                .whereField("uid", isEqualTo: uid)
                .whereField("status", isEqualTo: 1)
                .order(by: "created_at", descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: limit)
        } else {
            query = store
                .collection("/article/")
                .whereField("uid", isEqualTo: uid)
                .whereField("status", isEqualTo: 1)
                .order(by: "created_at", descending: true)
                .limit(to: limit)
        }

        bindUidArticleListHandler = query.addSnapshotListener(includeMetadataChanges: true) { [weak self] (querySnapshot, error) in
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

            self?.lastUidArticle = snapshot.documents.last
            do {
                let articles = try snapshot.documents.compactMap { try Article(from: $0) }.sorted(by: { $0.created_date > $1.created_date}).filter {$0.status == 1 }
                self?.status = .done
                callbackHandler(articles, nil)
            } catch {
                self?.status = .failed
                callbackHandler(nil, .error(error))
            }
        }
    }

    func removeBindArticleList() {
        self.bindArticleListHandler?.remove()
        self.lastArticle = nil
        self.lastUidArticle = nil
        self.lastArticleDocument = nil
    }

    func bindArticleList(article: Article, callbackHandler: @escaping ([Article]?, ArticleBindError?) -> Void) {

        if self.status == .loading { return }
        self.status = .loading

        let query: Query
        if let lastDocument = self.lastArticle {
            query = store
                .collection("/article/")
                .whereField("parentKey", isEqualTo: article.parentKey)
                .whereField("status", isEqualTo: 1)
                .order(by: "created_at", descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: limit)
        } else {
            query = store
                .collection("/article/")
                .whereField("parentKey", isEqualTo: article.parentKey)
                .whereField("status", isEqualTo: 1)
                .order(by: "created_at", descending: true)
                .limit(to: limit)
        }

        bindArticleListHandler = query.addSnapshotListener(includeMetadataChanges: true) { [weak self] (querySnapshot, error) in
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

            self?.lastArticle = snapshot.documents.last
            do {
                let articles = try snapshot.documents.compactMap { try Article(from: $0) }.sorted(by: { $0.created_date > $1.created_date}).filter {$0.status == 1 }
                self?.status = .done
                callbackHandler(articles, nil)
            } catch {
                self?.status = .failed
                callbackHandler(nil, .error(error))
            }
        }
    }

    // 投稿
    func createArticle(_ text: String, _ article: Article? = nil, completionHandler: @escaping (_ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var data = [
            "uid"               : uid,
            "text"              : text,
            "status"            : 1,
            "created_at"        : FieldValue.serverTimestamp(),
            "user_profile_image_url"  : AccountData.my_profile_image ?? "",
            "user_prefecture_id"      : AccountData.prefecture_id,
            "user_sex"                : AccountData.sex,
            "user_nickname"           : AccountData.nickname ?? ""
        ] as [String : Any]

        if let article = article {
            data["parentKey"]  = article.parentKey != "" ? article.parentKey : article.key
            data["toKey"]      = article.key
            data["toUid"]      = article.uid
        } else {
            data["parentKey"]  = ""
            data["toKey"]      = ""
            data["toUid"]      = ""
        }
        var ref: DocumentReference? = nil
        ref = self.store.collection("article").addDocument(data:data, completion: { [weak self] error in
            if let err = error {
                print("Error adding document: \(err)")
                completionHandler(err)
                return
            }

            print("ref")
            print(ref)
            print(ref?.documentID)

            if let article = article {
                // 返信ログ
                ArticleReplyLogService.addArticleReplyLog(article.uid, ref!.documentID, completionHandler: { _ in })

                if article.parentKey == "" {
                    let data = ["parentKey": article.key]
                    self?.store.collection("article").document(article.key).setData(data, merge: true, completion: { error in
                        if let err = error {
                            print("Error adding document: \(err)")
                            completionHandler(err)
                            return
                        }
                        completionHandler(nil)
                    })
                } else {
                    completionHandler(nil)
                }
            } else {
                completionHandler(nil)
            }
        })
    }

    // 削除
    func deleteArticle(_ article: Article, completionHandler: @escaping (_ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        if article.uid != uid {
            return
        }

        self.store.collection("article").document(article.key).setData([ "status" : 0 ], merge: true, completion: { error in
            if let err = error {
                print("Error adding document: \(err)")
                completionHandler(err)
                return
            }
            if article.key == article.parentKey {
                // 関連情報を削除
                let query = self.store
                    .collection("/article/")
                    .whereField("parentKey", isEqualTo: article.parentKey)
                    .whereField("status", isEqualTo: 1)
                    .order(by: "created_at", descending: true)

                query.addSnapshotListener(includeMetadataChanges: true) { (querySnapshot, error) in
                    do {
                        if let snapshot = querySnapshot {
                            let articles = try snapshot.documents.compactMap { try Article(from: $0) }
                            for article in articles {

                                self.store.collection("article").document(article.key).setData(["status": 0], merge: true,  completion: { _ in })
                            }
                        }
                    } catch {}
                }
            }
            completionHandler(nil)
        })
    }
}
