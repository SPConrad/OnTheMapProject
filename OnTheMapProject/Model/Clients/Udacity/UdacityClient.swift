//
//  UdacityClient.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 9/22/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
    var loggedInUser: UdacityUser?
    
    var session = URLSession.shared
    
    func assignLoggedInUser(_ newData: Data) {
        let parsedResults = JSON.deserialize(data: newData) as! [String:AnyObject]
        loggedInUser = UdacityUser(parsedResults)
        
        print(newData)
    }
    
    func postSession(username: String, password: String, _ onComplete: ((_ error: String?) -> Void)?) {
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // encoding a JSON body from a string, can also use a Codable struct
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let session = URLSession.shared
        
        
        let task = session.dataTask(with: request) { data, response, error in
            
            if error != nil { // Handle error…
                onComplete?(String(describing: error))
            }
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            if statusCode >= 400 && statusCode <= 403 {
                let errorMessage = "Bad credentials."
                onComplete?(errorMessage)
                return
            } else if statusCode < 200 && statusCode > 299 {
                print("Unexpected server error")
                onComplete?("Unexpected server error")
                return
            }
            
            let range = Range(5..<data!.count)
            
            let newData = data?.subdata(in: range) /* subset response data! */
            
            self.assignLoggedInUser(newData!)
            
            print("now logged in")
            print(String(data: newData!, encoding: .utf8)!)
            
            onComplete?(nil)
        }
        
        task.resume()
    }
    
}
