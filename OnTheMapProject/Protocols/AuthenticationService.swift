//
//  NetworkService.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/26/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import Foundation

public protocol AuthenticationService {
    
    associatedtype ResponseType
    associatedtype AuthResponse
    
    var loginPath: String { get set }
    
    func authenticate(username: String, password: String, completion: @escaping (AuthResponse) -> Void)
    
    func logout()
}

public protocol NetworkResponse {
    
}
