//
//  ImageStruct.swift
//  Instagramimic
//
//  Created by Damon on 2019-01-26.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import Foundation
import Firebase

struct ImageStruct {
    let uid: String
    let thumbnailURL: String
    let fullSizeURL: String
    let timestamp: Int
    let caption: String
    
    init(uid: String, thumbnailURL: String, fullSizeURL: String, timestamp: Int, caption: String) {
        self.uid = uid
        self.thumbnailURL = thumbnailURL
        self.fullSizeURL = fullSizeURL
        self.timestamp = timestamp
        self.caption = caption
    }
}
