//
//  NetworkReachability.swift
//  PlateChat
//
//  Created by cano on 2018/12/19.
//  Copyright © 2018 deskplate. All rights reserved.
//

import Foundation
import Alamofire

class NetworkReachability {

    static let shared: NetworkReachability = NetworkReachability()
    static var isReachable: Bool { return NetworkReachability.shared.isReachable }

    static func startListening() {
        //self.shared.startListening()
    }

    static func stopListening() {
        //self.shared.stopListening()
    }

    fileprivate let reachabilityManager: NetworkReachabilityManager? = NetworkReachabilityManager()
    fileprivate var isReachable: Bool = false

    fileprivate init() {}

    /*
    fileprivate func startListening() {
        self.isReachable = self.reachabilityManager?.isReachable ?? false
        self.reachabilityManager?.listener = { [weak self] status in
            switch status {
            case .unknown:
                self?.isReachable = false
            case .notReachable:
                self?.isReachable = false
            case .reachable:
                self?.isReachable = true
            }
        }
        self.reachabilityManager?.startListening()
    }

    fileprivate func stopListening() {
        self.reachabilityManager?.listener = nil
        self.isReachable = false
        self.reachabilityManager?.stopListening()
    }
    */
}
