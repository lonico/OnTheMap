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
                    let student = StudentLocation(studentLocationDir: record as StudentLocationDir)
                    new_studentLocations.append(student)
                }
                self.studentLocations = new_studentLocations
            }
            completion_handler(success: errorMsg == nil, errorMsg: errorMsg)
        }
    }

    static func parseSendGetStudentLocations(completion_handler: (results: [StudentLocationDir]?, errorMsg: String?) -> Void) {
        
        let url = ParseClient.Constants.baseURL + ParseClient.Methods.StudentLocation
        
        let parms = [
            ParseClient.JsonRequestKeys.limit: 4,
            ParseClient.JsonRequestKeys.order: "-updatedAt"
        ]
        
        HttpClient.shared_instance().httpGet(url, parameters: parms, httpHeaderFields: ParseClient.HTTPHeaderFields.keyvalues) { data, error in
            var errorMsg: String! = nil
            var results: [StudentLocationDir]! = nil
            
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
    
    static let JsonStudentAllKeysForStrings = [JsonStudentKeys.firstname, JsonStudentKeys.lastname, JsonStudentKeys.mediaURL]
    static let JsonStudentAllKeysForDoubles = [JsonStudentKeys.latitude, JsonStudentKeys.longitude]
    static let JsonStudentAllKeys = JsonStudentAllKeysForStrings + JsonStudentAllKeysForDoubles
    

    struct HTTPHeaderFields {
        
        //request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        //request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        static let keyvalues = [
            "X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
            "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
            ]
    }
    
}

/*
// MARK: - Sample Data

// Some sample data. This is a dictionary that is more or less similar to the
// JSON data that you will download from Parse.

func hardCodedLocationData() -> [[String : AnyObject]] {
    return  [
        [
            "createdAt" : "2015-02-24T22:27:14.456Z",
            "firstName" : "Jessica",
            "lastName" : "Uelmen",
            "latitude" : 28.1461248,
            "longitude" : -82.75676799999999,
            "mapString" : "Tarpon Springs, FL",
            "mediaURL" : "www.linkedin.com/in/jessicauelmen/en",
            "objectId" : "kj18GEaWD8",
            "uniqueKey" : 872458750,
            "updatedAt" : "2015-03-09T22:07:09.593Z"
        ], [
            "createdAt" : "2015-02-24T22:35:30.639Z",
            "firstName" : "Gabrielle",
            "lastName" : "Miller-Messner",
            "latitude" : 35.1740471,
            "longitude" : -79.3922539,
            "mapString" : "Southern Pines, NC",
            "mediaURL" : "http://www.linkedin.com/pub/gabrielle-miller-messner/11/557/60/en",
            "objectId" : "8ZEuHF5uX8",
            "uniqueKey" : 2256298598,
            "updatedAt" : "2015-03-11T03:23:49.582Z"
        ], [
            "createdAt" : "2015-02-24T22:30:54.442Z",
            "firstName" : "Jason",
            "lastName" : "Schatz",
            "latitude" : 37.7617,
            "longitude" : -122.4216,
            "mapString" : "18th and Valencia, San Francisco, CA",
            "mediaURL" : "http://en.wikipedia.org/wiki/Swift_%28programming_language%29",
            "objectId" : "hiz0vOTmrL",
            "uniqueKey" : 2362758535,
            "updatedAt" : "2015-03-10T17:20:31.828Z"
        ], [
            "createdAt" : "2015-03-11T02:48:18.321Z",
            "firstName" : "Jarrod",
            "lastName" : "Parkes",
            "latitude" : 34.73037,
            "longitude" : -86.58611000000001,
            "mapString" : "Huntsville, Alabama",
            "mediaURL" : "https://linkedin.com/in/jarrodparkes",
            "objectId" : "CDHfAy8sdp",
            "uniqueKey" : 996618664,
            "updatedAt" : "2015-03-13T03:37:58.389Z"
        ]
    ]
}

*/
