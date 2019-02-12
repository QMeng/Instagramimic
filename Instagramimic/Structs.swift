//
//  ImageStruct.swift
//  Instagramimic
//
//  Created by Damon on 2019-01-26.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import Foundation

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

struct CommentStruct {
    let uid: String
    let username: String
    let profilePicURL: String
    let picURL: String
    let comment: String
    let timestamp: Int
    
    init(uid: String, username: String, profilePicURL: String, picURL: String, comment: String, timestamp: Int) {
        self.uid = uid
        self.username = username
        self.profilePicURL = profilePicURL
        self.picURL = picURL
        self.comment = comment
        self.timestamp = timestamp
    }
}
