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
    
    var udacity_session_id: String!
    var udacity_user_id: String!
    
    override init () {
        //session = NSURLSession.sharedSession()
        super.init()
    }
    
    func loginWithEmailID(emailId: String, password: String, completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        
        let jsonBody = [
            UdacityCLient.JsonRequestKeys.udacity:
                [ UdacityCLient.JsonRequestKeys.udacity_userid: emailId,
                  UdacityCLient.JsonRequestKeys.udacity_password : password ]
        ]
        login(jsonBody, completion_handler: completion_handler)
    }
    
    func loginWithFacebook(completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString

        let jsonBody = [
            UdacityCLient.JsonRequestKeys.facebook_mobile:
                [ UdacityCLient.JsonRequestKeys.fbm_accesstoken: accessToken ]
        ]
        login(jsonBody, completion_handler: completion_handler)
    }
    
    func login(jsonBody: [String: AnyObject], completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        
        let url = UdacityCLient.Constants.baseURL + UdacityCLient.Methods.session
        
        HttpClient.shared_instance().httpPost(url, parameters: nil, jsonBody: jsonBody) { data, error in
            var errorMsg: String! = nil
            if let error = error {
                println(error)
                errorMsg = error
            } else {
                self.parseJSONWithCompletionHandler(data) { result, error in
                    if let error = error {
                        errorMsg = error.localizedDescription
                    } else {
                        errorMsg = self.getAndSetSessionFromResult(result)
                        if (errorMsg == nil) {
                            if let account_dict = result.valueForKey(UdacityCLient.JsonDataKeys.account) as? [String: AnyObject] {
                                if let user_id = account_dict[UdacityCLient.JsonDataKeys.key] as? String {
                                    self.udacity_user_id = user_id
                                } else {
                                    errorMsg = "Unexpected error, no '\(UdacityCLient.JsonDataKeys.key)' key"
                                }
                            } else {
                                errorMsg = "Unexpected error, no '\(UdacityCLient.JsonDataKeys.account)' key"
                            }
                        }
                    }
                }
            }
            completion_handler(success: errorMsg == nil, errorMsg: errorMsg)
        }
    }
            
    func logout(completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        
        logoutFromUdacity() { success, errorMsg in
            self.logoutFromFB()
            completion_handler(success: success, errorMsg: errorMsg)
                
        }
    }
        
    func logoutFromFB() -> Void {
        if let accessToken = FBSDKAccessToken.currentAccessToken() {
            FBSDKLoginManager().logOut()
        }
        else {
            println(">>> Already logged out")
        }
    }
    
    func logoutFromUdacity(completion_handler: (success: Bool, errorMsg: String?) -> Void) {
    
        let url = UdacityCLient.Constants.baseURL + UdacityCLient.Methods.session
            
        HttpClient.shared_instance().httpDelete(url, parameters: nil) { data, error in
            var errorMsg: String! = nil
            if error != nil { // Handle error…
                errorMsg = error
            } else {
                // println(NSString(data: data, encoding: NSUTF8StringEncoding))
                self.parseJSONWithCompletionHandler(data) { result, error in
                    if let error = error {
                        errorMsg = error.localizedDescription
                    } else {
                        errorMsg = self.getAndSetSessionFromResult(result)
                    }
                }
                completion_handler(success: errorMsg == nil, errorMsg: errorMsg)
            }
        }
    }
    
    func parseGetStudentLocations(completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        
        parseSendGetStudentLocations() { results, errorMsg in
            if errorMsg != nil { // Handle error...
                return
            }
            println(results)
        }
    }
    
    func parseSendGetStudentLocations(completion_handler: (results: [String:AnyObject]?, errorMsg: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=4&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = HttpClient.shared_instance().session
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            self.parseJSONWithCompletionHandler(newData) { result, error in
                var errorMsg: String! = nil
                var results: [String:AnyObject]! = nil
                if let error = error {
                    errorMsg = error.localizedDescription
                } else {
                    if let got_results = result.valueForKey("results") as? [String: String] {
                        results = got_results
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
                completion_handler(results: results, errorMsg: errorMsg)
            }

        }
        task.resume()
    }
    

    func getDataForUser(userid: String, completion_handler: (success: Bool, errorMsg: String?) -> Void) {
    
        let url = NSURL(string: "https://www.udacity.com/api/users/\(userid)")!
        let request = NSMutableURLRequest(URL: url)
        let session = HttpClient.shared_instance().session
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
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
    

    func getAndSetSessionFromResult(result: AnyObject) -> String! {
        
        var errorMsg: String! = nil
        if let session_dict = result.valueForKey(UdacityCLient.JsonDataKeys.session) as? [String: String] {
            if let session_id = session_dict[UdacityCLient.JsonDataKeys.id] {
                self.udacity_session_id = session_id
            } else {
                errorMsg = "Unexpected error, no '\(UdacityCLient.JsonDataKeys.id)' key"
            }
        } else {
            errorMsg = getStatusAndErrorMessageFromResult(result, missing_key: UdacityCLient.JsonDataKeys.session)
        }
        return errorMsg
    }
    

    func getStatusAndErrorMessageFromResult(result: AnyObject, missing_key: String!) -> String {
    
        var errorMsg: String
        if let status = result.valueForKey(UdacityCLient.JsonDataKeys.status) as? Int {
                errorMsg = ""
                if let errorStr = result.valueForKey(UdacityCLient.JsonDataKeys.error) as? String {
                    errorMsg = errorStr
                }
                errorMsg = errorMsg + " (\(status))"
        } else {
            errorMsg = "Unexpected error, "
            if (missing_key != nil) {
                errorMsg += "no '\(missing_key)' and "
            }
            errorMsg += "no '\(UdacityCLient.JsonDataKeys.status)' key"
        }
        return errorMsg
    }
    
    struct Constants {
        
        static let baseURL = "https://www.udacity.com/api/"
    }
    
    struct Methods {
        
        static let session = "session"
        static let user = "user"
    }
    
    struct JsonRequestKeys {
        
        static let udacity = "udacity"
        static let udacity_userid = "username"
        static let udacity_password = "password"
        static let facebook_mobile = "facebook_mobile"
        static let fbm_accesstoken = "access_token"
    }
    
    struct JsonDataKeys {
        
        static let session = "session"
        static let id = "id"
        static let account = "account"
        static let key = "key"
        static let error = "error"
        static let status = "status"
    }
    
    
}