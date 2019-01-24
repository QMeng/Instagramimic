//
//  SignUpViewController.swift
//  Instagramimic
//
//  Created by Damon on 2019-01-14.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var shortBioTextField: UITextField!
    
    var imagePickerController : UIImagePickerController!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBAction func takePhoto(_ sender: Any) {
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePickerController.dismiss(animated: true, completion: nil)
        profileImage.image = info[.originalImage] as? UIImage
    }
    
    func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func displayMyAlertMessage(userMessage: String) {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
            case 1:
                scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
            case 2:
                scrollView.setContentOffset(CGPoint(x: 0, y: 150), animated: true)
            default:
                print("do nothing")
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signUpButtonTabbed(_ sender: Any) {
        let userEmail = emailTextField.text
        let userPassword = passwordTextField.text
        let userConfirmPassword = confirmPasswordTextField.text
        let userUsername = usernameTextField.text
        let userShortBio = shortBioTextField.text
        
        if (userEmail!.isEmpty || userPassword!.isEmpty || userConfirmPassword!.isEmpty || userUsername!.isEmpty || userShortBio!.isEmpty){
            // Display alert message
            displayMyAlertMessage(userMessage: "All fields are required!")
            return;
        }
        
        if (!isValidEmail(email: userEmail!)) {
            // display alert message
            displayMyAlertMessage(userMessage: "Please input a valid email!")
        }
        
        // check passwords matches each other
        if (userPassword != userConfirmPassword) {
            // Display alert message
            displayMyAlertMessage(userMessage: "Passwords do not match!")
            return;
        }
        
        Auth.auth().createUser(withEmail: userEmail!, password: userPassword!) { (user, error) in
            if error == nil {
                self.performSegue(withIdentifier: "signUpToHome", sender: self)
            } else {
                self.displayMyAlertMessage(userMessage: error?.localizedDescription ?? "Error creating user")
            }
        }
    }
}
