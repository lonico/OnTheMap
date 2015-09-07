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
    
    override func viewDidAppear(animated: Bool) {
        let rightButtons = [refreshButton, pinButton]
        self.navigationItem.setRightBarButtonItems(rightButtons, animated: true)
        parseGetStudentLocations() { success, errorMsg in
//            if success {
//                let mapViewController = self.childViewControllers[0] as! UIViewController
//                self.presentViewController(mapViewController, animated: true, completion: nil)
//            }
        }
        super.viewDidAppear(animated)
    }
    
    
    @IBAction func pinButtonTouched(sender: UIBarButtonItem) {
        println("pinned!")      // TODO
        let addSLController = self.storyboard!.instantiateViewControllerWithIdentifier("addStudentLocation") as! UIViewController
        self.presentViewController(addSLController, animated: true, completion: nil)
        
    }
    
    @IBAction func refreshButtonTouch(sender: UIBarButtonItem) {
        println("refreshed")    // TODO
        parseGetStudentLocations() { success, errorMsg in
//            if success {
//                let mapViewController = self.childViewControllers[0] as! UIViewController
//                self.presentViewController(mapViewController, animated: true, completion: nil)
//            }
        }
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
    
    // MARK - support functions
    
    func parseGetStudentLocations(completion_handler: (success: Bool, errorMsg: String?) -> Void) {
        ParseClient.shared_instance().parseGetStudentLocations { success, errorMsg in
            completion_handler(success: success, errorMsg: errorMsg)
        }
    }
}

