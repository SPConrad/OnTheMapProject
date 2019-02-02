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
    
    func getUser(_ onComplete: ((_ userData: Data?, _ error: String?) -> Void)?) {
        
        guard let userId = loggedInUser?.key else {
            onComplete?(nil, "Error getting userID")
            return
        }
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/users/\(userId)")!)
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // encoding a JSON body from a string, can also use a Codable struct
        
        let session = URLSession.shared
        
        
        let task = session.dataTask(with: request) { data, response, error in
            
            if error != nil { // Handle error…
                onComplete?(nil, String(describing: error))
            }
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            if statusCode >= 400 && statusCode <= 403 {
                let errorMessage = "Bad credentials."
                onComplete?(nil, errorMessage)
                return
            } else if statusCode < 200 && statusCode > 299 {
                print("Unexpected server error")
                onComplete?(nil, "Unexpected server error")
                return
            }
            
            onComplete?(data, nil)
        }
        
        task.resume()
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
            
            guard let newData = data?.subdata(in: range) else {
                print("Invalid response")
                onComplete?("Unexpected bad JSON response")
                return
            }
            
            let jsonData = JSON.deserialize(data: newData)
            
            guard let accountData = jsonData["account"] as? [String: AnyObject] else {
                print("Invalid response")
                onComplete?("Unexpected server error")
                return
            }
            
            guard let SessionData = jsonData["session"] as? [String: AnyObject] else {
                print("Invalid response")
                onComplete?("Unexpected server error")
                return
            }
            self.loggedInUser = UdacityUser()
            self.loggedInUser?.username = username
            self.loggedInUser?.key = accountData["key"] as? String
            self.loggedInUser?.sessionId = SessionData["id"] as? String
            onComplete?(nil)
        }
        
        task.resume()
    }
    
    
    
    
}
