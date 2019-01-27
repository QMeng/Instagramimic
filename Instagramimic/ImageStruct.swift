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
    let url: String
    
    let itemRef: DocumentReference?
    
    init(uid: String, url: String) {
        self.uid = uid
        self.url = url
        self.itemRef = nil
    }
    
    init(snapshot: DocumentSnapshot) {
        self.uid = snapshot.data()!["uid"] as! String
        self.itemRef = snapshot.reference
        if let imageURL = snapshot.data()!["url"] as? String {
            self.url = imageURL
        } else {
            self.url = ""
        }
    }
}
