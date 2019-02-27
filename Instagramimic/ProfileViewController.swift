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

class ProfileViewController: UIViewController, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var shortBioField: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var customImageFlowLayout: ProfileViewFlowLayout!
    var profilePicPath: String!
    var images = [ImageStruct]()
    var imagePickerController: UIImagePickerController?
    var timestamp = Int()
    var photo = UIImage()
    var selectedPicURL: String!
    var selectedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        customImageFlowLayout = ProfileViewFlowLayout()
        imageCollectionView.collectionViewLayout = customImageFlowLayout
        imageCollectionView.backgroundColor = .white
        
        let docRef = Firestore.firestore().collection("users").document((Auth.auth().currentUser?.uid)!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dictionary = document.data()
                self.usernameField.text = dictionary!["username"] as? String
                self.shortBioField.text = dictionary!["shortBio"] as? String
                self.profilePicPath = dictionary!["profilePicURL"] as? String
                self.profileImage!.sd_setImage(with: URL.init(string: dictionary!["profilePicURL"] as! String), placeholderImage: UIImage(named: "empty-profile"), options: SDWebImageOptions(rawValue: 0), completed: {image, error, cacheType, imageURL in
                })
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    @IBAction func addImageButtonTabbed(_ sender: Any) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.delegate = self
        imagePickerController!.sourceType = .camera
        present(imagePickerController!, animated: true)
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
    
    func loadData() {
        Firestore.firestore().collection("pics").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let imageObject = ImageStruct(uid: diff.document.data()["uid"] as! String, thumbnailURL: diff.document.data()["thumbnailURL"] as! String, fullSizeURL: diff.document.data()["fullSizeURL"] as! String, timestamp: diff.document.data()["timestamp"] as! Int, caption: diff.document.data()["caption"] as! String)
                    self.images.insert(imageObject, at: 0)
                    self.images.sort(by: { $0.timestamp > $1.timestamp })
                }
            }
            self.imageCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionViewCell
        let image = images[indexPath.row]
        cell.imageView.tag = indexPath.row
        cell.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImageViewTap)))
        cell.imageView!.sd_setImage(with: URL.init(string: image.thumbnailURL), placeholderImage:UIImage.gif(asset: "loading"), options: SDWebImageOptions(rawValue: 0), completed: {image, error, cacheType, imageURL in
        })
        return cell
    }
    
    @objc func onImageViewTap(sender: UITapGestureRecognizer)
    {
        let imageView = sender.view as! UIImageView
        let tag = imageView.tag
        selectedPicURL = images[tag].fullSizeURL
        selectedImage = imageView.image
        performSegue(withIdentifier: "profileToComments", sender: self)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePickerController!.dismiss(animated: true, completion: nil)
        timestamp = Int(NSDate().timeIntervalSince1970)
        photo = cropToBounds(image: info[.originalImage] as! UIImage)
        performSegue(withIdentifier: "toCaptionView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCaptionView" {
            let dvc = segue.destination as! CaptionViewController
            dvc.imageVar = photo
            dvc.timestamp = timestamp
        }
        
        if segue.identifier == "profileToComments" {
            let dvc = segue.destination as! CommentsViewController
            dvc.photoFullURL = self.selectedPicURL
            dvc.prevIndex = 0
        }
    }
}
