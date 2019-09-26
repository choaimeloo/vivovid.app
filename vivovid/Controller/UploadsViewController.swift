//
//  UploadsViewController.swift
//  vivOvid
//
//  Created by Jan Cho on 9/26/19.
//  Copyright © 2019 Jan Cho. All rights reserved.
//

import UIKit
import Firebase

class UploadsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        // Google signout
        // GIDSignIn.sharedInstance()?.signOut()
        // refreshInterface()
        
        // Firebase signout
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("You're Signed Out!")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
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
