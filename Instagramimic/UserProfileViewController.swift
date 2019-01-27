//
//  UserProfileViewController.swift
//  Instagramimic
//
//  Created by Damon on 2019-01-15.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class UserProfileViewController: UIViewController, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var shortBioField: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var customImageFlowLayout: CustomImageFlowLayout!
    var profilePicPath: String!
    var images = [ImageStruct]()
    var imagePickerController: UIImagePickerController?
    var thumbnailURL: String = ""
    var fullSizeURL: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        customImageFlowLayout = CustomImageFlowLayout()
        imageCollectionView.collectionViewLayout = customImageFlowLayout
        imageCollectionView.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let docRef = Firestore.firestore().collection("users").document((Auth.auth().currentUser?.uid)!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dictionary = document.data()
                self.usernameField.text = dictionary!["username"] as? String
                self.shortBioField.text = dictionary!["shortBio"] as? String
                self.profileImage!.sd_setImage(with: URL.init(string: dictionary!["profilePicURL"] as! String), placeholderImage: UIImage(named: "empty-profile"), options: SDWebImageOptions(rawValue: 0), completed: {image, error, cacheType, imageURL in
                })
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func loadData() {
        Firestore.firestore().collection("pics").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let imageObject = ImageStruct(uid: diff.document.data()["uid"] as! String, thumbnailURL: diff.document.data()["thumbnailURL"] as! String, fullSizeURL: diff.document.data()["fullSizeURL"] as! String, timestamp: diff.document.data()["timestamp"] as! Int)
                    self.images.insert(imageObject, at: 0)
                    self.images.sort(by: { $0.timestamp > $1.timestamp })
                }
            }
            self.imageCollectionView.reloadData()
        }
    }
    
    @IBAction func logOutTabbed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionViewCell
        let image = images[indexPath.row]
        cell.imageView!.sd_setImage(with: URL.init(string: image.thumbnailURL), placeholderImage: UIImage(named: "image1"), options: SDWebImageOptions(rawValue: 0), completed: {image, error, cacheType, imageURL in
        })
        return cell
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePickerController!.dismiss(animated: true, completion: nil)
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        uploadThumbnail(image: (info[.originalImage] as! UIImage), timestamp: timestamp)
    }
    
    func uploadThumbnail(image: UIImage, timestamp: Int) {
        let thumbnail = resizeImage(image: cropToBounds(image: image), targetSize: CGSize(width: 200.0, height: 200.0))
        let thumbnailPath = "\((Auth.auth().currentUser?.uid)!)/\(timestamp)-thumbnail.jpg"
        let (data, metadata, thumbnailRef) = prepareUploadPic(image: thumbnail, filePath: thumbnailPath)
        thumbnailRef.putData(data, metadata: metadata) { (metadata, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                thumbnailRef.downloadURL { (url, error) in
                    self.thumbnailURL = (url?.absoluteString)!
                    self.uploadFullSizeImage(image: image, timestamp: timestamp)
                }
            }
        }
    }
    
    func uploadFullSizeImage(image: UIImage, timestamp: Int) {
        let fullSizeImage = resizeImage(image: cropToBounds(image: image), targetSize: CGSize(width: 1024.0, height: 1024.0))
        let fullSizePath = "\((Auth.auth().currentUser?.uid)!)/\(timestamp)-fullSize.jpg"
        let (data, metadata, fullSizeRef) = prepareUploadPic(image: fullSizeImage, filePath: fullSizePath)
        fullSizeRef.putData(data, metadata: metadata) { (metadata, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                fullSizeRef.downloadURL { (url, error) in
                    self.fullSizeURL = (url?.absoluteString)!
                    self.updateDB(timestamp: timestamp)
                }
            }
        }
    }
    
    func updateDB(timestamp: Int) {
        Firestore.firestore().collection("pics").addDocument(data: [
            "uid": Auth.auth().currentUser?.uid as Any,
            "fullSizeURL": self.fullSizeURL,
            "thumbnailURL": self.thumbnailURL,
            "timestamp": timestamp
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Pic Document successfully created")
            }
        }
    }
    
    @IBAction func addImageButtonTabbed(_ sender: Any) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.delegate = self
        imagePickerController!.sourceType = .camera
        present(imagePickerController!, animated: true, completion: nil)
    }
    
}
