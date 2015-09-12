//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 8/28/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.stopAnimating()
        // Do any additional setup after loading the view, typically from a nib.
        let accessToken = FBSDKAccessToken.currentAccessToken()
        if let accessToken = accessToken {
            println(">>> already logged in")
            let alertTitle = "Facebook login failed"
            loginWithFB(alertTitle)
        } else {
            emailTextField.becomeFirstResponder()
        }
    }
    
    // MARK: FBSDKLoginButtonDelegate functions
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void {
        
        activityIndicator.stopAnimating()
        let alertTitle = "Facebook login failed"
        if let error = error {
            let errorMsg = error.domain + ": " + error.description
            AlertController.Alert(msg: errorMsg, title: title).showAlert(self)
        } else {
            if let token = result!.token {
                loginWithFB(alertTitle)
            } else {
                let errorMsg = "no token"
                AlertController.Alert(msg: errorMsg, title: title).showAlert(self)
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) -> Void {
        
        activityIndicator.startAnimating()
        UdacityCLient.shared_instance().logout() { success, errorMsg in
            
            self.stopActivityIndicator()
            var msg: String? = ""
            var alertTitle = ""
            if success {
                println(">>> Logged out")
                alertTitle = "Facebook logout complete"
                msg = ""
            } else {
                alertTitle = "Facebook logout error"
                msg = errorMsg
            }
            AlertController.Alert(msg: msg, title: alertTitle).dispatchAlert(self)
        }
    }
    
    // MARK: action buttons
    // FB login button does not require an action
    
    @IBAction func loginButtonTouchUp(sender: UIButton) {
        actionLoginWithEmailPassword()
    }
    
    
    @IBAction func signUpTouchUp(sender: UIButton) {
        if let udacityLink = NSURL(string : "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.sharedApplication().openURL(udacityLink)
        }
    }
    
    // MARK: support function
    
    func actionLoginWithEmailPassword() -> Void {
        
        let email = emailTextField.text
        let password = passwordTextField.text
        let alertTitle = "Login error"
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if email == "" {
            let msg = "Empty email field"
            AlertController.Alert(msg: msg, title: title).showAlert(self)
        } else if password == "" {
            let msg = "Empty password field"
            AlertController.Alert(msg: msg, title: title).showAlert(self)
        } else {
            loginWithEmailID(email, password: password, alertTitle: alertTitle)
        }
    }
    
    // MARK: UITextFieldDelegates
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let alertTitle = "Login error"
        if textField == emailTextField {
            if emailTextField.text == "" {
                let msg = "Empty email field"
                AlertController.Alert(msg: msg, title: title).showAlert(self)
            } else {
                textField.resignFirstResponder()
                passwordTextField.becomeFirstResponder()
            }
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            actionLoginWithEmailPassword()
        }
        return true
    }
    
    // MARK: UI update functions
    
    func loginWithFB(alertTitle: String) -> Void {
        activityIndicator.startAnimating()
        UdacityCLient.shared_instance().loginWithFacebook() { success, errorMsg in
            
            self.stopActivityIndicator()
            if success {
                self.completeLogin()
            } else {
                AlertController.Alert(msg: errorMsg, title: alertTitle).dispatchAlert(self)
            }
        }
    }
    
    func loginWithEmailID(email: String , password: String, alertTitle: String) -> Void {
        activityIndicator.startAnimating()
        UdacityCLient.shared_instance().loginWithEmailID(email, password: password) { success, errorMsg in
            
            self.stopActivityIndicator()
            if success {
                self.completeLogin()
            } else {
                AlertController.Alert(msg: errorMsg, title: alertTitle).dispatchAlert(self)
            }
        }
    }
   
    func completeLogin() -> Void {
        
        println(">>> Login Successful")
        dispatch_async(dispatch_get_main_queue()) {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("navViewController") as! UIViewController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func stopActivityIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.stopAnimating()
        }
    }
    
}





