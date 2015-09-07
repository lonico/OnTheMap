//
//  AlertController.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 9/7/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

struct AlertController {
    
    struct Alert {
        let msg: String!
        let title: String!
    
        func showAlert(vc: UIViewController) {
            
            var valid_title = title
            if valid_title == nil {
                valid_title = "Alert"
            }
            
            let alertController = UIAlertController(title: valid_title, message: msg, preferredStyle: .Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Dismiss", style: .Cancel) { action -> Void in
                //Just dismiss the alert
            }
            alertController.addAction(cancelAction)
            vc.presentViewController(alertController, animated: true, completion: nil)
        }
        
        
        func dispatchAlert(vc: UIViewController) {
            if let msg = msg {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showAlert(vc)
                }
            }
        }
    }
}