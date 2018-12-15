//
//  LocationListViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 9/10/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit

class StudentListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public var students: [Student]!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var list: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getStudents()
    }
    
    func getStudents()  {
        print("get students")
        ParseClient.sharedInstance().getStudentLocations(onSuccess: { (students) in
            self.students = students
        }, onFailure: { (error) in
            print("error")
        }, onComplete: {
            print("on complete")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func logout(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func add(_ sender: Any) {
        
    }
    
    @IBAction func refresh(_ sender: Any) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStudent = students?[(indexPath as NSIndexPath).row]
        self.tabBarController?.selectedIndex = 1
        guard let map = self.tabBarController?.childViewControllers[1] as? MapViewController else {
            print("that didn't work")
            return
        }
        map.displaySingleStudent(selectedStudent!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students != nil ? students.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentLocationCell", for: indexPath) as! StudentLocationCell
        let student = students?[(indexPath as NSIndexPath).row]
        cell.urlLabel.text = student?.mediaURL
        cell.nameLabel.text = student?.firstName
        
        return cell
    }
    
    

}
