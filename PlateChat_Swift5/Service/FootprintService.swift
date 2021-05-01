//
//  FootprintService.swift
//  PlateChat
//
//  Created by cano on 2018/09/23.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

enum FootprintServiceFetchError: Error {
    case fetchError(Error?)
    case noExistsError
}

enum FootprintServiceUpdateError: Error {
    case updateError(Error?)
    case fetchError(Error?)
}

struct FootprintService {

    static func getFootprint(_ other_uid: String, completionHandler: @escaping (_ footprint: Footprint?, _ error: FootprintServiceFetchError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let documentRef = Firestore.firestore().collection("footprint").document(other_uid)
        documentRef.getDocument { (document, error) in
            //.addSnapshotListener { document, error in
            if error != nil {
                completionHandler(nil, .fetchError(error))
            } else if let document = document, document.exists {
                do {
                    let footprint = try Footprint(from: document)
                    completionHandler(footprint, nil)
                } catch {
                    completionHandler(nil, .fetchError(error))
                }
            } else {
                completionHandler(nil, .fetchError(error))
            }
        }
    }

    static func addFootprint(_ other_uid: String, completionHandler: @escaping ( _ error: FootprintServiceUpdateError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if other_uid == uid { return }
        
        self.getFootprint(other_uid, completionHandler:{ (footprint, error) in
            var history = [String: String]()
            if let footprint = footprint {
                history = footprint.history
            }
            //history["\(Timestamp().seconds)"] = uid


            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"// HH:mm:ss"

            let newDate = Date(timeIntervalSince1970: TimeInterval(Timestamp().seconds))
            let now = formatter.string(from: newDate)

            var newHistory = [String: String]()
            history.forEach {
                if let dateUnix = TimeInterval($0.0) {
                    let date = Date(timeIntervalSince1970: dateUnix)
                    let ymd  = formatter.string(from: date)

                    if $0.1 == uid {
                        if ymd != now {
                            newHistory["\($0.0)"] = $0.1
                        }
                    } else {
                        newHistory["\($0.0)"] = $0.1
                    }
                }
            }
            newHistory["\(Timestamp().seconds)"] = uid

            let tmp = newHistory.sorted(by: { Int($0.0)! > Int($1.0)! }).prefix(50)  // ソートするとなぜか[(key:"", value:""),,,] tuple になってしまう
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
            Firestore.firestore().collection("footprint").document(other_uid).setData(data,  completion: { error in
                if let error = error {
                    completionHandler(.fetchError(error))
                    return
                }
                completionHandler(nil)
            })
        })
    }
}
