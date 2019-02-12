//
//  FeedViewController.swift
//  Instagramimic
//
//  Created by Damon on 2019-02-09.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class FeedViewController: UIViewController, UICollectionViewDataSource {
    @IBOutlet weak var feedsCollection: UICollectionView!
    
    var feedsImageFlowLayout: FeedsViewFlowLayout!
    var feeds = [ImageStruct]()
    
    var selectedPicURL: String!
    var selectedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        feedsImageFlowLayout = FeedsViewFlowLayout()
        self.feedsCollection.collectionViewLayout = feedsImageFlowLayout
        self.feedsCollection.backgroundColor = .white
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedCell = feedsCollection.dequeueReusableCell(withReuseIdentifier: "feedCell", for: indexPath) as! FeedsCollectionViewCell
        let feed = feeds[indexPath.row]
        feedCell.feedImageView.tag = indexPath.row
        feedCell.feedImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImageTap)))
        feedCell.feedImageView!.sd_setImage(with: URL.init(string: feed.fullSizeURL), placeholderImage: UIImage.gif(asset: "ring-loader"), options: SDWebImageOptions(rawValue: 0), completed: {image, error, cacheType, imageURL in
            })
        return feedCell
    }
    
    func loadData() {
        Firestore.firestore().collection("pics").addSnapshotListener {
            querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let imageObject = ImageStruct(uid: diff.document.data()["uid"] as! String, thumbnailURL: diff.document.data()["thumbnailURL"] as! String, fullSizeURL: diff.document.data()["fullSizeURL"] as! String, timestamp: diff.document.data()["timestamp"] as! Int, caption: diff.document.data()["caption"] as! String)
                    self.feeds.insert(imageObject, at: 0)
                    self.feeds.sort(by: { $0.timestamp > $1.timestamp })
                }
            }
            self.feedsCollection.reloadData()
        }
    }
    
    @objc func onImageTap(_ sender: UITapGestureRecognizer)
    {
        let imageView = sender.view as! UIImageView
        let tag = imageView.tag
        selectedPicURL = feeds[tag].fullSizeURL
        selectedImage = imageView.image
        performSegue(withIdentifier: "toCommentsView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCommentsView" {
            let dvc = segue.destination as! CommentsViewController
            dvc.photoFullURL = self.selectedPicURL
            dvc.prevIndex = 1
        }
    }
}
