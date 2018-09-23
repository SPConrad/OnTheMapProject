//
//  SharedClient.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 9/22/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    var session = URLSession.shared
    
    override init() {
        super.init()
        
        
    }
    
    func taskForGETMethod(_ method: String,_ parameters: [String:AnyObject],
                          onSuccess: @escaping (_ data: Data) -> Void,
                          onFailure: @escaping (_ error: NSError) -> Void,
                          onComplete: @escaping () -> Void) {
        
        // 1. Set parameters
        var parametersWithApiKey = parameters
        parametersWithApiKey[ParameterKeys.ApiKey] = Constants.ApiKey as AnyObject
        
        // 2/3. Build the URL, Configure request
        let request = NSMutableURLRequest(url: urlFromParameters(parametersWithApiKey, withPathExtension: method))

        setHttpHeaders(request)
        
        // 4. Make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                onFailure(NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            if let data = data {
               onSuccess(data)
            }
            
            onComplete()
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            //self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    
//    // given raw JSON, return a usable Foundation object
//    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
//
//        var parsedResult: AnyObject! = nil
//        do {
//            let parsedResult = JSON.deserialize(data: data)//try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
//        } catch {
//            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
//            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
//        }
//
//        completionHandlerForConvertData(parsedResult, nil)
//    }
//
    private func setHttpHeaders(_ urlRequest: NSMutableURLRequest){
        urlRequest.setValue(ParameterKeys.AppId, forHTTPHeaderField: Constants.AppId)
        urlRequest.setValue(ParameterKeys.ApiKey, forHTTPHeaderField: Constants.ApiKey)
    }
    
    private func urlFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = ParseClient.Constants.ApiScheme
        components.host = ParseClient.Constants.ApiHost
        components.path = ParseClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}


//func getLocations(completion: @escaping (_ responseData: Data) -> Void) {
//    var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=50")!)
//    request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
//    request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
//    let session = URLSession.shared
//    let task = session.dataTask(with: request) { data, response, error in
//        if data != nil { // Handle error...
//            completion(data!)
//            return
//        }
//    }
//    task.resume()
//}
