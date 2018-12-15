//
//  SharedClient.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 9/22/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import Foundation
class ParseClient: NSObject {
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    var session = URLSession.shared
    
    override init() {
        super.init()
    }
    
    func getStudentLocations(onSuccess: @escaping (_ students: [Student]) -> Void,
                             onFailure: @escaping (_ error: String) -> Void,
                             onComplete: @escaping ()-> Void) {
        
        let url = URLBuilder.studentLocationUrl()

        
        request(method: "GET", url: url, onSuccess: { (data) in
            let parsedResults = JSON.deserialize(data: data)
            if let results = parsedResults["results"] as? [[String:AnyObject]] {
                var students: [Student] = [Student]()
                
                for student in results {
                    students.append(Student(student: student))
                }
                onSuccess(students)
            }
        }, onFailure: { (error) in
            onFailure("error")
        }, onCompleted: {
            onComplete()
        })
    }
    
    func postStudentLocation(newStudent: Student, _ onComplete: ((_ error: String?) -> Void)?) {

        let id = 0
//        let url = URLBuilder.studentLocationUrl()
//
//        let parameters = [
//            "uniqueKey": id as AnyObject,
//            "firstName": newStudent.firstName as AnyObject,
//            "lastName": newStudent.lastName as AnyObject,
//            "mapString": "" as AnyObject,
//            "mediaURL": newStudent.mediaURL as AnyObject,
//            "latitude": newStudent.latitude as AnyObject,
//            "longitude": newStudent.longitude as AnyObject
//            ] as [String:AnyObject]


        let uniqueKey = UdacityClient.sharedInstance().loggedInUser?.key
        let bodyString = "{\n  \"uniqueKey\" : \"\(String(describing: uniqueKey))\",\n  \"firstName\" : \"S\",\n  \"mapString\" : \"Durham, NC\",\n  \"mediaURL\" : \"http:\\/\\/google.com\",\n  \"lastName\" : \"C\",\n  \"longitude\" : -78.899108999999996,\n  \"latitude\" : 35.995930"
        
        
        let urlString = UdacityClient.Constants.BaseUrl + "parse/classes/StudentLocation"
        var makeRequest: URLRequest = baseURLRequest(with: urlString)
        
        makeRequest.httpMethod = "POST"
        makeRequest.httpBody = bodyString.data(using: String.Encoding.utf8)
        
        performRequest(makeRequest) { (jsonResponse, error) in
            
            guard error == nil else {
                onComplete?(error)
                return
            }
            
            guard (jsonResponse!["objectId"] as? String) != nil else {
                print("Invalid response")
                onComplete?("Invalid response")
                return
            }
            
            onComplete?(nil)
        }
        
    }
    
    func performRequest(_ request: URLRequest, completionBlock: ((_ result: AnyObject?, _ error: String?) -> Void)?) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                print("There was an error with your request")
                completionBlock?(nil, "There was an error with your request")
                return
            }
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            if statusCode == 403 {
                print("Wrong credentials")
                completionBlock?(nil, "Username or password incorrect")
                return
            }
            else if statusCode < 200 && statusCode > 299 {
                print("Unexpected server error")
                completionBlock?(nil, "Unexpected server error")
                return
            }
            
            guard let processedData = self.processData(data) else {
                print("No data returned from the server")
                completionBlock?(nil, "Unexpected server error")
                return
            }
            
            let jsonResponse: [String:AnyObject]
            
            do {
                jsonResponse = try JSONSerialization.jsonObject(with: processedData, options: []) as! [String:AnyObject]
            } catch {
                print("Error parsing JSON")
                completionBlock?(nil, "Unexpected error")
                return
            }
            ///request.description    String    "https://parse.udacity.com/parse/classes/StudentLocation/Ia4F3jLLFS"    
            completionBlock?(jsonResponse as AnyObject, nil)
        }
        
        task.resume()
    }
    
    func processData(_ data: Data?) -> Data? {
        return data!
    }
    
    func baseURLRequest(with endpoint: String) -> URLRequest {
        var baseURLRequest = URLRequest(url: URL(string: endpoint)!)
        baseURLRequest.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        baseURLRequest.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        baseURLRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return baseURLRequest
    }
    
    func request(method: String, url: String, parameters: [String: Any]? = nil, headers: [String: String]? = nil,
                 onSuccess: @escaping (_ data: Data) -> Void,
                 onFailure: @escaping (_ error: String) -> Void,
                 onCompleted: @escaping ()-> Void) {
        
        let encodeUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let request = NSMutableURLRequest(url: URL(string: encodeUrl!)!)
        
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(Constants.AppId, forHTTPHeaderField: ParameterKeys.AppId)
        request.addValue(Constants.ApiKey, forHTTPHeaderField: ParameterKeys.ApiKey)
        
        if let headers = headers{
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch {
                onFailure("Unexpected error")
                onCompleted()
            }
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                onFailure("Unexpected error")
                
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                if let data = data {
                    let newData = data.subdata(in: Range(uncheckedBounds: (5, data.count)))
                    let parsedResult = JSON.deserialize(data: newData) as? [String:AnyObject]
                    onFailure("Unexpected error")
                } else {
                    onFailure("Unexpected error")
                }
                
                return
            }
            
            if let data = data {
                onSuccess(data)
            }
            
            onCompleted()
            
        }
        
        task.resume()
    }
    
}
