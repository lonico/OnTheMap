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
    
    var udacity_session_id: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
    }
    
    // MARK - FBSDKLoginButtonDelegate functions
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("logingbuttondidcomplete")
        if let error = error {
            var errorMsg = "Facebook login failed " + error.domain + ": " + error.description
            statusLabel.text = errorMsg
        } else {
            if let token = result!.token {
                print("SUCCESS: ")
                println(token)
                loginWithFacebook() { success, errorMsg in
                    if success {
                        self.completeLogin()
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.statusLabel.text = errorMsg
                        }
                    }
                }
            } else {
                println("NOT LOGGED")
                statusLabel.text = "Facebook login failed"
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("logingbuttondidlogout")
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
            return
        }
        if password == "" {
            statusLabel.text = "Empty password field"
            return
        }
        statusLabel.text = ""
        
        loginWithEmailID(email, password: password) { success, errorMsg in
            if success {
                self.completeLogin()
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.statusLabel.text = errorMsg
                }
            }
        }
    }
    
    @IBAction func signUpTouchUp(sender: UIButton) {
        if let udacityLink = NSURL(string : "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.sharedApplication().openURL(udacityLink)
        }
    }
    
    // MARK - support functions
    
    func loginWithEmailID(emailId: String, password: String, completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        let hTTPBody = "{\"udacity\": {\"username\": \"\(emailId)\", \"password\": \"\(password)\"}}"
        login(hTTPBody, completion_handler: completion_handler)
    }
    
    func loginWithFacebook(completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        println(accessToken)
        let hTTPBody = "{\"facebook_mobile\": {\"access_token\":\"\(accessToken)\"}}"
        login(hTTPBody, completion_handler: completion_handler)
    }
    
    func login(httpBody: String, completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
    
        let task = session.dataTaskWithRequest(request) { data, response, error in
            var success = false
            var errorMsg: String! = nil
            if error != nil {
                errorMsg = "Login error: " + error.localizedDescription
            } else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                println(NSString(data: newData, encoding: NSUTF8StringEncoding))
                parseJSONWithCompletionHandler(newData) { result, error in
                    if let error = error {
                        errorMsg = "Login error: " + error.localizedDescription
                    } else {
                        if let session_dict = result.valueForKey("session") as? [String: String] {
                            if let session_id = session_dict["id"] {
                                self.udacity_session_id = session_id
                                success = true
                            } else {
                                errorMsg = "Unexpected login error, no 'id' field"
                            }
                        } else if let status = result.valueForKey("status") as? Int {
                            errorMsg = "Login error:"
                            if let errorStr = result.valueForKey("error") as? String {
                                errorMsg = errorMsg + " " + errorStr
                            }
                            errorMsg = errorMsg + " (\(status))"
                        } else {
                            errorMsg = "Unexpected login error, no 'session' field"
                        }
                    }
                    completion_handler(success: success, errorMsg: errorMsg)
                }
            }
        }
        task.resume()
    }
    
    func completeLogin() {
        println("Login Successful")
        dispatch_async(dispatch_get_main_queue()) {
            self.statusLabel.text = ""
        }

    }
}


/* Helper: Given raw JSON, return a usable Foundation object */
func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
    
    var parsingError: NSError? = nil
    
    let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
    
    if let error = parsingError {
        completionHandler(result: nil, error: error)
    } else {
        completionHandler(result: parsedResult, error: nil)
    }
}



