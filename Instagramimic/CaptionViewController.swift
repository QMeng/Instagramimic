//
//  CaptionViewController.swift
//  Instagramimic
//
//  Created by Damon on 2019-02-07.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit
import Firebase

class CaptionViewController: UIViewController {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var captionBox: UITextView!
    
    var imageVar: UIImage!
    var timestamp: Int!
    var thumbnailURL: String = ""
    var fullSizeURL: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.captionBox.layer.borderWidth = 1
        self.captionBox.layer.borderColor = UIColor.darkGray.cgColor
        self.photoView.image = imageVar
    }

    @IBAction func generateHashTags(_ sender: Any) {
        let image = VisionImage(image: imageVar)
        let labeler = Vision.vision().cloudLabelDetector()
        labeler.detect(in: image) { labels, error in
            guard error == nil, let labels = labels else {
                print(error?.localizedDescription as Any)
                return
            }
            
            var tags: [String] = []
            
            for label in labels {
                let labelText = label.label!
                let confidence = label.confidence!.doubleValue
                
                if confidence > 0.7 {
                    tags.append(labelText)
                }
            }
            
            var caption = self.captionBox.text!
            for tag in tags {
                caption += " #" + tag
            }

            DispatchQueue.main.async {
                self.captionBox.text = caption
            }
            return
        }
    }
    
    @IBAction func cancelPost(_ sender: Any) {
        performSegue(withIdentifier: "backToProfileView", sender: self)
    }
    
    @IBAction func post(_ sender: Any) {
        displayLoadingOverlay(view: self)
        uploadThumbnail(image: imageVar, timestamp: timestamp, caption: captionBox.text)
    }
    
    func uploadThumbnail(image: UIImage, timestamp: Int, caption: String) {
        let thumbnail = resizeImage(image: cropToBounds(image: image), targetSize: CGSize(width: 200.0, height: 200.0))
        let thumbnailPath = "\((Auth.auth().currentUser?.uid)!)/\(timestamp)-thumbnail.jpg"
        let (data, metadata, thumbnailRef) = prepareUploadPic(image: thumbnail, filePath: thumbnailPath)
        thumbnailRef.putData(data, metadata: metadata) { (metadata, error) in
            if error != nil {
                print(error.debugDescription)
                print(error?.localizedDescription as Any)
            } else {
                thumbnailRef.downloadURL { (url, error) in
                    self.thumbnailURL = (url?.absoluteString)!
                    self.uploadFullSizeImage(image: image, timestamp: timestamp, caption: caption)
                }
            }
        }
    }
    
    func uploadFullSizeImage(image: UIImage, timestamp: Int, caption: String) {
        let fullSizeImage = resizeImage(image: cropToBounds(image: image), targetSize: CGSize(width: 1024.0, height: 1024.0))
        let fullSizePath = "\((Auth.auth().currentUser?.uid)!)/\(timestamp)-fullSize.jpg"
        let (data, metadata, fullSizeRef) = prepareUploadPic(image: fullSizeImage, filePath: fullSizePath)
        fullSizeRef.putData(data, metadata: metadata) { (metadata, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                fullSizeRef.downloadURL { (url, error) in
                    self.fullSizeURL = (url?.absoluteString)!
                    self.updateDB(timestamp: timestamp, caption: caption)
                }
            }
        }
    }
    
    func updateDB(timestamp: Int, caption: String) {
        Firestore.firestore().collection("pics").addDocument(data: [
            "uid": Auth.auth().currentUser?.uid as Any,
            "fullSizeURL": self.fullSizeURL,
            "thumbnailURL": self.thumbnailURL,
            "timestamp": timestamp,
            "caption" : caption
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Pic Document successfully created")
                self.dismiss(animated: false, completion: nil)
                self.performSegue(withIdentifier: "backToProfileView", sender: self)
            }
        }
    }
    
}
