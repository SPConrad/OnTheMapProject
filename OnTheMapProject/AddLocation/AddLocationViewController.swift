//
//  AddLocationViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/19/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit

let sample: [String:AnyObject] =
    [
        "objectId": "abc123" as AnyObject,
        "uniqueKey": "11iudda03" as AnyObject,
        "firstName": "Sean" as AnyObject,
        "lastName": "Conrad" as AnyObject,
        "mapString": "http://www.google.com" as AnyObject,
        "mediaUrl": "http://www.google.com" as AnyObject,
        "latitude": 35.995649 as AnyObject,
        "longitude": -78.901753 as AnyObject,
        "createdAt": "" as AnyObject,
        "updatedAt": "" as AnyObject
    ]


class AddLocationViewController: ViewController {
    
    var locationController: LocationController!
    var locations: [Location]!
    
    @IBOutlet weak var namedLocationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var findLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationController = LocationController()
        locations = [Location]()
        locations.append(Location(location: sample))
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAllLocations() {
        locationController.getLocations(completion: { responseData in
            let parsedData = JSON.deserialize(data: responseData)
            //print(parsedResult["results"])
            if let results = try? parsedData["results"] as? [[String:AnyObject]] {
                for result in results! {
                    self.locations.append(Location(location: result))
                }
            }
            print("hello world")
        })
    }
    private func dismissKeyboard() {
        namedLocationTextField.resignFirstResponder()
        urlTextField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _ = namedLocationTextField.resignFirstResponder()
        _ = urlTextField.resignFirstResponder()
    }
    
    @IBAction func findLocation(_ sender: Any) {
        if let mapVc = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
            mapVc.studentLocation = locations[0]
            self.present(mapVc, animated: true, completion: nil)
        } else {
            print("whoops")
        }
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
