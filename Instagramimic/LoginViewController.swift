//
//  ViewController.swift
//  Instagramimic
//
//  Created by Damon on 2019-01-10.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "toProfileView", sender: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loginButtonTabbed(_ sender: Any) {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if (email!.isEmpty) || (password!.isEmpty) {
            Instagramimic.displayMyAlertMessage(view: self, userMessage: "Please fill all fields!")
        }
        
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            if error == nil {
                self.performSegue(withIdentifier: "toProfileView", sender: self)
            } else {
                Instagramimic.displayMyAlertMessage(view: self, userMessage: error?.localizedDescription ?? "Error logging in")
            }
        }
    }
}

