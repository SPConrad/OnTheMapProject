//
//  UdacityConstants.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 9/22/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit

extension UdacityClient {
    
    // MARK: UDACITY
    struct Constants {
        static let ApiScheme = "https://"
        static let ApiHost = "onthemap-api.udacity.com"
        static let ApiPath = "/v1"
        static let BaseUrl = ApiScheme + ApiHost + ApiPath
    }
    
    // MARK: Udacity Parameter Keys
    struct ParameterKeys {
        static let Users = "/users"
        static let Udacity = "udacity"
        static let Username = "Username"
        static let Password = "Password"
    }
    
    // MARK: Udacity Response Keys
    struct ResponseKeys {
        static let Account = "Account"
        static let Registered = "registered"
        static let Key = "key"
        static let Session = "session"
        static let Id = "id"
        static let Expiration = "expiration"
    }
}
