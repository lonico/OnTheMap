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
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    // MARK - FBSDKLoginButtonDelegate functions
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        let alertTitle = "Facebook login failed"
        if let error = error {
            let errorMsg = error.domain + ": " + error.description
            showAlert(errorMsg, title: title)
        } else {
            if let token = result!.token {
                UdacityCLient.shared_instance().loginWithFacebook() { success, errorMsg in
                    if success {
                        self.completeLogin()
                    } else {
                        self.dispatchAlert(errorMsg, title: alertTitle)
                    }
                }
            } else {
                let errorMsg = "no token"
                showAlert(errorMsg, title: alertTitle)
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
            let alertTitle = "Facebook login failed"
            self.dispatchAlert(msg, title: alertTitle)
        }
    }
    
    // MARK - action buttons
    // FB login button does not require an action
    
    @IBAction func loginButtonTouchUp(sender: UIButton) {
        
        let email = emailTextField.text
        let password = passwordTextField.text
        let alertTitle = "Login error"
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if email == "" {
            let msg = "Empty email field"
            showAlert(msg, title: alertTitle)
        } else if password == "" {
            let msg = "Empty password field"
            showAlert(msg, title: alertTitle)
        } else {
            UdacityCLient.shared_instance().loginWithEmailID(email, password: password) { success, errorMsg in
                if success {
                    self.completeLogin()
                } else {
                    self.dispatchAlert(errorMsg, title: alertTitle)
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
    
    func dispatchAlert(msg: String?, title: String?) {
        if let msg = msg {
            dispatch_async(dispatch_get_main_queue()) {
                self.showAlert(msg, title: title)
            }
            
        }
    }
    
    func showAlert(msg: String?, var title: String?) {
        
        if title == nil {
            title = "Alert"
        }
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the alert
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func completeLogin() {
        println("Login Successful")
        dispatch_sync(dispatch_get_main_queue()) {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("navViewController") as! UIViewController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
}





