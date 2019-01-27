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

class UserProfileViewController: UIViewController, UICollectionViewDataSource {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var shortBioField: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    var customImageFlowLayout: CustomImageFlowLayout!
    var profilePicPath: String!
    var images = [ImageStruct]()
    
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
                let picPath = dictionary!["profilePic"] as? String
                let picRef = Storage.storage().reference().child(picPath!)
                picRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.profileImage.image = UIImage(data: data!)
                    }
                }
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func loadData() {
        Firestore.firestore().collection("pics").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).addSnapshotListener { querySnapshot, error in
            var newImage = [ImageStruct]()
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let imageObject = ImageStruct(uid: diff.document.data()["uid"] as! String, url:  diff.document.data()["url"] as! String)
                    newImage.append(imageObject)
                }
            }
            self.images = newImage
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
        cell.imageView!.sd_setImage(with: URL.init(string: image.url), placeholderImage: UIImage(named: "image1"), options: SDWebImageOptions(rawValue: 0), completed: {image, error, cacheType, imageURL in
        })
        return cell
    }
    
}
