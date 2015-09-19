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

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationInputTextField: UITextField!
    @IBOutlet weak var viewForTextField: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(animated: Bool) {
        locationInputTextField.becomeFirstResponder()
        activityIndicator.hidesWhenStopped = true
        self.setAlpha(1)
        super.viewWillAppear(animated)
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
    
    func taskForFindButtonTouchUp() -> Void {
        let location = locationInputTextField.text
        if location == "" {
            AlertController.Alert(msg: "please enter an address", title: AlertController.AlertTitle.MissingLocationError).showAlert(self)
        } else {
            getPlacemarkAndSegue(location)
        }
    }
    
    func getPlacemarkAndSegue(address: String) -> Void {
        activityIndicator.startAnimating()
        self.setAlpha(0.5)
        GeoLocationClient.getPlacemark(address) { placemark, alert in
            if let placemark = placemark {
                let addSMController = self.storyboard!.instantiateViewControllerWithIdentifier("addStudentMediaURL") as! AddStudentMediaURLViewController
                addSMController.placemark = placemark
                addSMController.mapString = address
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    self.presentViewController(addSMController, animated: true, completion: nil)
                }
            } else {
                self.activityIndicator.stopAnimating()
                self.setAlpha(1)
                if let alert = alert {
                    alert.dispatchAlert(self)
                } else {
                    AlertController.Alert(
                        msg: "alert and placemark can't be both nil",
                        title: AlertController.AlertTitle.InternalError).dispatchAlert(self)
                }
            }
        }
    }
    
    func setAlpha(alpha: CGFloat) -> Void {
        titleLabel.alpha = alpha
        viewForTextField.alpha = alpha
        locationInputTextField.alpha = alpha
    }
}
