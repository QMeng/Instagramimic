//
//  UserProfileViewController.swift
//  Instagramimic
//
//  Created by Damon on 2019-01-15.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var shortBioField: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let docRef = db.collection("users").document((Auth.auth().currentUser?.uid)!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dictionary = document.data()
                self.usernameField.text = dictionary!["username"] as? String
                self.shortBioField.text = dictionary!["shortBio"] as? String
            } else {
                print("Document does not exist")
            }
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
    
}
