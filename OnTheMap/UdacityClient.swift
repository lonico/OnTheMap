//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 8/30/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class UdacityCLient: NSObject {
    
    var session: NSURLSession
    var udacity_session_id: String!
    
    override init () {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func loginWithEmailID(emailId: String, password: String, completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        
        let hTTPBody = "{\"udacity\": {\"username\": \"\(emailId)\", \"password\": \"\(password)\"}}"
        login(hTTPBody, completion_handler: completion_handler)
    }
    
    func loginWithFacebook(completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        let hTTPBody = "{\"facebook_mobile\": {\"access_token\":\"\(accessToken)\"}}"
        login(hTTPBody, completion_handler: completion_handler)
    }
    
    func login(httpBody: String, completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            var success = false
            var errorMsg: String! = nil
            if error != nil {
                errorMsg = error.localizedDescription
            } else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                // println(NSString(data: newData, encoding: NSUTF8StringEncoding))
                self.parseJSONWithCompletionHandler(newData) { result, error in
                    if let error = error {
                        errorMsg = error.localizedDescription
                    } else {
                        if let session_dict = result.valueForKey("session") as? [String: String] {
                            if let session_id = session_dict["id"] {
                                self.udacity_session_id = session_id
                                success = true
                            } else {
                                errorMsg = "Unexpected error, no 'id' field"
                            }
                        } else if let status = result.valueForKey("status") as? Int {
                            errorMsg = ""
                            if let errorStr = result.valueForKey("error") as? String {
                                errorMsg = errorStr
                            }
                            errorMsg = errorMsg + " (\(status))"
                        } else {
                            errorMsg = "Unexpected error, no 'session' field"
                        }
                    }
                    completion_handler(success: success, errorMsg: errorMsg)
                }
            }
        }
        task.resume()
    }
    
    func logout(completion_handler: (success: Bool, errorMsg: String?) -> Void) {
    
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        let task = session.dataTaskWithRequest(request) { data, response, error in
            var success = false
            var errorMsg = ""
            if error != nil { // Handle error…
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            // println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            self.parseJSONWithCompletionHandler(newData) { result, error in
                if let error = error {
                    errorMsg = error.localizedDescription
                } else {
                    if let session_dict = result.valueForKey("session") as? [String: String] {
                        if let session_id = session_dict["id"] {
                            self.udacity_session_id = session_id
                            success = true
                        } else {
                            errorMsg = "Unexpected error, no 'id' field"
                        }
                    } else if let status = result.valueForKey("status") as? Int {
                        errorMsg = ""
                        if let errorStr = result.valueForKey("error") as? String {
                            errorMsg = errorStr
                        }
                        errorMsg = errorMsg + " (\(status))"
                    } else {
                        errorMsg = "Unexpected error, no 'session' field"
                    }
                }
                completion_handler(success: success, errorMsg: errorMsg)
            }

        }
    task.resume()
    }

    class func shared_instance() -> UdacityCLient {

        struct Singleton {
            static var sharedInstance = UdacityCLient()
        }
        
        return Singleton.sharedInstance
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

}