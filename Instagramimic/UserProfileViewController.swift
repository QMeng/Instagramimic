//
//  UserProfileViewController.swift
//  Instagramimic
//
//  Created by Damon on 2019-01-15.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class UserProfileViewController: UIViewController {

    @IBOutlet weak var UsernameLabel: UILabel!
    @IBOutlet weak var ShortBiolabel: UILabel!
    @IBOutlet weak var UserProfilePicImageView: UIImageView!
    
    var usernameLabelText = String()
    var shortBioLabelText = String()
    var profileImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        UsernameLabel.text = usernameLabelText
        ShortBiolabel.text = shortBioLabelText
        UserProfilePicImageView.image = profileImage
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
