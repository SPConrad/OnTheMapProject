//
//  ListMapViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 12/16/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit
import MapKit

class ListMapViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var students: [Student]?
    var selectedStudent: Student?
    var defaultRegion: MKCoordinateRegion?
    
    private let groupRegionRadius: CLLocationDistance = 1000000
    private let smallRegionRadius: CLLocationDistance = 50000
    var mapPoint: MKMapPoint?
    
    enum viewControllers {
        case listView
        case mapView
    }
    
    private var activeViewController = viewControllers.listView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        students = [Student]()
        layoutMainView()
        createListView()
        makeCallForStudents()
    }
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isUserInteractionEnabled = true
        defaultRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(0.0, 0.0), 1000, 1000)
        return mapView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Shared View
    
    private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton()
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.isUserInteractionEnabled = true
        logoutButton.setTitle("LOGOUT", for: .normal)
        logoutButton.setTitleColor(UIColor.blue, for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutSession), for: UIControlEvents.touchUpInside)

        return logoutButton
    }()
    
    private lazy var refreshButton: UIButton = {
        let refreshButton = UIButton()
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.isUserInteractionEnabled = true
        refreshButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        refreshButton.setImage(UIImage(named: "icon_refresh"), for: .normal)
        refreshButton.addTarget(self, action: #selector(makeCallForStudents), for: UIControlEvents.touchUpInside)

        return refreshButton
    }()
    
    private lazy var addLocationButton: UIButton = {
        let addLocationButton = UIButton()
        addLocationButton.translatesAutoresizingMaskIntoConstraints = false
        addLocationButton.isUserInteractionEnabled = true
        addLocationButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        addLocationButton.setImage(UIImage(named: "icon_addpin"), for: .normal)
        addLocationButton.addTarget(self, action: #selector(submitNewLocation), for: UIControlEvents.touchUpInside)
        
        return addLocationButton
    }()
    private lazy var listViewTabButton: UIButton = {
        let listViewTabButton = UIButton()
        listViewTabButton.translatesAutoresizingMaskIntoConstraints = false
        listViewTabButton.setImage(UIImage(named: "icon_listview-deselected"), for: .normal)
        listViewTabButton.addTarget(self, action: #selector(displayListView), for: UIControlEvents.touchUpInside)
        return listViewTabButton
    }()
    
    private lazy var mapViewTabButton: UIButton = {
        let mapViewTabButton = UIButton()
        mapViewTabButton.translatesAutoresizingMaskIntoConstraints = false
        mapViewTabButton.setImage(UIImage(named: "icon_mapview-deselected"), for: .normal)
        mapViewTabButton.addTarget(self, action: #selector(displayMapView), for: UIControlEvents.touchUpInside)
        return mapViewTabButton
    }()
    
    private lazy var topBar: UIToolbar = {
        let topBar = UIToolbar()
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.backgroundColor = UIColor.white
        topBar.barTintColor = UIColor.white
        topBar.tintColor = UIColor.white
        topBar.barStyle = .default
        return topBar
    }()
    
    private lazy var bottomBar: UITabBar = {
        let bottomBar = UITabBar()
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        return bottomBar
    }()
    
    func layoutTopBar() {
        self.topBar.addSubview(logoutButton)
        self.topBar.addSubview(refreshButton)
        self.topBar.addSubview(addLocationButton)
        
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: topBar.topAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: topBar.bottomAnchor),
            logoutButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 100)
            ])
        
        NSLayoutConstraint.activate([
            addLocationButton.topAnchor.constraint(equalTo: topBar.topAnchor),
            addLocationButton.bottomAnchor.constraint(equalTo: topBar.bottomAnchor),
            addLocationButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor)
            ])
        
        NSLayoutConstraint.activate([
            refreshButton.topAnchor.constraint(equalTo: topBar.topAnchor),
            refreshButton.bottomAnchor.constraint(equalTo: topBar.bottomAnchor),
            refreshButton.trailingAnchor.constraint(equalTo: addLocationButton.leadingAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 50)
            ])
    }
    
    func layoutBottomBar() {
        bottomBar.addSubview(listViewTabButton)
        bottomBar.addSubview(mapViewTabButton)
        
        NSLayoutConstraint.activate([
            listViewTabButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 50),
            listViewTabButton.topAnchor.constraint(equalTo: bottomBar.topAnchor),
            listViewTabButton.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor),
            listViewTabButton.widthAnchor.constraint(equalToConstant: 75)
            ])
        
        NSLayoutConstraint.activate([
            mapViewTabButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -50),
            mapViewTabButton.topAnchor.constraint(equalTo: listViewTabButton.topAnchor),
            mapViewTabButton.bottomAnchor.constraint(equalTo: listViewTabButton.bottomAnchor),
            mapViewTabButton.widthAnchor.constraint(equalToConstant: 75)
            ])
    }
    
    func createListView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StudentListCell.self, forCellReuseIdentifier: "StudentListCell")
        layoutListView()

        print("list view created")
    }
    
    func layoutMainView() {
        view.addSubview(topBar)
        view.addSubview(bottomBar)
        layoutBottomBar()
        layoutTopBar()
        
        self.navigationItem.title = "On the Map"
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 44)
            ])
        
        NSLayoutConstraint.activate([
            bottomBar.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 50),
            bottomBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    func disableListView() {
        view.willRemoveSubview(tableView)
    }
    
    func layoutListView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
            ])
        
    }
    
    func disableMapView() {
        view.willRemoveSubview(mapView)
    }
    
    func layoutMapView() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
            ])
    }
    
    func logout() {
        print("logout")
    }
    
    func refreshStudentList() {
        print("refresh student list")
    }
    
    @objc
    func logoutSession() {
        logout()
    }
    
    @objc
    func makeCallForStudents()  {
        print("get students")
        ParseClient.sharedInstance().getStudentLocations(onSuccess: { (students) in
            self.students = students
        }, onFailure: { (error) in
            print("error")
        }, onComplete: {
            print("on complete")
            DispatchQueue.main.async {
                print("reload data")
                self.tableView.reloadData()
                print("data reloaded")
            }
        })
    }
    
    @objc
    func submitNewLocation() {
        if let addLocVc = UIStoryboard(name: "AddLocation", bundle: nil).instantiateViewController(withIdentifier: "AddLocation") as? AddLocationViewController {
            self.present(addLocVc, animated: true, completion: nil)
        } else {
            print("Whoops")
        }
    }
    
    @objc
    func displayListView() {
        if activeViewController == .mapView {
            disableMapView()
            layoutListView()
        }
        activeViewController = .listView
    }
    
    @objc
    func displayMapView() {
        if activeViewController == .listView {
            disableListView()
            layoutMapView()
        }
        activeViewController = .mapView
        
        if selectedStudent == nil {
            makePinsForStudents()
            if let student = students?[5] {
                if let lat = student.latitude, let lon = student.longitude {
                    let location = CLLocation(latitude: lat, longitude: lon)
                    centerMapOnLocation(location)
                }
            }
        }
    }
    
    // MARK: - TableView Controller
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStudent = students?[(indexPath as NSIndexPath).row]
        displayMapView()
        if let lat = selectedStudent?.latitude, let lon = selectedStudent?.longitude {
            let location = CLLocation(latitude: lat, longitude: lon)
            if let name = selectedStudent?.fullName() {
                addPin(location: location, title: name)
            }
            centerMapOnLocation(location)
        }
        
    }
    
    func makePinsForStudents(_ numberOfStudents: Int? = 15) {
        for n in 1...15 {
            if let student = students?[n] {
                if let location = createStudentLocation(student) {
                    addPin(location: location, title: student.firstName ?? "Student")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let students = students {
            return students.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentListCell", for: indexPath) as! StudentListCell
        cell.configure()
        let student = students?[(indexPath as NSIndexPath).row]
        cell.urlLabel.text = student?.mediaURL
        cell.nameLabel.text = student?.firstName
        
        return cell
    }
    
    // MARK: - Map Controller
    
    func createStudentLocation(_ student: Student) -> CLLocation? {
        guard let lat = student.latitude, let lng = student.longitude else {
            print("error!")
            return nil
        }
        return CLLocation(latitude: lat, longitude: lng)
    }
    
    func addPin(location: CLLocation, title: String) {
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location.coordinate
        dropPin.title = title
        mapView.addAnnotation(dropPin)
    }
    
    func getStudentsForMapView() {
        if let students = students {
            for (_, student) in students.enumerated() {
                if let newLocation = createStudentLocation(student) {
                    addPin(location: newLocation, title: student.fullName())
                }
            }
        }
    }
    
    func centerMapOnLocation(_ location: CLLocation?) {
        var coordinateRegion: MKCoordinateRegion?
        var radius: CLLocationDistance = 100000
        if let location = location {
            if selectedStudent == nil {
                radius = groupRegionRadius
            } else {
                radius = smallRegionRadius
            }
            coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius)
        }
        mapView.setRegion(coordinateRegion ?? MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(0.0, 0.0), 1000, 1000), animated: true)
    }
}
