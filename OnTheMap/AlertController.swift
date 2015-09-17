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
        let msg: String?
        let title: String?
        let handler: ((UIAlertAction) -> Void)?
        
        init(msg: String?, title: String?, handler: ((UIAlertAction) -> Void)? = nil) {
            self.msg = msg
            self.title = title
            self.handler = handler
        }
        
        func showAlert(vc: UIViewController) -> Void {
            
            var valid_title = title
            if valid_title == nil {
                valid_title = "Alert"
            }
            let alertController = UIAlertController(title: valid_title, message: msg, preferredStyle: .Alert)
            var cancelAction: UIAlertAction
            if handler == nil {
                cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
            } else {
                cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel) { action in
                    self.handler!(action)
                }
            }
            alertController.addAction(cancelAction)
            vc.presentViewController(alertController, animated: true, completion: nil)
        }
        
        func dispatchAlert(vc: UIViewController) -> Void {
            
            dispatch_async(dispatch_get_main_queue()) {
            self.showAlert(vc)
            }
        }
    }
}