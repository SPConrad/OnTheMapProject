//
//  AddLocationViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/19/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit

struct StudentLocation: Codable {
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: String
    let longitude: String
    let createdAt: String
    let updatedAt: String
}

class AddLocationViewController: ViewController {
    
    var locationController: LocationController!
    
    @IBOutlet weak var namedLocationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var findLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationController = LocationController()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func findLocation(_ sender: Any) {
        locationController.getLocations(completion: { responseData in
            let parsedData = JSON.deserialize(data: responseData)
            //print(parsedResult["results"])
            if let results = try? parsedData["results"] as? [[String:AnyObject]] {
                var locations: [Location] = [Location]()
                
                for result in results! {
                    print(result)
                    let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    
                    
                }
                
//                for result in results! {
//                    try locations.append(Location(from: result as! Decoder))
//                }
            }
            
            
            
            print("hello world")
            
        })

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
