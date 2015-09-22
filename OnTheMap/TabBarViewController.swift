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

        refreshButton.enabled = false
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
                AlertController.Alert(msg: errorMsg, title: AlertController.AlertTitle.RefreshError).dispatchAlert(self)
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshButton.enabled = true
            }
        }
    }
    
    @IBAction func logoutButtonTouch(sender: UIBarButtonItem) {
        
        UdacityCLient.shared_instance().logout() { success, errorMsg in
            if success {
                let alert = AlertController.Alert(msg: "", title: AlertController.AlertTitle.LoggedOut) { action in
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginViewController") as! UIViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
                alert.dispatchAlert(self)
            } else {
                AlertController.Alert(msg: errorMsg, title: AlertController.AlertTitle.LogoutError).dispatchAlert(self)
            }
        }
    }
 }

