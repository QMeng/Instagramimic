//
//  SignUpViewController.swift
//  Instagramimic
//
//  Created by Damon on 2019-01-14.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit
import Firebase

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
    let db = Firestore.firestore()
    
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
        profileImage.image = resizeImage(image: (info[.originalImage] as? UIImage)!, targetSize: CGSize(width: 200.0, height: 200.0))
    }
    
    func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
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
    
    // sign up button tabbed, start user registration processes
    @IBAction func signUpButtonTabbed(_ sender: Any) {
        let userEmail = emailTextField.text
        let userPassword = passwordTextField.text
        let userConfirmPassword = confirmPasswordTextField.text
        let userUsername = usernameTextField.text
        let userShortBio = shortBioTextField.text
        
        if (userEmail!.isEmpty || userPassword!.isEmpty || userConfirmPassword!.isEmpty || userUsername!.isEmpty || userShortBio!.isEmpty){
            // Display alert message
            displayMyAlertMessage(view: self, userMessage: "All fields are required!")
            return;
        }
        
        if (!isValidEmail(email: userEmail!)) {
            // display alert message
            displayMyAlertMessage(view: self, userMessage: "Please input a valid email!")
            return;
        }
        
        // check passwords matches each other
        if (userPassword != userConfirmPassword) {
            // Display alert message
            displayMyAlertMessage(view: self, userMessage: "Passwords do not match!")
            return;
        }
        
        displayLoadingOverlay(view: self)
        createUser(email: userEmail!, password: userPassword!, username: userUsername!, shortBio: userShortBio!)
        
    }
    
    // create user and upload user data into firestore
    func createUser(email: String, password: String, username: String, shortBio: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                self.dismiss(animated: false, completion: nil)
                displayMyAlertMessage(view: self, userMessage: error?.localizedDescription ?? "Error creating user")
            } else {
                Auth.auth().signIn(withEmail: email, password: password)
                
                var data = Data()
                data = self.profileImage.image!.jpegData(compressionQuality: 0.1)!
                let filePath = "\((Auth.auth().currentUser?.uid)!)/profilePic.jpg"
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpg"
                let picRef = Storage.storage().reference().child(filePath)
                picRef.putData(data, metadata: metaData) { (metadata, error) in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                    } else {
                        print("Profile pic upload successful")
                        Firestore.firestore().collection("users").document((Auth.auth().currentUser?.uid)!).setData([
                            "email": email,
                            "username": username,
                            "shortBio": shortBio,
                            "profilePic": "\((Auth.auth().currentUser?.uid)!)/profilePic.jpg"
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            } else {
                                print("Document successfully created")
                            }
                        }
                    }
                }
                
                self.dismiss(animated: false, completion: nil)
                self.performSegue(withIdentifier: "signUpToHome", sender: self)
            }
        }
    }
}
