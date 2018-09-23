//
//  ParseConvenience.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 9/22/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit
import Foundation

extension ParseClient {
    
    // MARK: GET Convenience Methods
    
    // MARK: Get All Locations
    
    func getAllLocations( onSuccess: @escaping (_ locations: [ParseLocation]?) -> Void,
                         onFailure: @escaping (_ error: NSError) -> Void,
                         onComplete: @escaping () -> Void) {
        
        /* 1. Specify parameters, method */
        let parameters = [ParseClient.ParameterKeys.ApiKey: ParseClient.Constants.ApiKey, ParseClient.ParameterKeys.AppId: ParseClient.Constants.AppId]
        let mutableMethod: String = ParseClient.Methods.StudentLocation
        
        /* 2. Make the request */
        
        let _ = taskForGETMethod(mutableMethod, parameters as [String : AnyObject], onSuccess: { (data) in
            
            let deserialized = JSON.deserialize(data: data)
            if let results = deserialized["results"] as? [[String:AnyObject]] {
                var locations: [ParseLocation] = [ParseLocation]()
                
                for result in results {
                    locations.append(ParseLocation(location: result))
                }
            }
            
            
        }, onFailure: { (error) in
            onFailure(error)
        }, onComplete: {
            onComplete()
        })
    }
    
    
}
