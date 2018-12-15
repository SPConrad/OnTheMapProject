//
//  MapViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/19/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    var students: [Student]!
    var selectedStudent: Student?
    let regionRadius: CLLocationDistance = 10000000
    var mapPoint: MKMapPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        students = [Student]()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.delegate = self
        if (selectedStudent != nil) {
            
        }
        else {
            getStudents()
        }
    }
    
    public func getStudents()  {
        print("get students")
        ParseClient.sharedInstance().getStudentLocations(onSuccess: { (students) in
            self.students = students
        }, onFailure: { (error) in
            print("error")
        }, onComplete: {
            print("on complete")
            DispatchQueue.main.async {
                self.layoutMapView()
            }
        })
    }
    
    func layoutMapView() {
        if students != nil {
            for (_, student) in students.enumerated() {
                guard let lat = student.latitude, let lng = student.longitude else {
                   return
                }
                let newLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                addPin(location: newLocation, title: student.fullName())
            }
        }
    }
    
    func displaySingleStudent(_ student: Student) {
        print("display selected student")
    }
    
    func addPin(location: CLLocationCoordinate2D, title: String) {
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location
        dropPin.title = title
        mapView.addAnnotation(dropPin)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func addLocation(_ sender: Any) {
        if let addLocVc = UIStoryboard(name: "AddLocation", bundle: nil).instantiateViewController(withIdentifier: "AddLocation") as? AddLocationViewController {
            self.present(addLocVc, animated: true, completion: nil)
        } else {
            print("Whoops")
        }
        
    }
    
    @IBAction func refresh(_ sender: Any) {
        getStudents()
    }
    
    @IBAction func logout(_ sender: Any) {
        
    }
    
}
