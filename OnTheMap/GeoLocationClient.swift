//
//  GeoLocationClient.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 9/8/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import Foundation
import MapKit

struct GeoLocationClient {
    
    // MARK: forward geocoding
    
    static func getPlacemark(address: String, completion_handler: (placemark: CLPlacemark!, alert: AlertController.Alert!) -> Void) -> Void {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            var studentPlacemark: CLPlacemark! = nil
            var alert: AlertController.Alert! = nil
            if let error = error {
                alert = AlertController.Alert(
                    msg: error.localizedDescription,
                    title: AlertController.AlertTitle.LocalizationError)
            } else if let placemarks = placemarks {
                if placemarks.count == 0 {
                    alert = AlertController.Alert(
                        msg: "Unexpected error (empty array)",
                        title: AlertController.AlertTitle.LocalizationError)
                } else {
                    if placemarks.count > 1 {
                        alert = AlertController.Alert(
                            msg: "Got \(placemarks.count) results, using the first one",
                            title: AlertController.AlertTitle.LocalizationAmbiguityWarning)
                    }
                    studentPlacemark = placemarks[0] as! CLPlacemark
                }
            } else {
                alert = AlertController.Alert(
                    msg: "Unexpected error (nil)",
                    title: AlertController.AlertTitle.LocalizationError)
            }
            completion_handler(placemark: studentPlacemark, alert: alert)
        }
    }
}