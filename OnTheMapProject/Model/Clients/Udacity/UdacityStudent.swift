//
//  UdacityStudent.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 12/2/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import Foundation

public struct UdacityUser {
    let username: String?
    let key: String?
    let sessionId: String?
    let firstName: String?
    let lastName: String?
    
    init(_ user: [String:AnyObject]) {
        username = user["username"] as? String ?? ""
        key = user["key"] as? String ?? ""
        sessionId = user["sessionId"] as? String ?? ""
        firstName = user["firstName"] as? String ?? ""
        lastName = user["lastName"] as? String ?? ""
    }
}
