//
//  LoginViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/19/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit

class LoginViewController: ViewController {
    
    

    @IBOutlet weak var logoImageView: UIImageView!
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
        
    }
    
    
    
    @IBAction func pressSignUpButton(_ sender: Any) {
        
    }
    
    /*
    private func authorize(qid: String, and password: String) {
        factory?.service?.authenticate(with: qid, and: password) { [weak self] response, errorMsg in
            if let errorMsg = errorMsg {
                self?.handleAuthorizationFailure(errorMsg)
            } else {
                self?.handleAuthorizationSuccess(response)
            }
        }
    }
    */
    
    func sendLoginRequest() {
        
    }
    
    func loginResponseHandler() {
        
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
