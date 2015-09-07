//
//  AlertController.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 9/7/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

struct AlertController {
    
    static func showAlert(vc: UIViewController, msg: String?, var title: String?) {
        
        if title == nil {
            title = "Alert"
        }
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Dismiss", style: .Cancel) { action -> Void in
            //Just dismiss the alert
        }
        alertController.addAction(cancelAction)
        vc.presentViewController(alertController, animated: true, completion: nil)
    }
    
    static func dispatchAlert(vc: UIViewController, msg: String?, title: String?) {
        if let msg = msg {
            dispatch_async(dispatch_get_main_queue()) {
                self.showAlert(vc, msg: msg, title: title)
            }
            
        }
    }


}