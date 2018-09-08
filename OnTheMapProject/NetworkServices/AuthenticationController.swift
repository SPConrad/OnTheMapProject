//
//  NetworkService.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/26/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import Foundation

class AuthenticationController: AuthenticationService {
    let baseApiURL = "https://parse.udacity.com/parse/"
    let studentLocationApiEndPoint = "classes/StudentLocation"
    let sessionApiEndPoint = "session"
    
    var loginPath: String = ""
    typealias ResponseType = String
    typealias AuthResponse = String
    
    func buildSessionUrl() -> String {
        return baseApiURL + sessionApiEndPoint
    }
    
    func buildSessionRequest(username: String? = nil, password: String? = nil) -> URLRequest {
        var request = URLRequest(url: URL(string: buildSessionUrl())!)
        if username == nil && password == nil {
            request.httpMethod = "DELETE"
            var xsrfCookie: HTTPCookie? = nil
            let sharedCookieStorage = HTTPCookieStorage.shared
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
        } else {
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        }
        
        return request
    }
    
    func authenticate(username: String, password: String, completion: @escaping (String) -> Void) {
        let request = buildSessionRequest(username: username, password: password)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
        }
        task.resume()
    }
    
    func logout() {
        var request = buildSessionRequest()
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
        }
        task.resume()
    }
    
    
}

// DELETE a Session (Log out)
/*
 var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
 request.httpMethod = "DELETE"
 var xsrfCookie: HTTPCookie? = nil
 let sharedCookieStorage = HTTPCookieStorage.shared
 for cookie in sharedCookieStorage.cookies! {
 if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
 }
 if let xsrfCookie = xsrfCookie {
 request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
 }
 let session = URLSession.shared
 let task = session.dataTask(with: request) { data, response, error in
 if error != nil { // Handle error…
 return
 }
 let range = Range(5..<data!.count)
 let newData = data?.subdata(in: range) /* subset response data! */
 print(String(data: newData!, encoding: .utf8)!)
 }
 task.resume()
 */

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

// GET Public User Data
/*
let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/3903878747")!)
let session = URLSession.shared
let task = session.dataTask(with: request) { data, response, error in
    if error != nil { // Handle error...
        return
    }
    let range = Range(5..<data!.count)
    let newData = data?.subdata(in: range) /* subset response data! */
    print(String(data: newData!, encoding: .utf8)!)
}
task.resume()
*/

// POST a Session (Login)
/*
var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
request.httpMethod = "POST"
request.addValue("application/json", forHTTPHeaderField: "Accept")
request.addValue("application/json", forHTTPHeaderField: "Content-Type")
request.httpBody = "{\"udacity\": {\"username\": \"account@domain.com\", \"password\": \"********\"}}".data(using: .utf8)
let session = URLSession.shared
let task = session.dataTask(with: request) { data, response, error in
    if error != nil { // Handle error…
        return
    }
    let range = Range(5..<data!.count)
    let newData = data?.subdata(in: range) /* subset response data! */
    print(String(data: newData!, encoding: .utf8)!)
}
task.resume()
*/

// DELETE a Session (Log out)
/*
var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
request.httpMethod = "DELETE"
var xsrfCookie: HTTPCookie? = nil
let sharedCookieStorage = HTTPCookieStorage.shared
for cookie in sharedCookieStorage.cookies! {
    if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
}
if let xsrfCookie = xsrfCookie {
    request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
}
let session = URLSession.shared
let task = session.dataTask(with: request) { data, response, error in
    if error != nil { // Handle error…
        return
    }
    let range = Range(5..<data!.count)
    let newData = data?.subdata(in: range) /* subset response data! */
    print(String(data: newData!, encoding: .utf8)!)
}
task.resume()
*/


// POST a Session with Facebook
/*
var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
request.httpMethod = "POST"
request.addValue("application/json", forHTTPHeaderField: "Accept")
request.addValue("application/json", forHTTPHeaderField: "Content-Type")
request.httpBody = "{\"facebook_mobile\": {\"access_token\": \"DADFMS4SN9e8BAD6vMs6yWuEcrJlMZChFB0ZB0PCLZBY8FPFYxIPy1WOr402QurYWm7hj1ZCoeoXhAk2tekZBIddkYLAtwQ7PuTPGSERwH1DfZC5XSef3TQy1pyuAPBp5JJ364uFuGw6EDaxPZBIZBLg192U8vL7mZAzYUSJsZA8NxcqQgZCKdK4ZBA2l2ZA6Y1ZBWHifSM0slybL9xJm3ZBbTXSBZCMItjnZBH25irLhIvbxj01QmlKKP3iOnl8Ey;\"}}".data(using: .utf8)
let session = URLSession.shared
let task = session.dataTask(with: request) { data, response, error in
    if error != nil { // Handle error...
        return
    }
    let range = Range(5..<data!.count)
    let newData = data?.subdata(in: range) /* subset response data! */
    print(String(data: newData!, encoding: .utf8)!)
}
task.resume()
*/

/*
 Logout with Facebook
 If you're implementing Facebook login, then deleting a session with Udacity's API is just the first step of "logging out". To be thorough, you should also logout of your Facebook session.
 
 This can be accomplished using Facebook’s FBSDKLoginButton or programmatically. With the FBSDKLoginManager, the logout behavior is built-in; however, if you want to log out programmatically, you’ll need to use the FBSDKLoginManager. For help, consult Facebook’s iOS documentation https://developers.facebook.com/docs/ios.
 */

















