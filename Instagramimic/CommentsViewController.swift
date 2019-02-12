//
//  CommentsViewController.swift
//  Instagramimic
//
//  Created by Damon on 2019-02-10.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class CommentsViewController: UIViewController, UICollectionViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var captionView: UITextView!
    @IBOutlet weak var commentCollection: UICollectionView!
    @IBOutlet weak var newCommentField: UITextField!
    @IBOutlet weak var commentNavBar: UINavigationItem!
    
    var commentViewFlowLayout: CommentsViewFlowLayout!
    var comments = [CommentStruct]()
    var trashBarButtonItem : UIBarButtonItem!
    
    var photoFullURL: String!
    var prevIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        commentViewFlowLayout = CommentsViewFlowLayout()
        commentCollection.collectionViewLayout = commentViewFlowLayout
        commentCollection.backgroundColor = .white
        
        photoView.sd_setImage(with: URL.init(string: photoFullURL), placeholderImage: UIImage.gif(asset: "ring-loader"), options: SDWebImageOptions(rawValue: 0), completed: {image, error, cacheType, imageURL in
        })
        
        self.trashBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target:self, action: #selector(deletePost))
        self.trashBarButtonItem.tintColor = .darkGray
        
        Firestore.firestore().collection("pics").whereField("fullSizeURL", isEqualTo: photoFullURL).getDocuments() { querySnapshot, error in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.captionView.text = (document.data()["caption"] as! String)
                    let owner = document.data()["uid"] as! String
                    if owner == Auth.auth().currentUser?.uid {
                        self.commentNavBar.rightBarButtonItem = self.trashBarButtonItem
                    } else {
                        self.commentNavBar.rightBarButtonItem = nil
                    }
                    break
                }
            }
        }
    }
    
    @IBAction func postComment(_ sender: Any) {
        let comment = newCommentField.text!
        if comment == "" {
            displayMyAlertMessage(view: self, userMessage: "Comment can not be empty!")
            return
        }
        Firestore.firestore().collection("users").document((Auth.auth().currentUser?.uid)!).getDocument() { (document, error) in
            if let document = document, document.exists {
                let dictionary = document.data()
                let profilePicURL = dictionary!["profilePicURL"]
                let username = dictionary!["username"]
                Firestore.firestore().collection("comments").addDocument(data: [
                    "uid": Auth.auth().currentUser?.uid as Any,
                    "username": username as Any,
                    "comment": comment,
                    "picFullURL": self.photoFullURL,
                    "timestamp": Int(NSDate().timeIntervalSince1970),
                    "profilePicURL": profilePicURL as Any])
            }
            DispatchQueue.main.async {
                self.newCommentField.text = ""
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        performSegue(withIdentifier: "toTabView", sender: self)
    }
    
    @objc func deletePost() {
        Firestore.firestore().collection("comments").whereField("picFullURL", isEqualTo: self.photoFullURL).getDocuments() { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documents.forEach { doc in
                doc.reference.delete()
            }
            
            Firestore.firestore().collection("pics").whereField("fullSizeURL", isEqualTo: self.photoFullURL).getDocuments() {
                querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                var timestamp = Int()
                snapshot.documents.forEach { doc in
                    timestamp = doc.data()["timestamp"] as! Int
                    doc.reference.delete()
                }
                
                Storage.storage().reference().child((Auth.auth().currentUser?.uid)! + "/" + String(timestamp) + "-fullSize.jpg").delete()
                Storage.storage().reference().child((Auth.auth().currentUser?.uid)! + "/" + String(timestamp) + "-thumbnail.jpg").delete()
                self.performSegue(withIdentifier: "toTabView", sender: self)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let commentCell = commentCollection.dequeueReusableCell(withReuseIdentifier: "commentCell", for: indexPath) as! CommentsCollectionViewCell
        let comment = comments[indexPath.row]
        commentCell.comment.text = comment.comment
        commentCell.username.text = comment.username
        commentCell.profileImageView!.sd_setImage(with: URL.init(string: comment.profilePicURL), placeholderImage: UIImage.gif(asset: "loading"), options: SDWebImageOptions(rawValue: 0), completed: {image, error, cacheType, imageURL in
        })
        return commentCell
    }
    
    func loadData() {
        Firestore.firestore().collection("comments").whereField("picFullURL", isEqualTo: self.photoFullURL).addSnapshotListener {
            querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let commentObject = CommentStruct(uid: diff.document.data()["uid"] as! String, username: diff.document.data()["username"] as! String, profilePicURL: diff.document.data()["profilePicURL"] as! String, picURL: diff.document.data()["picFullURL"] as! String, comment: diff.document.data()["comment"] as! String, timestamp: diff.document.data()["timestamp"] as! Int)
                    self.comments.insert(commentObject, at: 0)
                    self.comments.sort(by: { $0.timestamp < $1.timestamp })
                }
            }
            self.commentCollection.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTabView" {
            if let tabVC = segue.destination as? UITabBarController {
                tabVC.selectedIndex = prevIndex
            }
        }
    }
}
