//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 9/5/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import Foundation

class ParseClient {

    class func parseGetStudentLocations(completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        
        parseSendGetStudentLocations() { results, errorMsg in
            if errorMsg != nil { // Handle error...
                return
            }
            println(results)
        }
    }

    class func parseSendGetStudentLocations(completion_handler: (results: [String:AnyObject]?, errorMsg: String?) -> Void) {
        
        let url = ParseClient.Constants.baseURL + ParseClient.Methods.StudentLocation
        
        let parms = [
            ParseClient.JsonRequestKeys.limit: 4,
            ParseClient.JsonRequestKeys.order: "-updatedAt"
        ]
        
        HttpClient.shared_instance().httpGet(url, parameters: parms, httpHeaderFields: ParseClient.HTTPHeaderFields.keyvalues) { data, error in
            var errorMsg: String! = nil
            var results: [String:AnyObject]! = nil
            
            println(NSString(data: data, encoding: NSUTF8StringEncoding))

            if let error = error {
                println(error)
                errorMsg = error
            } else {
                HttpClient.parseJSONWithCompletionHandler(data) { result, error in
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
                }
            }
            completion_handler(results: results, errorMsg: errorMsg)
        }
        
    }
    
    struct Constants {
        
        static let baseURL = "https://api.parse.com/1/classes/"
    }
    
    struct Methods {
        
        static let StudentLocation = "StudentLocation"
    }
    
    struct JsonRequestKeys {
        
        static let limit = "limit"
        static let order = "order"
    }

    struct HTTPHeaderFields {
        
        //request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        //request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        static let keyvalues = [
            "X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
            "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
            ]
    }
    
    
}

