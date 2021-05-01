//
//  Authorization.swift
//  PlateChat
//
//  Created by k.katafuchi on 2018/08/16.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

enum AuthorizedErrorType {
    
    // 利用制限
    case restricted
    // 明示的否認
    case denied
}

enum AuthorizedResult {
    
    case success
    case error(AuthorizedErrorType)
}

typealias AuthorizedCompletion = ((AuthorizedResult) -> Void)

final class Authorization {
    
    private init() {}
    
    static func media(mediaType: AVMediaType, completion: AuthorizedCompletion?) {
        let status = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch status {
        case .authorized:
            // アクセス許可あり
            completion?(AuthorizedResult.success)
        case .restricted:
            // 利用制限 : 設定 > 一般 > 機能制限で利用が制限されている
            completion?(AuthorizedResult.error(.restricted))
        case .denied:
            // 明示的否認 : 設定 > プライバシー > で利用が制限されている
            completion?(AuthorizedResult.error(.denied))
        case .notDetermined:
            // まだアクセス許可を聞いていない
            AVCaptureDevice.requestAccess(for: mediaType) { granted in
                DispatchQueue.main.async {
                    if granted {
                        // 許可
                        completion?(AuthorizedResult.success)
                    } else {
                        // 否認
                        completion?(AuthorizedResult.error(.denied))
                    }
                }
            }
        }
    }
    
    static func camera(completion: AuthorizedCompletion?) {
        self.media(mediaType: AVMediaType.video, completion: completion)
    }
    
    static func photo(completion: AuthorizedCompletion?) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .limited:
            break
        case .authorized:
            // アクセス許可あり
            completion?(AuthorizedResult.success)
        case .restricted:
            // 利用制限 : 設定 > 一般 > 機能制限で利用が制限されている
            completion?(AuthorizedResult.error(.restricted))
        case .denied:
            // 明示的否認 : 設定 > プライバシー > で利用が制限されている
            completion?(AuthorizedResult.error(.denied))
        case .notDetermined:
            // まだアクセス許可を聞いていない
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == PHAuthorizationStatus.authorized {
                        // 許可
                        completion?(AuthorizedResult.success)
                    } else {
                        // 否認
                        completion?(AuthorizedResult.error(.denied))
                    }
                }
            }
        }
    }
}
