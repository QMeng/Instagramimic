//
//  FeedsViewFlowLayout.swift
//  Instagramimic
//
//  Created by Damon on 2019-02-09.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit

class FeedsViewFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    override var itemSize: CGSize {
        set {}
        get {
            let itemWidth = self.collectionView!.frame.width
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 1
        minimumLineSpacing = 1
        scrollDirection = .vertical
    }
}
