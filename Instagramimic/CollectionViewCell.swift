//
//  ImageCollectionViewCell.swift
//  Instagramimic
//
//  Created by Damon on 2019-01-26.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
}

class FeedsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var feedImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.feedImageView.image = nil
    }
}

class CommentsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImageView.image = nil
        self.username.text = nil
        self.comment.text = nil
        self.comment.textColor = .darkGray
    }
}
