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
    
    func postStudentLocation(newStudent: Student, onSuccess: @escaping (_ response: [[String:AnyObject]]) -> Void,
                             onFailure: @escaping (_ error: String) -> Void,
                             onComplete: @escaping ()-> Void) {
        let id = 0
        let firstName = "Sean"
        let lastName = "Conrad"
        let mapString = "Durham, NC"
        let mediaUrl = "https://www.google.com"
        let latitude = 0.00
        let longitude = 0.00
        let url = URLBuilder.studentLocationUrl()
        
        let parameters = [
            "uniqueKey": id,
            "firstName": firstName,
            "lastName": lastName,
            "mapString": mapString,
            "mediaURL": mediaUrl,
            "latitude": latitude,
            "longitude": longitude
            ] as [String:AnyObject]
        
        /* Response:
         {
         "createdAt":"2015-03-11T02:48:18.321Z",
         "objectId":"CDHfAy8sdp"
         }
         */
        
        
        
        request(method: "POST", url: url, parameters: parameters, onSuccess: { (data) in
            let parsedResults = JSON.deserialize(data: data)
            if let results = parsedResults["results"] as? [[String:AnyObject]] {
                
                onSuccess(results)
            }
        }, onFailure: { (error) in
            onFailure("error")
        }, onCompleted: {
            onComplete()
        })
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
