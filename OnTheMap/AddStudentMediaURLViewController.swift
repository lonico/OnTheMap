        //
//  AddStudentMediaURLViewController.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 9/7/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import UIKit
import MapKit

class AddStudentMediaURLViewController: UIViewController, UITextFieldDelegate {

    var placemark: CLPlacemark!
    var mapString: String!
    
    @IBOutlet weak var mediaURL: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(animated: Bool) {
        if let placemark = placemark {
            var pmCircularRegion = placemark.region as! CLCircularRegion
            var region = MKCoordinateRegionMakeWithDistance(pmCircularRegion.center, pmCircularRegion.radius, pmCircularRegion.radius)
            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(MKPlacemark(placemark: placemark))
            mediaURL.becomeFirstResponder()
        } else {
            let alert = AlertController.Alert(msg: "placemark not set", title: "Internal Error")
            alert.showAlert(self)
        }
    }
    
    // MARK: UITextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doSubmitAction()
        return true
    }
    
    
    // MARK: Action buttons
    
    @IBAction func cancelButtonTouchUp(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitButtonTouchUp(sender: UIButton) {
        doSubmitAction()
    }
    
    func doSubmitAction() {
        if mediaURL.text == "" {
            let alert = AlertController.Alert(msg: "please enter URL", title: "Empty URL string")
            alert.showAlert(self)
        } else {
            let latitude = placemark.location.coordinate.latitude
            let longitude = placemark.location.coordinate.longitude
            UdacityCLient.shared_instance().getUserInfo() {
                success, errorMsg in
            }
            let studentLocation = StudentLocation(uniqueKey: "", firstName: "", lastName: "", mapString: mapString, mediaURL: mediaURL.text, latitude: latitude, longitude: longitude)
            
            let alert = AlertController.Alert(msg: "please come back later", title: "Success")
            alert.showAlert(self)
        }
    }
    
    
    
}
