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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        locationInputTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Action buttons
    
    
    @IBAction func CancelButtonTouchUp(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func FindButtonTouchUp(sender: UIButton) {
        findAction()
    }
    
    func findAction() {
        let location = locationInputTextField.text
        if location == "" {
            let alert = AlertController.Alert(msg: "please enter an address", title: "Empty location")
            alert.showAlert(self)
        } else {
            getPlaceMarksAndSegue(location)
        }
    }
    
    // MARK: UITextField delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        findAction()
        return true
    }
    
    
    func getPlaceMark(address: String, completion_handler: (placemark: CLPlacemark!, alert: AlertController.Alert!) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemark, error in
            var studentPlacemark: CLPlacemark! = nil
            var alert: AlertController.Alert! = nil
            if let error = error {
                alert = AlertController.Alert(msg: error.localizedDescription, title: "Cannot localize address")
            } else if let placemark = placemark {
                println(placemark)
                println(placemark.count)
                if placemark.count == 0 {
                    alert = AlertController.Alert(msg: "Unexpected error (empty array)", title: "Cannot localize address")
                } else {
                    if placemark.count > 1 {
                        alert = AlertController.Alert(msg: "Got \(placemark.count) results, using the first one", title: "Ambiguous address")
                    }
                    studentPlacemark = placemark[0] as! CLPlacemark
                }
            } else {
                alert = AlertController.Alert(msg: "Unexpected error (nil)", title: "Cannot localize address")
            }
            completion_handler(placemark: studentPlacemark, alert: alert)
        }

    }
    
    func getPlaceMarksAndSegue(address: String) -> Void {
        getPlaceMark(address) { placemark, alert in
            if let alert = alert {
                alert.dispatchAlert(self)
            }
            if let placemark = placemark {
                let addSMController = self.storyboard!.instantiateViewControllerWithIdentifier("addStudentMediaURL") as! AddStudentMediaURLViewController
                addSMController.placemark = placemark
                addSMController.mapString = address
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(addSMController, animated: true, completion: nil)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    
}
