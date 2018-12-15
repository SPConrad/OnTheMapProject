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
//        if let listTbVc = UIStoryboard(name: "LocationList", bundle: nil).instantiateViewController(withIdentifier: "StudentListTabBarViewController") as? StudentListTabBarViewController {
//            listTbVc.configure(.list)
//            self.present(listTbVc, animated: true, completion: nil)
//        } else {
//            print("Whoops")
//        }
//

        guard let username = emailTextField.text?.trimmingCharacters(in: .whitespaces), let password = passwordTextField.text?.trimmingCharacters(in: .whitespaces) else { return }

        sendLoginRequest(username: username, password: password)
        
    }
    
    @IBAction func pressSignUpButton(_ sender: Any) {
        
    }
    
    func sendLoginRequest(username: String, password: String) {
        UdacityClient.sharedInstance().postSession(username: username, password: password, { (error) -> Void in
            DispatchQueue.main.async {
                if let listTbVc = UIStoryboard(name: "LocationList", bundle: nil).instantiateViewController(withIdentifier: "StudentListTabBarViewController") as? StudentListTabBarViewController {
                    listTbVc.configure(.list)
                    self.present(listTbVc, animated: true, completion: nil)
                } else {
                    print("Whoops")
                }
        
            }
            if let error = error {
                print("Error: \(error)")
            }
        })
        
    }
    

}
