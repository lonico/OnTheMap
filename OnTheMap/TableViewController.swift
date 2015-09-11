//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 9/2/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Table view data sources

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return ParseClient.shared_instance().studentLocations.count
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("studentCell", forIndexPath: indexPath) as! UITableViewCell
        // Configure the cell...
        let student = ParseClient.shared_instance().studentLocations[indexPath.row]
        cell.textLabel?.text = student.getFullNameFromStudent()
        cell.detailTextLabel?.text = student.getURLFromStudent()
        return cell
    }
    
    
    // MARK: Table view delegates
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let app = UIApplication.sharedApplication()
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let url = cell?.detailTextLabel?.text {
            let result = app.openURL(NSURL(string: url)!)
            if !result {
                AlertController.Alert(msg: url, title: "Failed to open URL").dispatchAlert(self)
            }
        } else {
            AlertController.Alert(msg: "no URL was provided", title: "Empty URL").dispatchAlert(self)
        }
    }
    
    
    // Mark: refresh method
    func refreshTable() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView?.reloadData()
            self.tableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }
}
