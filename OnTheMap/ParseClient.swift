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
    
    // MARK: get list of student locations
    
    func getStudentLocations(completion_handler: (success: Bool, errorMsg: String?) -> Void) -> Void {
        
        ParseClient.sendRequestForGetStudentLocations() { results, errorMsg in
            if errorMsg != nil { // Handle error...
                println("ERROR: \(errorMsg)")
            } else {
                // println(results)     // TODO
                var new_studentLocations = [StudentLocation]()
                
                for record in results! {
                    // println("----\n\(record)\n")    // TODO
                    let student = StudentLocation(studentLocationDir: record as StudentLocationDir)
                    new_studentLocations.append(student)
                }
                self.studentLocations = new_studentLocations
            }
            completion_handler(success: errorMsg == nil, errorMsg: errorMsg)
        }
    }
    
    static func sendRequestForGetStudentLocations(completion_handler: (results: [StudentLocationDir]?, errorMsg: String?) -> Void) -> Void {
        
        let url = ParseClient.Constants.baseURL + ParseClient.Methods.StudentLocation
        
        let parms = [
            ParseClient.JsonRequestKeys.limit: 200,
            ParseClient.JsonRequestKeys.skip: 0,
            ParseClient.JsonRequestKeys.order: "-updatedAt"
        ]
        
        HttpClient.shared_instance().httpGet(url, parameters: parms, httpHeaderFields: ParseClient.HTTPHeaderFields.keyvalues, offset: 0) { data, error in
            
            var errorMsg: String! = nil
            // println(NSString(data: data, encoding: NSUTF8StringEncoding))  // TODO

            if let error = error {
                println(error)      // TODO
                errorMsg = error
                completion_handler(results: nil, errorMsg: errorMsg)
            } else {
                HttpClient.parseJSONWithCompletionHandler(data) { result, error in
                    var results: [StudentLocationDir]! = nil
                    if let error = error {
                        errorMsg = error.localizedDescription
                    } else {
                        if let got_results = result.valueForKey("results") as? [[String: AnyObject]] {
                            results = got_results
                        } else {
                            errorMsg = ParseClient.getCodeAndErrorMessageFromResult(result, missing_keys: ["results"])
                        }
                    }
                    completion_handler(results: results, errorMsg: errorMsg)
                }
            }
            
        }
        
    }
    
    // MARK: post a new student location
    
    static func postStudentLocation(studentLocation: StudentLocation, completion_handler: (createdAt: String?, updatedAt: String?, errorMsg: String?) -> Void) -> Void {
        ParseClient.sendRequestForPostStudentLocation(studentLocation) { createdAt, updatedAt, errorMsg in
            
            completion_handler(createdAt: createdAt, updatedAt: updatedAt, errorMsg: errorMsg)
        }
    }
    
    static func sendRequestForPostStudentLocation(studentLocation: StudentLocation, completion_handler: (createdAt: String?, updatedAt: String?, errorMsg: String?) -> Void) -> Void {
        
        let url = ParseClient.Constants.baseURL + ParseClient.Methods.StudentLocation
        let parms = [String: AnyObject]()
        let jsonPostData = studentLocation.getDictFromStudent()
        
        HttpClient.shared_instance().httpPost(url, parameters: parms, jsonBody: jsonPostData, httpHeaderFields: ParseClient.HTTPHeaderFields.keyvalues, offset: 0) { data, error in
            var errorMsg: String! = nil
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            // Optional({"code":142,"error":"mapString is required for a Student Location"}
            // Optional({"updatedAt":"2015-09-09T06:32:23.929Z","objectId":"VQPcz7uDwZ"}
            
            if let error = error {
                println(error)
                errorMsg = error
                completion_handler(createdAt: nil, updatedAt: nil, errorMsg: errorMsg)
            } else {
                HttpClient.parseJSONWithCompletionHandler(data) { result, error in
                    var createdAt: String! = nil
                    var updatedAt: String! = nil
                    if let error = error {
                        errorMsg = error.localizedDescription
                    } else {
                        if let value = result.valueForKey(JsonResponseKeys.createdAt) as? String {
                            createdAt = value
                        } else if let value = result.valueForKey(JsonResponseKeys.updatedAt) as? String {
                            updatedAt = value
                        } else {
                            errorMsg = self.getCodeAndErrorMessageFromResult(result, missing_keys: [JsonResponseKeys.createdAt, JsonResponseKeys.updatedAt])
                        }
                    }
                    completion_handler(createdAt: createdAt, updatedAt: updatedAt, errorMsg: errorMsg)
                }
            }
        }
    }
    
    // MARK: support functions
    
    static func getCodeAndErrorMessageFromResult(result: AnyObject, missing_keys: [String]!) -> String {
        
        var errorMsg: String
        if let code = result.valueForKey(JsonResponseKeys.code) as? Int {
            errorMsg = ""
            if let errorStr = result.valueForKey(JsonResponseKeys.error) as? String {
                errorMsg = errorStr
            }
            errorMsg = errorMsg + " (\(code))"
        } else {
            errorMsg = "Unexpected error, "
            if (missing_keys != nil) {
                let missing = ", nor ".join(missing_keys)
                errorMsg += "no '\(missing)' and "
            }
            errorMsg += "no '\(JsonResponseKeys.code)' key"
        }
        return errorMsg
    }

    static func shared_instance() -> ParseClient {
        
        struct Singleton {
            static var shared_instance = ParseClient()
        }
        return Singleton.shared_instance
    }
    
    // MARK: Constants for HTTP requests
    
    struct Constants {
        
        static let baseURL = "https://api.parse.com/1/classes/"
    }
    
    struct Methods {
        
        static let StudentLocation = "StudentLocation"
    }
    
    struct JsonRequestKeys {
        
        static let limit = "limit"
        static let order = "order"
        static let skip = "skip"
    }
    
    struct JsonStudentKeys {
        
        static let uniqueKey = "uniqueKey"
        static let firstname = "firstName"
        static let lastname = "lastName"
        static let mediaURL = "mediaURL"
        static let longitude = "longitude"
        static let latitude = "latitude"
        static let mapString = "mapString"
    }
    
    struct JsonResponseKeys {
        
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        static let code = "code"
        static let error = "error"
        
    }
    
    // skip uniqueKey and mapString
    static let JsonStudentAllInputKeysForStrings = [JsonStudentKeys.uniqueKey, JsonStudentKeys.firstname, JsonStudentKeys.lastname, JsonStudentKeys.mediaURL, JsonStudentKeys.mapString]
    
    static let JsonStudentAllInputKeysForDoubles = [JsonStudentKeys.latitude, JsonStudentKeys.longitude]
    
    static let JsonStudentAllKeys = JsonStudentAllInputKeysForStrings + JsonStudentAllInputKeysForDoubles
    
    struct HTTPHeaderFields {
        
        //request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        //request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        static let keyvalues = [
            "X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
            "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
            ]
    }
}
