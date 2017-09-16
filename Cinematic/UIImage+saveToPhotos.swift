//
//  UIImage+SaveToPhotos.swift
//  Cinematic
//
//  Created by AJ Priola on 2/22/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary
import Photos

extension UIImage {
    
    func saveToPhotos(_ closure: @escaping (Bool) -> Void) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            PHPhotoLibrary.shared().performChanges({ 
                PHAssetChangeRequest.creationRequestForAsset(from: self)
            }, completionHandler: { (success, error) in
                if let error = error {
                    print(error)
                }
                closure(success)
            })
        } else {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    self.saveToPhotos(closure)
                } else {
                    closure(false)
                }
            })
        }
        
    }
    
}
