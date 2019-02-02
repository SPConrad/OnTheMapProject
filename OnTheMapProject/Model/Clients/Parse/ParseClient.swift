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
    
    func getStudentLocation(uniqueKey: String, _ onComplete: ((_ student: Student?, _ error: String?) -> Void)?) {
        
        var urlString = URLBuilder.studentLocationUrl()
        let parameters = ["where" : "{\"uniqueKey\": \"\(uniqueKey)\"}"]
        
        let encodedParameters = NSURLComponents()
        encodedParameters.queryItems = parameters.map { URLQueryItem(name: $0, value: String($1)) }
        
        urlString = urlString + encodedParameters.percentEncodedQuery!
        
        var makeRequest: URLRequest = baseURLRequest(with: urlString)
        
        makeRequest.httpMethod = "GET"
        
        performRequest(makeRequest) { (jsonResponse, error) in
            
            guard error == nil else {
                onComplete?(nil, error)
                return
            }
            
            guard (jsonResponse!["objectId"] as? String) != nil else {
                onComplete?(nil, "Student does not exist")
                return
            }
            
            let student = Student(student: jsonResponse as! [String:AnyObject])
            
            onComplete?(student, nil)
        }
        
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
    
    func postStudentLocation(method: String, mapString: String, mediaUrl: String, lat: Double, lon: Double, _ onComplete: ((_ objectId: String?, _ error: String?) -> Void)?) {

        let urlString = URLBuilder.studentLocationUrl()

        let parameters = [
            "uniqueKey": UdacityClient.sharedInstance().loggedInUser?.key as AnyObject,
            "firstName": UdacityClient.sharedInstance().loggedInUser?.firstName as AnyObject,
            "lastName": UdacityClient.sharedInstance().loggedInUser?.lastName as AnyObject,
            "mapString": mapString as AnyObject,
            "mediaURL": mediaUrl as AnyObject,
            "latitude": lat as AnyObject,
            "longitude": lon as AnyObject
            ] as [String:AnyObject]
        
        guard let postData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            onComplete?(nil, "Error generating POST json data object")
            return
        }
        
        let postJson: String! = String(data: postData, encoding: String.Encoding.utf8)
        
        var makeRequest: URLRequest = baseURLRequest(with: urlString)

        makeRequest.httpMethod = method
        
        makeRequest.httpBody = postJson.data(using: String.Encoding.utf8)

        performRequest(makeRequest) { (jsonResponse, error) in

            guard error == nil else {
                onComplete?(nil, error)
                return
            }

            guard let objectId = (jsonResponse!["objectId"] as? String) else {
                onComplete?(nil, "Invalid response")
                return
            }

            onComplete?(objectId, nil)
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
