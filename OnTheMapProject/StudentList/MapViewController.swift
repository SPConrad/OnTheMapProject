//
//  MapViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/19/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//
//
//import UIKit
//import MapKit
//
//class MapDelegate: UIViewController, MKMapViewDelegate {
//
//
//
//    var students: [Student]?
//    var selectedStudent: Student?
//    let groupRegionRadius: CLLocationDistance = 10000000
//    let smallRegionRadius: CLLocationDistance = 10000
//    var mapPoint: MKMapPoint?
//
//    let defaultRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(0.0, 0.0), 1000, 1000)
//
//
//    func createStudentLocation(_ student: Student) -> CLLocationCoordinate2D {
//        guard let lat = student.latitude, let lng = student.longitude else {
//            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
//        }
//        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
//    }
//
//
//    func displaySingleStudent(_ student: Student) {
//        print("display selected student")
//    }
//
//    func addPin(location: CLLocationCoordinate2D, title: String) {
//        let dropPin = MKPointAnnotation()
//        dropPin.coordinate = location
//        dropPin.title = title
//        mapView.addAnnotation(dropPin)
//    }
//
//    func centerMapOnLocation(_ location: CLLocation?, _ selectedStudentLocation: CLLocationCoordinate2D?) {
//        var coordinateRegion: MKCoordinateRegion?
//        if let location = location {
//            coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, groupRegionRadius, groupRegionRadius)
//        } else if let selectedStudentLocation = selectedStudentLocation {
//            coordinateRegion = MKCoordinateRegionMakeWithDistance(selectedStudentLocation, smallRegionRadius, smallRegionRadius)
//        }
//        mapView.setRegion(coordinateRegion ?? defaultRegion, animated: true)
//    }
//
//    @IBAction func addLocation(_ sender: Any) {
//        if let addLocVc = UIStoryboard(name: "AddLocation", bundle: nil).instantiateViewController(withIdentifier: "AddLocation") as? AddLocationViewController {
//            self.present(addLocVc, animated: true, completion: nil)
//        } else {
//            print("Whoops")
//        }
//    }
//
//}
//
