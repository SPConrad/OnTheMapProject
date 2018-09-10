//
//  LocationListViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 9/10/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit

class LocationListViewController: ViewController {
    var studentLocations: [Location]!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func logout(_ sender: Any) {
    }
    

    @IBAction func add(_ sender: Any) {
    }
    
    @IBAction func refresh(_ sender: Any) {
    }
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var list: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentLocations = [Location]()
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 80
        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
//            tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
            ])
        
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

extension LocationListViewController: UITableViewDataSource {
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
