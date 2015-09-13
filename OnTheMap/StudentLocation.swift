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
    
    func getFullNameFromStudent() -> String {
        return join(" ", [self.firstName, self.lastName])
    }
    
    func getURLFromStudent() -> String {
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
    
    func getDictFromStudent() -> [String:AnyObject] {
        var dict = [String:AnyObject]()
        for key in ParseClient.JsonStudentAllKeys {
            dict[key] = getValueForFieldName(key)
        }
        return dict
    }
    
    func getValueForFieldName(key: String) -> AnyObject {
        switch key {
        case ParseClient.JsonStudentKeys.uniqueKey: return self.uniqueKey
        case ParseClient.JsonStudentKeys.firstname: return self.firstName
        case ParseClient.JsonStudentKeys.lastname: return self.lastName
        case ParseClient.JsonStudentKeys.mediaURL: return self.mediaURL
        case ParseClient.JsonStudentKeys.latitude: return self.latitude
        case ParseClient.JsonStudentKeys.longitude: return self.longitude
        case ParseClient.JsonStudentKeys.mapString: return self.mapString
        default: return "N/A"
        }
    }
}

extension StudentLocation {
    
    init(studentLocationDir dir: StudentLocationDir) {
        
        var _uniqueKey = ""
        var _firstName = ""
        var _lastName  = ""
        var _mediaURL  = ""
        var _latitude  = 0.0
        var _longitude = 0.0
        var _mapString = ""
        
        for key in ParseClient.JsonStudentAllInputKeysForStrings {
            var value = ""
            if let stringValue = dir[key] as? String {
                value = stringValue
            }
            switch key {
            case ParseClient.JsonStudentKeys.uniqueKey: _uniqueKey = value
            case ParseClient.JsonStudentKeys.firstname: _firstName = value
            case ParseClient.JsonStudentKeys.lastname: _lastName = value
            case ParseClient.JsonStudentKeys.mediaURL: _mediaURL = value
            case ParseClient.JsonStudentKeys.mapString: _mapString = value
            default: break  // make Xcode happy, even though all cases are exhausted
            }
            
        }
        for key in ParseClient.JsonStudentAllInputKeysForDoubles {
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
        
        uniqueKey = _uniqueKey
        firstName = _firstName
        lastName  = _lastName
        mediaURL  = _mediaURL
        latitude  = _latitude
        longitude = _longitude
        mapString = _mapString
    }
}

