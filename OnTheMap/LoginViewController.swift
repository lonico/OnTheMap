//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 8/28/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    var udacity_session_id: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
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
        
        login(email, password: password) { success, errorMsg in
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
    
    
        
    func login(email: String, password: String, completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
    
        let task = session.dataTaskWithRequest(request) { data, response, error in
            var success = false
            var errorMsg: String! = nil
            if error != nil {
                errorMsg = "Login error: " + error.localizedDescription
            } else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                // println(NSString(data: newData, encoding: NSUTF8StringEncoding))
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
    
    func loginWithFacebook(completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"DADFMS4SN9e8BAD6vMs6yWuEcrJlMZChFB0ZB0PCLZBY8FPFYxIPy1WOr402QurYWm7hj1ZCoeoXhAk2tekZBIddkYLAtwQ7PuTPGSERwH1DfZC5XSef3TQy1pyuAPBp5JJ364uFuGw6EDaxPZBIZBLg192U8vL7mZAzYUSJsZA8NxcqQgZCKdK4ZBA2l2ZA6Y1ZBWHifSM0slybL9xJm3ZBbTXSBZCMItjnZBH25irLhIvbxj01QmlKKP3iOnl8Ey;\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                // Handle error...
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
    
    func completeLogin() {
        println("Login Successful")
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



