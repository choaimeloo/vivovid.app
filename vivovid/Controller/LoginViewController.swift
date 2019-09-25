//
//  LoginViewController.swift
//  vivovid
//
//  Created by Jan Cho on 9/23/19.
//  Copyright © 2019 Jan Cho. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func logInPressed(_ sender: Any) {
        
        // TODO: Do form validation on the email and password
        
        if let email = emailTextField.text, let password =
            passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    print(error!)
                } else {
                    print("Login Successful")
                    self.performSegue(withIdentifier: "loginToMain", sender: self)
                }
            }
        }
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
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
