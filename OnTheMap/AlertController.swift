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
                valid_title = AlertTitle.Generic
            }
            let alertController = UIAlertController(title: valid_title, message: msg, preferredStyle: .Alert)
            var cancelAction: UIAlertAction
            if handler == nil {
                cancelAction = UIAlertAction(title: AlertActionTitle.Dismiss, style: UIAlertActionStyle.Cancel, handler: nil)
            } else {
                cancelAction = UIAlertAction(title: AlertActionTitle.Dismiss, style: UIAlertActionStyle.Cancel) { action in
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
    
    struct AlertTitle {
        
        static let Generic = "Alert"
        static let InternalError = "Internal error"
        
        static let FBLoginFailed = "Facebook login failed"
        static let FBLogoutFailed = "Facebook logout failed"
        static let FBLogoutCompleted = "Facebook logout completed"
        
        static let LoginError = "login error"
        static let LogoutError = "logout error"
        static let LoggedOut = "logged out"
        
        static let RefreshError = "Refresh error"
        static let ReadStudentLocatinsError = "Error reading student locations"
        
        static let OpenURLError = "Failed to open URL"
        static let MissingURLError = "Empty URL string"
        
        static let MissingLocationError = "Empty location"
        
        static let PostingUserInfoError = "Error, cannot post user info"
        static let GettingUserInfoError = "Error, cannot get user info"
        
        static let Details = "Details"
        static let Success = "Success"
        
        static let LocalizationError = "Cannot localize address"
        static let LocalizationAmbiguityWarning = "Ambiguous address"
    }
    
    struct AlertActionTitle {
        
        static let Dismiss = "Dismiss"
    }
}