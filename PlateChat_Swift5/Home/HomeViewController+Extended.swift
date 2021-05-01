//
//  HomeViewController+Extended.swift
//  PlateChat
//
//  Created by cano on 2018/11/26.
//  Copyright © 2018 deskplate. All rights reserved.
//

import UIKit

extension HomeViewController {

    // アクションシートを起動してUIImagePickerController起動
    func shwoActionSheet<T>(title: String, message: String, actions: [ActionSheetAction<T>]) {
        self.showActionSheet(title: title, message: message, actions: actions)
            .subscribe({ [unowned self] event in
                if let sourceType = event.element as? UIImagePickerController.SourceType {
                    switch sourceType {
                    case .camera:
                        self.launchPhotoPicker(.camera)
                    case .photoLibrary:
                        self.launchPhotoPicker(.photoLibrary)
                    case .savedPhotosAlbum:
                        break
                    }
                }
            })
            .disposed(by: rx.disposeBag)
    }

    // UIImagePickerControllerの起動と選択した画像の処理
    private func launchPhotoPicker(_ type: UIImagePickerController.SourceType) {
        UIImagePickerController.rx.createWithParent(self) { picker in
            picker.sourceType = type
            picker.allowsEditing = true
            }
            .flatMap { $0.rx.didFinishPickingMediaWithInfo }
            .take(1)
        .map { info in return info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage }
            .bind(to: self.selectedImage)
            .disposed(by: rx.disposeBag)
    }
    
}
