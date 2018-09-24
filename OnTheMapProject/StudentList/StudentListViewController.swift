//
//  LocationListViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 9/10/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit

class StudentListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var students: [Student]!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var list: UIBarButtonItem!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        students = [Student]()
        getStudents()
        tableView.reloadData()
    }
    
    func getStudents() {
        ParseClient.sharedInstance().getStudentLocations(onSuccess: { (students) in
            self.students = students
        }, onFailure: { (error) in
            print("error")
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func add(_ sender: Any) {
        
    }
    
    @IBAction func refresh(_ sender: Any) {
        getStudents()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentLocationCell", for: indexPath) as! StudentLocationCell
        let student = students?[(indexPath as NSIndexPath).row]
        cell.urlLabel.text = student?.mediaURL
        cell.nameLabel.text = student?.firstName
        
        return cell
    }

}
