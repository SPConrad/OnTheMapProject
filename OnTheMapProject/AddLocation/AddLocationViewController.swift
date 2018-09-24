//
//  AddLocationViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/19/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit

class AddLocationViewController: UIViewController {
    
    var locations: [Student]!
    
    @IBOutlet weak var namedLocationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var findLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locations = [Student]()
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
    
    @IBAction func findLocation(_ sender: Any) {
//        if let mapVc = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
//            mapVc.studentLocation = locations[0]
//            self.present(mapVc, animated: true, completion: nil)
//        } else {
//            print("whoops")
//        }
        if let listVc = UIStoryboard(name: "LocationList", bundle: nil).instantiateViewController(withIdentifier: "LocationListViewController") as? StudentListViewController {
            self.present(listVc, animated: true, completion: nil)
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
