//
//  UserProfileViewController.swift
//  Instagramimic
//
//  Created by Damon on 2019-01-15.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit

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
    
}
