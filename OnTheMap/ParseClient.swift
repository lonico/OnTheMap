//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 9/5/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import Foundation



class ParseClient {

    var studentLocations = [StudentLocation]()
    
    func parseGetStudentLocations(completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        
        ParseClient.parseSendGetStudentLocations() { results, errorMsg in
            if errorMsg != nil { // Handle error...
                println("ERROR: \(errorMsg)")
            } else {
                println(results)
                var new_studentLocations = [StudentLocation]()
                
                for record in results! {
                    println("----\n\(record)\n")
                    let student = record as StudentLocation
                    new_studentLocations.append(student)
                }
                self.studentLocations = new_studentLocations
            }
            completion_handler(success: errorMsg == nil, errorMsg: errorMsg)
        }
    }

    static func parseSendGetStudentLocations(completion_handler: (results: [StudentLocation]?, errorMsg: String?) -> Void) {
        
        let url = ParseClient.Constants.baseURL + ParseClient.Methods.StudentLocation
        
        let parms = [
            ParseClient.JsonRequestKeys.limit: 4,
            ParseClient.JsonRequestKeys.order: "-updatedAt"
        ]
        
        HttpClient.shared_instance().httpGet(url, parameters: parms, httpHeaderFields: ParseClient.HTTPHeaderFields.keyvalues) { data, error in
            var errorMsg: String! = nil
            var results: [StudentLocation]! = nil
            
            println(NSString(data: data, encoding: NSUTF8StringEncoding))

            if let error = error {
                println(error)
                errorMsg = error
            } else {
                HttpClient.parseJSONWithCompletionHandler(data) { result, error in
                    if let error = error {
                        errorMsg = error.localizedDescription
                    } else {
                        if let got_results = result.valueForKey("results") as? [[String: AnyObject]] {
                            results = got_results
                        } else if let status = result.valueForKey("status") as? Int {
                            errorMsg = ""
                            if let errorStr = result.valueForKey("error") as? String {
                                errorMsg = errorStr
                            }
                            errorMsg = errorMsg + " (\(status))"
                        } else {
                            errorMsg = "Unexpected error, no 'results' field"
                        }
                    }
                }
            }
            completion_handler(results: results, errorMsg: errorMsg)
        }
        
    }
    
    static func shared_instance() -> ParseClient {
        
        struct Singleton {
            static var shared_instance = ParseClient()
        }
        return Singleton.shared_instance
    }
    
    // MARK - Constants for HTTP requests
    
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
    
    struct JsonStudentKeys {
        
        static let firstname = "firstName"
        static let lastname = "lastName"
        static let mediaURL = "mediaURL"
        static let longitude = "longitude"
        static let latitude = "latitude"
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

