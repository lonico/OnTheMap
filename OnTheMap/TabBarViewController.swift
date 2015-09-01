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
        println("I was here")
        super.viewWillAppear(animated)
    }
    
    
    @IBAction func pinButtonTouched(sender: UIBarButtonItem) {
        println("pinned!")
    }
    
    @IBAction func refreshButtonTouch(sender: UIBarButtonItem) {
        println("refreshed")
    }
    
    @IBAction func logoutButtonTouch(sender: UIBarButtonItem) {
        println("logging out")
        UdacityCLient.shared_instance().logout() { success, errorMsg in
            var msg: String? = ""
            if success {
                println("Logged out")
            } else {
                msg = errorMsg
                println("msg")
            }
            dispatch_async(dispatch_get_main_queue()) {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginViewController") as! UIViewController
                self.presentViewController(controller, animated: true, completion: nil)            }

        }

        
    }
}

