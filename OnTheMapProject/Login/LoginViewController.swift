//
//  LoginViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/19/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPress(_ sender: Any) {

        guard let username = emailTextField.text?.trimmingCharacters(in: .whitespaces), let password = passwordTextField.text?.trimmingCharacters(in: .whitespaces) else { return }

        sendLoginRequest(username: username, password: password)
        
    }
    
    @IBAction func pressSignUpButton(_ sender: Any) {
        
    }
    
    func sendLoginRequest(username: String, password: String) {
        UdacityClient.sharedInstance().postSession(username: "konrad9@gmail.com", password: password, { (error) -> Void in
            if let error = error {
                print("Error: \(error)")
            } else {
                DispatchQueue.main.async {
                    let listMapViewStoryboard = UIStoryboard(name: "LocationList", bundle: nil)
                    let listMapVc = listMapViewStoryboard.instantiateViewController(withIdentifier: "ListMapView") as! ListMapViewController
                    self.present(listMapVc, animated: true, completion: nil)
                }
            }
        })
    }
    
}
