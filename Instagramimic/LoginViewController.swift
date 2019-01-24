//
//  ViewController.swift
//  Instagramimic
//
//  Created by Damon on 2019-01-10.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loginButtonTabbed(_ sender: Any) {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if (email!.isEmpty) || (password!.isEmpty) {
            displayMyAlertMessage(userMessage: "Please fill all fields!")
        }
        
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            if error == nil {
                self.performSegue(withIdentifier: "toProfileView", sender: self)
            } else {
                self.displayMyAlertMessage(userMessage: error?.localizedDescription ?? "Error logging in")
            }
        }
    }
    
    func displayMyAlertMessage(userMessage: String) {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
}

