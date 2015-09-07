//
//  AddStudentLocationViewController.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 9/7/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import UIKit
import MapKit

class AddStudentLocationViewController: UIViewController {

    @IBOutlet weak var locationInputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK - Action buttons
    
    
    @IBAction func CancelButtonTouchUp(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func FindButtonTouchUp(sender: UIButton) {
        let location = locationInputTextField.text
        if location == "" {
            AlertController.showAlert(self, msg: "please enter an address", title: "Empty location")
        } else {
            getPlaceMarksAndSegue(location)
        }
    }
    
    struct Alert {
        let msg: String!
        let title: String!
    }
    
    func getPlaceMark(address: String, completion_handler: (placemark: CLPlacemark!, alert: Alert!) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemark, error in
            var studentPlacemark: CLPlacemark! = nil
            var alert: Alert! = nil
            if let error = error {
                alert = Alert(msg: error.localizedDescription, title: "Cannot localize address")
            } else if let placemark = placemark {
                println(placemark)
                println(placemark.count)
                if placemark.count == 0 {
                    alert = Alert(msg: "Unexpected error (empty array)", title: "Cannot localize address")
                } else {
                    if placemark.count > 1 {
                        alert = Alert(msg: "Got \(placemark.count) results, using the first one", title: "Ambiguous address")
                    }
                    studentPlacemark = placemark[0] as! CLPlacemark
                }
            } else {
                alert = Alert(msg: "Unexpected error (nil)", title: "Cannot localize address")
            }
            completion_handler(placemark: studentPlacemark, alert: alert)
        }

    }
    
    func getPlaceMarksAndSegue(address: String) -> Void {
        getPlaceMark(address) { placemark, alert in
            if let alert = alert {
                AlertController.dispatchAlert(self, msg: alert.msg, title: alert.title)
            }
            if let placemark = placemark {
                //prepareForSegue(<#segue: UIStoryboardSegue#>, sender: <#AnyObject?#>)
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
