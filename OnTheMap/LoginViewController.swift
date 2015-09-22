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
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorTitle: UILabel!
    @IBOutlet weak var errorMsg: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorView.layer.cornerRadius = 10.0
        
        hideError()
        activityIndicator.stopAnimating()
        // Do any additional setup after loading the view, typically from a nib.
        let accessToken = FBSDKAccessToken.currentAccessToken()
        if let accessToken = accessToken {
            // in case somthing bad happens
            let alertTitle = AlertController.AlertTitle.FBLoginFailed
            loginWithFB(alertTitle)
        }
    }
    
    // MARK: FBSDKLoginButtonDelegate functions
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void {
        
        activityIndicator.stopAnimating()
        hideError()
        let alertTitle = AlertController.AlertTitle.FBLoginFailed
        if let error = error {
            let errorMsg = error.domain + ": " + error.description
            AlertController.Alert(msg: errorMsg, title: alertTitle).showAlert(self)
        } else {
            if let token = result!.token {
                loginWithFB(alertTitle)
            } else {
                let errorMsg = "no token"
                AlertController.Alert(msg: errorMsg, title: alertTitle).showAlert(self)
                showError(errorMsg, title: alertTitle)
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) -> Void {
        
        hideError()
        activityIndicator.startAnimating()
        UdacityCLient.shared_instance().logout() { success, errorMsg in
            
            self.stopActivityIndicator()
            var msg: String? = ""
            var alertTitle = ""
            if success {
                alertTitle = AlertController.AlertTitle.FBLogoutCompleted
                msg = ""
            } else {
                alertTitle = AlertController.AlertTitle.FBLogoutFailed
                msg = errorMsg
            }
            let alert = AlertController.Alert(msg: errorMsg, title: alertTitle) { action in
                self.dispatchError(errorMsg, title: alertTitle)
            }
            alert.dispatchAlert(self)
        }
    }
    
    // MARK: action buttons
    // FB login button does not require an action
    
    @IBAction func loginButtonTouchUp(sender: UIButton) {
        
        actionLoginWithEmailPassword()
    }
    
    @IBAction func signUpTouchUp(sender: UIButton) {
        
        hideError()
        if let udacityLink = NSURL(string : "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.sharedApplication().openURL(udacityLink)
        }
    }
    
    // MARK: support function
    
    func actionLoginWithEmailPassword() -> Void {
        
        let email = emailTextField.text
        let password = passwordTextField.text
        let alertTitle = AlertController.AlertTitle.LoginError
        
        hideError()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if email == "" {
            let msg = "Empty email field"
            AlertController.Alert(msg: msg, title: alertTitle).showAlert(self)
            showError(msg, title: alertTitle)
        } else if password == "" {
            let msg = "Empty password field"
            AlertController.Alert(msg: msg, title: alertTitle).showAlert(self)
            showError(msg, title: alertTitle)
        } else {
            loginWithEmailID(email, password: password, alertTitle: alertTitle)
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let alertTitle = AlertController.AlertTitle.LoginError
        if textField == emailTextField {
            textField.resignFirstResponder()
            if emailTextField.text == "" {
                let msg = "Empty email field"
                AlertController.Alert(msg: msg, title: alertTitle).showAlert(self)
                showError(msg, title: alertTitle)
            } else {
                hideError()
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
                let alert = AlertController.Alert(msg: errorMsg, title: alertTitle) { action in
                    self.dispatchError(errorMsg, title: alertTitle)
                }
                alert.dispatchAlert(self)
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
                let alert = AlertController.Alert(msg: errorMsg, title: alertTitle) { action in
                    self.dispatchError(errorMsg, title: alertTitle)
                    }
                alert.dispatchAlert(self)
            }
        }
    }
   
    func completeLogin() -> Void {
        
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
    
    func setError(msg: String!, title: String!) {
        if let title = title {
            errorTitle.text = title
        } else {
            errorTitle.text = ""
        }
        if let msg = msg {
            errorMsg.text = msg
        } else {
            errorMsg.text = ""
        }
    }

    func showError(msg: String!, title: String!) {
        setError(msg, title: title)
        errorView.hidden = false
    }
    
    func dispatchError(msg: String!, title: String!) {
        setError(msg, title: title)
        dispatch_async(dispatch_get_main_queue()) {
            self.errorView.hidden = false
        }
    }
    
    func hideError() {
        setError("", title: "")
        errorView.hidden = true
    }
}





