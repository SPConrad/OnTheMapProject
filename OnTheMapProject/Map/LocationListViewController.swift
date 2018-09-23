//
//  LocationListViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 9/10/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit

class LocationListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var students: [ParseLocation]!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var list: UIBarButtonItem!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ParseClient.sharedInstance().getAllLocations(onSuccess: { (studentsLocation) in
            self.students = studentsLocation
        }, onFailure: { (error) in
            
        }, onComplete: {
            self.tableView.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    
    @IBAction func logout(_ sender: Any) {
    }
    
    
    @IBAction func add(_ sender: Any) {
    }
    
    @IBAction func refresh(_ sender: Any) {
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentLocationCell", for: indexPath) as! StudentLocationCell
        cell.urlLabel.text = "Hello URL"
        cell.nameLabel.text = "Sean Conrad"
        // Configure the cell...
        
        return cell
    }

}
