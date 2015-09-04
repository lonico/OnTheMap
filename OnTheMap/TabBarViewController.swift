//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 8/31/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    @IBOutlet var pinButton: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        let rightButtons = [refreshButton, pinButton]
        self.navigationItem.setRightBarButtonItems(rightButtons, animated: true)
        super.viewWillAppear(animated)
    }
    
    @IBAction func pinButtonTouched(sender: UIBarButtonItem) {
        println("pinned!")      // TODO
    }
    
    @IBAction func refreshButtonTouch(sender: UIBarButtonItem) {
        println("refreshed")    // TODO
    }
    
    @IBAction func logoutButtonTouch(sender: UIBarButtonItem) {
        println(">>> Logging out")
        UdacityCLient.shared_instance().logout() { success, errorMsg in
            var msg: String? = ""
            if success {
                println(">>> Logged out")
            } else {
                println(">>> \(errorMsg)")
            }
            dispatch_async(dispatch_get_main_queue()) {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginViewController") as! UIViewController
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
}

