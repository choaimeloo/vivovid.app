//
//  SignupViewController.swift
//  vivovid
//
//  Created by Jan Cho on 9/23/19.
//  Copyright © 2019 Jan Cho. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
    @IBOutlet weak var googleSignUpButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       GIDSignIn.sharedInstance()?.presentingViewController = self
       
       // Automatically sign in the user.
       GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    // Create & authenticate new user in Firebase
    
    // TODO: Do form validation on the email and password
    func createUserWithEmail() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    print(error!)
                } else {
                    print("Signup Successful")
                    self.performSegue(withIdentifier: "signupToUploads", sender: self)
                }
            }
        }
    }
    
    // Set up responder chain for email & password text fields
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == .next {
            let nextTag = textField.tag + 1
            if let nextResponder = textField.superview?.viewWithTag(nextTag) {
                nextResponder.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
            return true
        } else if textField.returnKeyType == .go {
            createUserWithEmail()
            textField.resignFirstResponder()
            return true
        }
        return false
    }
        
    // Signup with email and password
    @IBAction func signupEmailPressed(_ sender: Any) {
        createUserWithEmail()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
