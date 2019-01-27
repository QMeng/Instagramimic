//
//  Util.swift
//  Instagramimic
//
//  Created by Damon on 2019-01-24.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import Foundation
import UIKit
import Firebase

func displayMyAlertMessage(view: UIViewController, userMessage: String) {
    let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
    
    myAlert.addAction(okAction)
    view.present(myAlert, animated: true, completion: nil)
}

func displayLoadingOverlay(view: UIViewController) {
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
    
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    loadingIndicator.hidesWhenStopped = true
    loadingIndicator.style = UIActivityIndicatorView.Style.gray
    loadingIndicator.startAnimating();
    
    alert.view.addSubview(loadingIndicator)
    view.present(alert, animated: true, completion: nil)
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

func uploadPic(storageRef: StorageReference, image: UIImage, uid: String, name: String) {
    var data = Data()
    data = image.jpegData(compressionQuality: 1.0)!
    let filePath = "\(uid)/\(name)"
    let metaData = StorageMetadata()
    metaData.contentType = "image/jpg"
    let picRef = storageRef.child(filePath)
    
    picRef.putData(data, metadata: nil) { (metadata, error) in
        guard metadata != nil else {
            // Uh-oh, an error occurred!
            print(error?.localizedDescription as Any)
            return
        }
        picRef.downloadURL { (url, error) in
            guard url != nil else {
                // Uh-oh, an error occurred!
                return
            }
        }
    }
    
}
