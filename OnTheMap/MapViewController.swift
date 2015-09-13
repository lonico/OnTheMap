//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Laurent Nicolas on 8/31/15.
//  Copyright (c) 2015 Laurent Nicolas. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ParseClient.shared_instance().getStudentLocations() { success, errorMsg in
            if success {
                self.setAnnotationsForStudentLocations()
            } else {
                AlertController.Alert(msg: errorMsg, title: "Error reaading student locations").dispatchAlert(self)
            }
        }
    }
    
    // This is called at init, but also on a refresh, hence removeAnnotations
    
    func setAnnotationsForStudentLocations() -> Void {
        // get student information, including their location
        let studentLocations = ParseClient.shared_instance().studentLocations
        
        // We will create an MKPointAnnotation for each entry in studentLocations. The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        for studentLocation in studentLocations {
            // Here we create the annotation and set its coordinate, title, and subtitle properties
            var annotation = MKPointAnnotation()
            annotation.coordinate = studentLocation.getCoordinateFromStudent()
            annotation.title = studentLocation.getFullNameFromStudent()
            annotation.subtitle = studentLocation.getURLFromStudent()
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
            println(">>> Annotations: \(self.mapView.annotations.count)")
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) -> Void {
        
        if control == annotationView.rightCalloutAccessoryView {
            var alert: AlertController.Alert? = nil
            let app = UIApplication.sharedApplication()
            let urlString = annotationView.annotation.subtitle!
            if let url = NSURL(string: urlString) {
                let result = app.openURL(url)
                if !result {
                    AlertController.Alert(msg: urlString, title: "Failed to open URL").showAlert(self)
                }
            } else {
                AlertController.Alert(msg: urlString, title: "Failed to open URL").showAlert(self)
            }
        }
    }
    
}
