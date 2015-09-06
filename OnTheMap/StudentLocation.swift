//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 9/6/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import Foundation
import MapKit

typealias StudentLocation = [String: AnyObject]

func getFullNameFromStudent(student: StudentLocation) -> String? {
    let fname = student[ParseClient.JsonStudentKeys.firstname] as? String
    let lname = student[ParseClient.JsonStudentKeys.lastname] as? String
    if fname == nil {
        return lname
    }
    if lname == nil {
        return fname
    }
    return fname! + " " + lname!
}

func getURLFromStudent(student: StudentLocation) -> String? {
    let url = student[ParseClient.JsonStudentKeys.mediaURL] as? String
    return url
}

func getCoordinateFromStudent (student: StudentLocation) -> CLLocationCoordinate2D {

    // Notice that the float values are being used to create CLLocationDegree values.
    // This is a version of the Double type.
    var latitude: Double = CLLocationDegrees(0)
    var longitude: Double = CLLocationDegrees(0)
    
    if let lat = student[ParseClient.JsonStudentKeys.latitude] as? Double {
        latitude = CLLocationDegrees(lat)
    }
    if let long = student[ParseClient.JsonStudentKeys.longitude] as? Double {
        longitude = CLLocationDegrees(long)
    }
    
    // The lat and long are used to create a CLLocationCoordinates2D instance.
    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    return coordinate
}