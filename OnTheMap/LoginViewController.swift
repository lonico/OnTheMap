//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 8/28/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    // MARK - FBSDKLoginButtonDelegate functions
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if let error = error {
            let errorMsg = "Facebook login failed " + error.domain + ": " + error.description
            statusLabel.text = errorMsg
        } else {
            if let token = result!.token {
                UdacityCLient.shared_instance().loginWithFacebook() { success, errorMsg in
                    if success {
                        self.completeLogin()
                    } else {
                        self.dispatch_status_update(errorMsg)
                    }
                }
            } else {
                statusLabel.text = "Facebook login failed"
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        UdacityCLient.shared_instance().logout() { success, errorMsg in
            var msg: String? = ""
            if success {
                println("Logged out")
            } else {
                msg = errorMsg
            }
            self.dispatch_status_update(msg)
        }
    }
    
    // MARK - action buttons
    // FB login button does not require an action
    
    @IBAction func loginButtonTouchUp(sender: UIButton) {
        
        let email = emailTextField.text
        let password = passwordTextField.text
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if email == "" {
            statusLabel.text = "Empty email field"
        } else if password == "" {
            statusLabel.text = "Empty password field"
        } else {
            statusLabel.text = ""
            
            UdacityCLient.shared_instance().loginWithEmailID(email, password: password) { success, errorMsg in
                if success {
                    self.completeLogin()
                } else {
                    self.dispatch_status_update(errorMsg)
                }
            }
        }
    }
    
    @IBAction func signUpTouchUp(sender: UIButton) {
        if let udacityLink = NSURL(string : "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.sharedApplication().openURL(udacityLink)
        }
    }
    
    // MARK - UI update functions
    
    func dispatch_status_update(msg: String?) {
        if let msg = msg {
            dispatch_async(dispatch_get_main_queue()) {
                self.statusLabel.text = msg
            }
        }
    }
    
    func completeLogin() {
        println("Login Successful")
        self.dispatch_status_update("")
    }
    
}





