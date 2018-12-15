//
//  AddLocationViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/19/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController, MKMapViewDelegate {
    
    var location: Student!
    var mapPoint: MKPointAnnotation!
    
    @IBOutlet weak var namedLocationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    
    let regionRadius: CLLocationDistance = 1000
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        return mapView
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white
        button.titleLabel?.textColor = UIColor.black
        button.titleLabel?.text = "Submit"
        button.addTarget(self, action: #selector(confirmAddLocationPressed), for: .touchUpInside)
        return button
    }()
    
    public func addSyncNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(confirmAddLocationPressed), name: NSNotification.Name(rawValue: "confirmAddLocationPressed"), object: nil)
    }
    
    public func removeSyncNotification() {
        NotificationCenter.default.removeObserver(self)
    }

    
    @objc func confirmAddLocationPressed() {
            let student = Student(student: [
                "firstName": "John" as AnyObject,
                "lastName": "Smith" as AnyObject,
                "mediaURL": mapPoint.title as AnyObject,
                "latitude": mapPoint.coordinate.latitude as AnyObject,
                "longitude": mapPoint.coordinate.longitude as AnyObject,
                "uniqueKey": "u10179641" as AnyObject
                ])
        
        
        ParseClient.sharedInstance().postStudentLocation(newStudent: student) { result in
            print("Complete")
            print(result)
        }
        self.view.willRemoveSubview(mapView)
        self.view.willRemoveSubview(confirmButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func dismissKeyboard() {
        namedLocationTextField.resignFirstResponder()
        urlTextField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _ = namedLocationTextField.resignFirstResponder()
        _ = urlTextField.resignFirstResponder()
    }
    
    func layoutMapView() {        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])
    }
    
    func layoutConfirmButton() {
        NSLayoutConstraint.activate([
            confirmButton.heightAnchor.constraint(equalToConstant: 42),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            confirmButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
            ])
    }
    
    func createRegion(_ location: CLLocationCoordinate2D) -> MKCoordinateRegion {
        return MKCoordinateRegionMakeWithDistance(location, regionRadius, regionRadius)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        if let location = namedLocationTextField.text, let url = urlTextField.text {
            view.addSubview(mapView)
            layoutMapView()
            let geocoder: CLGeocoder = CLGeocoder()
            geocoder.geocodeAddressString(location) { (placemarks, error) in
                print("In geocoder!")
                if error == nil {
                    if let placemark = placemarks?[0] {
                        guard let lat = placemark.location?.coordinate.latitude, let lng = placemark.location?.coordinate.longitude else {
                            return
                        }
                        self.mapPoint = MKPointAnnotation()
                        self.mapPoint.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        self.mapPoint.title = url
                        self.mapView.addAnnotation(self.mapPoint)
                        let coordinateRegion = self.createRegion(self.mapPoint.coordinate)
                        self.mapView.setRegion(coordinateRegion, animated: true)
                        self.view.addSubview(self.confirmButton)
                        self.layoutConfirmButton()
                    }
                    geocoder.cancelGeocode()
                }
            }
        }
    }
}



