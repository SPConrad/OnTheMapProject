//
//  LocationController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/31/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import Foundation

class LocationController: LocationService {
    
    typealias ResponseType = String
    typealias LocationResponse = String
    
    func getLocation(id: String, completion: @escaping (_ responseData: Data) -> Void) {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                completion(data!)
                return
            }
        }
        task.resume()
    }
    
    func getLocations(completion: @escaping (_ responseData: Data) -> Void) {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=50")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if data != nil { // Handle error...
                completion(data!)
                return
            }
        }
        task.resume()
    }
    
    func postLocation(location: String, completion: @escaping (_ responseData: Data) -> Void) {
        var firstName = ""
        var lastName = ""
        var mapString = ""
        var medialUrl = ""
        var lat = 0
        var lon = 0
        
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.httpBody = "{\"uniqueKey\": \"1234\", \"firstName\": \(firstName), \"lastName\": \(lastName),\"mapString\": \(mapString), \"mediaURL\": \(mediaUrl),\"latitude\": \(lat), \"longitude\": \(lon)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            print(String(data: data!, encoding: .utf8)!)
        }
        task.resume()
    }
    
    func updateLocation(location: String, completion: @escaping (_ responseData: Data) -> Void) {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/8ZExGR5uX8"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.httpBody = "{\"uniqueKey\": \"1234\", \"firstName\": \(firstName), \"lastName\": \(lastName),\"mapString\": \(mapString), \"mediaURL\": \(mediaUrl),\"latitude\": \(lat), \"longitude\": \(lon)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            print(String(data: data!, encoding: .utf8)!)
        }
        task.resume()
    }
    
    func deleteLocation(location: String, completion: @escaping (Data) -> Void) {
        
    }
    

}

// GET Student Locations
/*
 var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
 request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
 request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
 let session = URLSession.shared
 let task = session.dataTask(with: request) { data, response, error in
 if error != nil { // Handle error...
 return
 }
 print(String(data: data!, encoding: .utf8)!)
 }
 task.resume()
 */


// GET A Student Location
/*
 let urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
 let url = URL(string: urlString)
 var request = URLRequest(url: url!)
 request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
 request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
 let session = URLSession.shared
 let task = session.dataTask(with: request) { data, response, error in
 if error != nil { // Handle error
 return
 }
 print(String(data: data!, encoding: .utf8)!)
 }
 task.resume()
 */


// POST A Student Location
/*
 var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
 request.httpMethod = "POST"
 request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
 request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
 request.addValue("application/json", forHTTPHeaderField: "Content-Type")
 request.httpBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}".data(using: .utf8)
 let session = URLSession.shared
 let task = session.dataTask(with: request) { data, response, error in
 if error != nil { // Handle error…
 return
 }
 print(String(data: data!, encoding: .utf8)!)
 }
 task.resume()
 */




// PUT (update) A Student Location
/*
 let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/8ZExGR5uX8"
 let url = URL(string: urlString)
 var request = URLRequest(url: url!)
 request.httpMethod = "PUT"
 request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
 request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
 request.addValue("application/json", forHTTPHeaderField: "Content-Type")
 request.httpBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Cupertino, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.322998, \"longitude\": -122.032182}".data(using: .utf8)
 let session = URLSession.shared
 let task = session.dataTask(with: request) { data, response, error in
 if error != nil { // Handle error…
 return
 }
 print(String(data: data!, encoding: .utf8)!)
 }
 task.resume()
 */
