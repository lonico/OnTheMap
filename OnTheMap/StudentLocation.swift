//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 9/6/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import Foundation
import MapKit

typealias StudentLocationDir = [String: AnyObject]

struct StudentLocation {
    
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    
    func getFullNameFromStudent() -> String? {
        return join(" ", [self.firstName, self.lastName])
    }
    
    func getURLFromStudent() -> String? {
        return self.mediaURL
    }
    
    func getCoordinateFromStudent() -> CLLocationCoordinate2D {
        
        // Notice that the float values are being used to create CLLocationDegree values.
        // This is a version of the Double type.
        var latitude = CLLocationDegrees(self.latitude)
        var longitude = CLLocationDegrees(self.longitude)
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return coordinate
    }
    
}

extension StudentLocation {
    
    init(studentLocationDir dir: StudentLocationDir) {
        
        var _firstName = ""
        var _lastName = ""
        var _mediaURL = ""
        var _latitude = 0.0
        var _longitude = 0.0
        for key in ParseClient.JsonStudentAllKeysForStrings {
            var value = ""
            if let stringValue = dir[key] as? String {
                value = stringValue
            }
            switch key {
            case ParseClient.JsonStudentKeys.firstname: _firstName = value
            case ParseClient.JsonStudentKeys.lastname: _lastName = value
            case ParseClient.JsonStudentKeys.mediaURL: _mediaURL = value
            default: break  // make Xcode happy, even though all cases are exhausted
            }
            
        }
        for key in ParseClient.JsonStudentAllKeysForDoubles {
            var value = 0.0
            if let doubleValue = dir[key] as? Double {
                value = doubleValue
            }
            switch key {
            case ParseClient.JsonStudentKeys.latitude: _latitude = value
            case ParseClient.JsonStudentKeys.longitude: _longitude = value
            default: break  // make Xcode happy, even though all cases are exhausted
            }
        }
        
        firstName = _firstName
        lastName = _lastName
        mediaURL = _mediaURL
        latitude = _latitude
        longitude = _longitude
        
        // save a but of time, as these are not used
        uniqueKey = "N/A"
        mapString = "N/A"
    }
}

