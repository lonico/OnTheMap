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
    @IBOutlet weak var activiyIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewForInputTestField: UIView!
    
    override func viewWillAppear(animated: Bool) {
        activiyIndicator.hidesWhenStopped = true
        setAlpha(1)
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
        taskForSubmitAction()
        return true
    }
    
    // MARK: Action buttons
    
    @IBAction func cancelButtonTouchUp(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func checkLinkInSafariButtonTouchUp(sender: UIButton) {
        if mediaURL.text == "" {
            let alert = AlertController.Alert(msg: "please enter URL", title: "Empty URL string")
            alert.showAlert(self)
        } else {
            let app = UIApplication.sharedApplication()
            let urlString = mediaURL.text
            if let url = NSURL(string: urlString) {
                let result = app.openURL(url)
                if !result {
                    AlertController.Alert(msg: urlString, title: "Failed to open URL").showAlert(self)
                }
            } else {
                AlertController.Alert(msg: urlString, title: "Failed to open URL").showAlert(self)
            }
        }
    }
    
    @IBAction func submitButtonTouchUp(sender: UIButton) {
        taskForSubmitAction()
    }
    
    func taskForSubmitAction() -> Void {
        if mediaURL.text == "" {
            let alert = AlertController.Alert(msg: "please enter URL", title: "Empty URL string")
            alert.showAlert(self)
        } else {
            let latitude = placemark.location.coordinate.latitude
            let longitude = placemark.location.coordinate.longitude
            activiyIndicator.startAnimating()
            setAlpha(0.5)
            UdacityCLient.shared_instance().getUserInfo() { userInfo, errorMsg in
                var alert: AlertController.Alert! = nil
                if userInfo != nil {
                    let studentLocation = StudentLocation(uniqueKey: userInfo.uniqueKey, firstName: userInfo.firstName, lastName: userInfo.lastName, mapString: self.mapString, mediaURL: self.mediaURL.text, latitude: latitude, longitude: longitude)
                    
                    println(">>> key \(userInfo.uniqueKey)")
                    ParseClient.postStudentLocation(studentLocation) { createdAt, updatedAt, errorMsg in
                        if createdAt != nil || updatedAt != nil {
                            alert = AlertController.Alert(msg: "posted info for \(userInfo.firstName) \(userInfo.lastName)", title: "Success") { action in
                                    self.popOut()
                            }
                        } else {
                            alert = AlertController.Alert(msg: errorMsg, title: "Error, cannot post user info")
                        }
                        self.dismissProgressIndicators()
                        alert.dispatchAlert(self)
                    }
                } else if errorMsg != nil {
                    alert = AlertController.Alert(msg: errorMsg, title: "Error, cannot get user info")
                } else {
                    alert = AlertController.Alert(msg: "Internal error: userInfo and errorMsg are both nil", title: "Error, cannot get user info")
                }

                if alert != nil {
                    self.dismissProgressIndicators()
                    alert.dispatchAlert(self)
                }
            }
        }
    }
    
    func dismissProgressIndicators() {
        dispatch_async(dispatch_get_main_queue()) {
            self.activiyIndicator.stopAnimating()
            self.setAlpha(1)
        }
    }
    
    func setAlpha(alpha: CGFloat) -> Void {
        mediaURL.alpha = alpha
        viewForInputTestField.alpha = alpha
        mapView.alpha = alpha
    }
    
    func popOut() -> Void {
        dispatch_async(dispatch_get_main_queue()) {
            let presentingVC = self.presentingViewController
            self.dismissViewControllerAnimated(false, completion: nil)
            presentingVC?.dismissViewControllerAnimated(false, completion: nil)
        }
    }
}
