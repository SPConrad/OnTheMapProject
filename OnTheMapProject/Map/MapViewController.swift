//
//  MapViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/19/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit
import MapKit
class MapViewController: ViewController {
    
    var mapView: MKMapView!
    var stackView: UIStackView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navbar: UINavigationBar!
    
    var studentLocation: Location?
    let regionRadius: CLLocationDistance = 1000
    var mapPoint: MKMapPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MKMapView()
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
