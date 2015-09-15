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
    private var newStudentLocations = [StudentLocation]()
    
    // MARK: get list of student locations
    
    func getAllStudentLocations(completion_handler: (success: Bool, errorMsg: String?) -> Void) -> Void {
        
        // println(">>> " + __FUNCTION__)
        let skip = 0
        let count = 50
        newStudentLocations = []
        getStudentLocations(skip, count: count) {  success, errorMsg in
            if errorMsg != nil { // Handle error...
                println("ERROR getAll: \(errorMsg)")
            } else {
                // println(">>> " + __FUNCTION__ + " count new: \(self.newStudentLocations.count)")
                self.studentLocations = self.newStudentLocations
            }
            completion_handler(success: errorMsg == nil, errorMsg: errorMsg)
        }
    }

/* 
    This will recursively get all records:
    
    >>> bundle_id: com.udacity.OnTheMap
    >>> already logged in
    >>> Login Successful
    >>> getAllStudentLocations
    >>> getStudentLocations(_:count:completion_handler:) skip: 0, count rec: 50
    >>> getStudentLocations(_:count:completion_handler:) skip: 50, count rec: 100
    >>> getStudentLocations(_:count:completion_handler:) skip: 100, count rec: 150
    >>> getStudentLocations(_:count:completion_handler:) skip: 150, count rec: 153
    >>> getStudentLocations(_:count:completion_handler:) skip: 150, DONE
    >>> getStudentLocations(_:count:completion_handler:) skip+count: 150, count rec: 153
    >>> getStudentLocations(_:count:completion_handler:) skip+count: 100, count rec: 153
    >>> getStudentLocations(_:count:completion_handler:) skip+count: 50, count rec: 153
    >>> getAllStudentLocations count new: 153
    >>> setAnnotationsForStudentLocations() Annotations: 153
*/
    func getStudentLocations(skip: Int, count: Int, completion_handler: (success: Bool, errorMsg: String?) -> Void) -> Void {
        
        ParseClient.sendRequestForGetStudentLocations(skip, count: count) { results, errorMsg in
            if errorMsg != nil { // Handle error...
                println("ERROR get: \(errorMsg)")
                completion_handler(success: errorMsg == nil, errorMsg: errorMsg)
            } else {
                // println(results)     // TODO
                for record in results! {
                    // println("----\n\(record)\n")    // TODO
                    let student = StudentLocation(studentLocationDir: record as StudentLocationDir)
                    self.newStudentLocations.append(student)
                }
                // println(">>> " + __FUNCTION__ + " skip: \(skip), count rec: \(self.newStudentLocations.count)")
                if results!.count == count {
                    // we got all records we asked for, so there may be more
                    self.getStudentLocations(skip + count, count: count) { success, errorMsg in
                        if errorMsg != nil { // Handle error...
                            println("ERROR getAll: \(errorMsg)")
                        } else {
                            // println(">>> " + __FUNCTION__ + " skip+count: \(skip+count), count rec: \(self.newStudentLocations.count)")
                        }
                        completion_handler(success: errorMsg == nil, errorMsg: errorMsg)
                    }
                } else {
                    // no more data, we're done
                    // println(">>> " + __FUNCTION__ + " skip: \(skip), DONE")
                    completion_handler(success: errorMsg == nil, errorMsg: errorMsg)

                }
            }
        }
    }
    
    static func sendRequestForGetStudentLocations(skip: Int, count: Int, completion_handler: (results: [StudentLocationDir]?, errorMsg: String?) -> Void) -> Void {
        
        let url = ParseClient.Constants.baseURL + ParseClient.Methods.StudentLocation
        
        let parms: [String: AnyObject] = [
            ParseClient.JsonRequestKeys.limit: count,
            ParseClient.JsonRequestKeys.skip: skip,
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
    
    // MARK: update (put) a student location
    
    static func putStudentLocation(studentLocation: StudentLocation, objectId: String, completion_handler: (createdAt: String?, updatedAt: String?, errorMsg: String?) -> Void) -> Void {
        ParseClient.sendRequestForPutStudentLocation(studentLocation, objectId: objectId) { createdAt, updatedAt, errorMsg in
            
            completion_handler(createdAt: createdAt, updatedAt: updatedAt, errorMsg: errorMsg)
        }
    }
    
    static func sendRequestForPutStudentLocation(studentLocation: StudentLocation, objectId: String,completion_handler: (createdAt: String?, updatedAt: String?, errorMsg: String?) -> Void) -> Void {
        
        let url = ParseClient.Constants.baseURL + ParseClient.Methods.StudentLocation + "/" + objectId
        let parms = [String: AnyObject]()
        var jsonPostData = studentLocation.getDictFromStudent()
        //jsonPostData.removeValueForKey(JsonStudentKeys.objectId)
        
        HttpClient.shared_instance().httpPut(url, parameters: parms, jsonBody: jsonPostData, httpHeaderFields: ParseClient.HTTPHeaderFields.keyvalues, offset: 0) { data, error in
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
        static let skip  = "skip"
    }
    
    struct JsonStudentKeys {
        
        static let objectId  = "objectId"
        static let uniqueKey = "uniqueKey"
        static let firstname = "firstName"
        static let lastname  = "lastName"
        static let mediaURL  = "mediaURL"
        static let longitude = "longitude"
        static let latitude  = "latitude"
        static let mapString = "mapString"
    }
    
    struct JsonResponseKeys {
        
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        static let code      = "code"
        static let error     = "error"
        
    }
    
    // skip uniqueKey and mapString
    static let JsonStudentAllInputKeysForStrings = [JsonStudentKeys.objectId, JsonStudentKeys.uniqueKey, JsonStudentKeys.firstname, JsonStudentKeys.lastname, JsonStudentKeys.mediaURL, JsonStudentKeys.mapString]
    
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
