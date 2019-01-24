//
//  StartViewController.swift
//  Instagramimic
//
//  Created by Damon on 2019-01-23.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonTabbed(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "alreadyLoggedIn", sender: nil)
        } else {
            self.performSegue(withIdentifier: "toLoginView", sender: nil)
        }
    }
    
}
