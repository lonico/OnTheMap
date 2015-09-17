//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 8/31/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import UIKit
import MapKit

class TabBarViewController: UITabBarController {
    
    @IBOutlet var pinButton: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    
    
    override func viewWillAppear(animated: Bool) {
        let rightButtons = [refreshButton, pinButton]
        self.navigationItem.setRightBarButtonItems(rightButtons, animated: true)
        super.viewWillAppear(animated)
    }
    
    // MARK: Button Actions
    
    @IBAction func pinButtonTouched(sender: UIBarButtonItem) {
        
        let addSLController = self.storyboard!.instantiateViewControllerWithIdentifier("addStudentLocation") as! UIViewController
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(addSLController, animated: true, completion: nil)
        }
    }
    
    @IBAction func refreshButtonTouch(sender: UIBarButtonItem) {

        ParseClient.shared_instance().getAllStudentLocations() { success, errorMsg in
            if success {
                for vc in self.viewControllers as! [UIViewController] {
                    if let tablevc = vc as? TableViewController {
                        tablevc.refreshTable()
                    }
                    if let tablevc = vc as? MeTableViewController {
                        tablevc.refreshTable()
                    }
                    if let mapvc = vc as?  MapViewController {
                        mapvc.setAnnotationsForStudentLocations()
                    }
                }
            } else {
                AlertController.Alert(msg: errorMsg, title: "Refresh error").dispatchAlert(self)
            }
        }
    }
    
    @IBAction func logoutButtonTouch(sender: UIBarButtonItem) {
        
        UdacityCLient.shared_instance().logout() { success, errorMsg in
            if success {
                AlertController.Alert(msg: "", title: "Logged out").dispatchAlert(self)
            } else {
                AlertController.Alert(msg: errorMsg, title: "Logout error").dispatchAlert(self)
            }
            dispatch_async(dispatch_get_main_queue()) {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginViewController") as! UIViewController
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
 }

