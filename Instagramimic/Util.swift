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

func cropToBounds(image: UIImage) -> UIImage {
    
    let cgimage = image.cgImage!
    let contextImage: UIImage = UIImage(cgImage: cgimage)
    let contextSize: CGSize = contextImage.size
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var cgwidth: CGFloat = CGFloat(image.size.width)
    var cgheight: CGFloat = CGFloat(image.size.height)
    
    // See what size is longer and create the center off of that
    if contextSize.width > contextSize.height {
        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        cgwidth = contextSize.height
        cgheight = contextSize.height
    } else {
        posX = 0
        posY = ((contextSize.height - contextSize.width) / 2)
        cgwidth = contextSize.width
        cgheight = contextSize.width
    }
    
    let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
    
    // Create bitmap image from context using the rect
    let imageRef: CGImage = cgimage.cropping(to: rect)!
    
    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: .right)
    
    return image
}

func prepareUploadPic(image: UIImage, filePath: String) -> (Data, StorageMetadata, StorageReference) {
    let data = image.jpegData(compressionQuality: 0.8)!
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpg"
    let picRef = Storage.storage().reference().child(filePath)
    return (data, metadata, picRef)
}
