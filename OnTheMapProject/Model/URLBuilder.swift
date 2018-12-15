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
        return UdacityClient.Constants.BaseUrl + "/session"
    }
    
    class func userInformationUrl(id: String) -> String {
        return UdacityClient.Constants.BaseUrl + "/users/\(id)"
    }
    
    class func studentLocationUrl() -> String {
        return ParseClient.Constants.BaseUrl + "/parse/classes/StudentLocation"
    }
    
}



/*For POSTing and DELETEing a session, change https://www.udacity.com/api/session to https://onthemap-api.udacity.com/v1/session.
 
 For GETting public user data, change https://www.udacity.com/api/users/< user_id > to https://onthemap-api.udacity.com/v1/users/< user_id >.
 
 */
