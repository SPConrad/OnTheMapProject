//
//  MapViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/19/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navbar: UINavigationBar!
    
    var studentLocations: [Student]!
    var studentLocation: Student?
    let regionRadius: CLLocationDistance = 1000
    var mapPoint: MKMapPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentLocations = [Student]()
        layoutMapView()
    }
    
    func layoutMapView() {
        self.view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            mapView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
            ])
        
        if studentLocation != nil {
            let initialLocation = CLLocation(latitude: (studentLocation?.latitude)!, longitude: (studentLocation?.longitude)!)
            centerMapOnLocation(location: initialLocation)
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func locationList(_ sender: Any) {
        
    }
    
    @IBAction func addLocation(_ sender: Any) {
        
    }
    
    @IBAction func refresh(_ sender: Any) {
        
    }
    
    @IBAction func logout(_ sender: Any) {
        
    }
    
}
