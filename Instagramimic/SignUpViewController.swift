//
//  SignUpViewController.swift
//  Instagramimic
//
//  Created by Damon on 2019-01-14.
//  Copyright © 2019 damonmeng. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
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

}
