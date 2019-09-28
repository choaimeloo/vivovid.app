//
//  LoginViewController.swift
//  vivovid
//
//  Created by Jan Cho on 9/23/19.
//  Copyright © 2019 Jan Cho. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class LoginViewController: UIViewController, UITextFieldDelegate, LoginButtonDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        // If Facebook user is already logged in, send to next view controller
        if AccessToken.current != nil {
            self.performSegue(withIdentifier: "loginToUploads", sender: self)
        } else {
            // Initialize Facebook login button
            let loginButton = FBLoginButton()
            loginButton.delegate = self
        }
    }
    
    
    // Facebook Login
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil {
            print(error?.localizedDescription as Any)
            // TODO: Do something here to alert user
        } else {
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            print("Facebook Login Successful")
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    print("User signed into Firebase")
                    print(authResult?.user.displayName ?? "Username missing")
                    print(authResult?.user.email ?? "Email missing")
                }
            }
            self.performSegue(withIdentifier: "loginToUploads", sender: self)
        }
    }
    
    // Facebook Logout
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("User logged out")
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    // TODO: Form validation on the email and password
    func logInWithEmail() {
        if let email = emailTextField.text, let password =
            passwordTextField.text {
            
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    print(error!)
                } else {
                    print("Login Successful")
                    self.performSegue(withIdentifier: "loginToUploads", sender: self)
                }
            }
        }
    }
    
    // Set up responder chain for email & password textfields
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
            logInWithEmail()
            textField.resignFirstResponder()
            return true
        }
        return false
    }
        
    
    @IBAction func logInPressed(_ sender: Any) {
        logInWithEmail()
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
