//
//  URLBuilder.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 9/23/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import Foundation

class URLBuilder: NSObject {
    
    class func authUrl() -> String {
        return UdacityClient.Constants.BaseUrl + "/api/session"
    }
    
    class func userInformationUrl(key: String) -> String {
        return UdacityClient.Constants.BaseUrl + "/api/users/\(key)"
    }
    
    class func studentLocationUrl() -> String {
        return ParseClient.Constants.BaseUrl + "/parse/classes/StudentLocation"
    }
    
}
