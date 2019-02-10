//
//  FeedsCollectionViewCell.swift
//  Instagramimic
//
//  Created by Damon on 2019-02-09.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit

class FeedsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var feedImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.feedImageView.image = nil
    }
}
