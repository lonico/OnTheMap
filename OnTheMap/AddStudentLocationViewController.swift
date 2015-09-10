//
//  AddStudentLocationViewController.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 9/7/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import UIKit
import MapKit

class AddStudentLocationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var locationInputTextField: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        locationInputTextField.becomeFirstResponder()
    }
    
    // MARK: Action buttons
    
    @IBAction func CancelButtonTouchUp(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func FindButtonTouchUp(sender: UIButton) {
        taskForFindButtonTouchUp()
    }
    
    // MARK: UITextField delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        taskForFindButtonTouchUp()
        return true
    }
    
    // MARK: Support functions
    
    func taskForFindButtonTouchUp() {
        let location = locationInputTextField.text
        if location == "" {
            let alert = AlertController.Alert(msg: "please enter an address", title: "Empty location")
            alert.showAlert(self)
        } else {
            getPlacemarkAndSegue(location)
        }
    }
    
    func getPlacemarkAndSegue(address: String) -> Void {
        GeoLocationClient.getPlacemark(address) { placemark, alert in
            if let placemark = placemark {
                let addSMController = self.storyboard!.instantiateViewControllerWithIdentifier("addStudentMediaURL") as! AddStudentMediaURLViewController
                addSMController.placemark = placemark
                addSMController.mapString = address
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(addSMController, animated: true, completion: nil)
                }
            } else if let alert = alert {
                alert.dispatchAlert(self)
            } else {
                AlertController.Alert(msg: "alert and placemark can't be both nil", title: "Internal error").dispatchAlert(self)
            }
        }
    }
}
