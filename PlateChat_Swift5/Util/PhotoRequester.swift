//
//  PhotoRequester.swift
//  PlateChat
//
//  Created by k.katafuchi on 2018/08/16.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import UIKit

enum PhotoResquestResult {
    
    case success(UIImage)
    case faild(AuthorizedErrorType)
    case cancel
}

typealias PhotoResquestCompletion = ((PhotoResquestResult) -> Void)

final class PhotoRequester: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate static let shared: PhotoRequester = PhotoRequester()
    
    fileprivate var completionHandler: (PhotoResquestCompletion)?
    
    static func requestPhotoLibrary(_ parentViewController: UIViewController, completion: PhotoResquestCompletion?) {
        self.shared.requestPhoto(parentViewController, sourceType: .photoLibrary, completion: completion)
    }
    
    static func requestPhotoFromCamera(_ parentViewController: UIViewController, completion: PhotoResquestCompletion?) {
        self.shared.requestPhoto(parentViewController, sourceType: .camera, completion: completion)
    }
    
    static func requestPhotoFromSavedPhotosAlbum(_ parentViewController: UIViewController, completion: PhotoResquestCompletion?) {
        self.shared.requestPhoto(parentViewController, sourceType: .savedPhotosAlbum, completion: completion)
    }
    
    private func requestPhoto(_ parentViewController: UIViewController, sourceType: UIImagePickerController.SourceType, completion: PhotoResquestCompletion?) {
        if !UIImagePickerController.isSourceTypeAvailable(sourceType) {
            completion?(PhotoResquestResult.faild(.denied))
            return
        }
        
        let resultBlock: AuthorizedCompletion = { [unowned self] result in
            switch result {
            case .success:
                let imagePickerController: UIImagePickerController = UIImagePickerController()
                imagePickerController.sourceType = sourceType
                imagePickerController.allowsEditing = true
                imagePickerController.delegate = self
                
                self.completionHandler = completion
                
                parentViewController.present(imagePickerController, animated: true, completion: nil)
            case .error(let error):
                completion?(PhotoResquestResult.faild(error))
            }
        }
        
        switch sourceType {
        case .camera:
            Authorization.camera(completion: resultBlock)
        case .photoLibrary, .savedPhotosAlbum:
            Authorization.photo(completion: resultBlock)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension PhotoRequester {
    
    //@objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //let image = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage
        if let iamge = info[.editedImage] as? UIImage {
            picker.dismiss(animated: true) { [unowned self] in
                self.completionHandler?(PhotoResquestResult.success(iamge))
                self.completionHandler = nil
            }
        }
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [unowned self] in
            self.completionHandler?(PhotoResquestResult.cancel)
            self.completionHandler = nil
        }
    }
}
