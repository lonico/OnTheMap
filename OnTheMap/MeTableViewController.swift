//
//  MeTableViewController.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 9/12/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

class MeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var myLocations = [StudentLocation]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        
        myLocations = getMyLocations()
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data sources
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return myLocations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("meViewCell", forIndexPath: indexPath) as! UITableViewCell
        // Configure the cell...
        let student = myLocations[indexPath.row]
        cell.textLabel?.text = student.getFullNameFromStudent() + " - " + student.mapString
        cell.detailTextLabel?.text = "\(student.getCoordinateFromStudent())"
        return cell
    }
    
    
    // MARK: Table view delegates
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        
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
    
    // Support functions
    
    func getMyLocations() -> [StudentLocation] {
        
        var myLocations = [StudentLocation]()
        let uniqueKey = UdacityCLient.shared_instance().udacity_user_id
        println(uniqueKey)
        for studentLocation in ParseClient.shared_instance().studentLocations {
            if studentLocation.uniqueKey == uniqueKey {
                myLocations.append(studentLocation)
            }
        }
        return myLocations
    }

    // Mark: refresh method
    func refreshTable() -> Void {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.myLocations = self.getMyLocations()
            self.tableView?.reloadData()
        }
    }
}
