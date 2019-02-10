//
//  FeedViewController.swift
//  Instagramimic
//
//  Created by Damon on 2019-02-09.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import SDWebImage

class FeedViewController: UIViewController, UICollectionViewDataSource {
    @IBOutlet weak var feedsCollection: UICollectionView!
    
    var feedsImageFlowLayout: FeedsViewFlowLayout!
    
    var feeds = [ImageStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        feedsImageFlowLayout = FeedsViewFlowLayout()
        feedsCollection.collectionViewLayout = feedsImageFlowLayout
        feedsCollection.backgroundColor = .white
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedCell = feedsCollection.dequeueReusableCell(withReuseIdentifier: "feedCell", for: indexPath) as! FeedsCollectionViewCell
        let feed = feeds[indexPath.row]
        feedCell.feedImageView!.sd_setImage(with: URL.init(string: feed.fullSizeURL), placeholderImage: UIImage.gif(asset: "spinner"), options: SDWebImageOptions(rawValue: 0), completed: {image, error, cacheType, imageURL in
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
}
