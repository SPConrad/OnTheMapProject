
//
//  File.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/31/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import Foundation

public protocol LocationService {
    
    associatedtype ResponseType
    associatedtype LocationResponse
        
    func getLocation(id: String, completion: @escaping (Data) -> Void)
    
    func getLocations(completion: @escaping (Data) -> Void)
    
    func postLocation(location: String, completion: @escaping (Data) -> Void)
    
    func deleteLocation(location: String, completion: @escaping (Data) -> Void)
    
}
