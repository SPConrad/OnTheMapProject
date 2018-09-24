//
//  Location.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/22/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import Foundation
import MapKit

public struct Student: Codable {
    
    // MARK: Properties
    let createdAt: String?
    let firstName: String?
    let lastName: String?
    let latitude: Double?
    let longitude: Double?
    let mapString: String?
    let mediaURL: String?
    let objectId: String?
    let uniqueKey: String?
    let updatedAt: String?
    
    // MARK: Initializer
    init(student: [String:AnyObject]) {
        createdAt = student["createdAt"] as? String ?? ""
        firstName = student["firstName"] as? String ?? ""
        lastName = student["lastName"] as? String ?? ""
        latitude = student["latitude"] as? Double ?? 0.0
        longitude = student["longitude"] as? Double ?? 0.0
        mapString = student["mapString"] as? String ?? ""
        mediaURL = student["mediaURL"] as? String ?? ""
        objectId = student["objectId"] as? String ?? ""
        updatedAt = student["updatedAt"] as? String ?? ""
        uniqueKey = student["uniqueKey"] as? String ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case createdAt = "createdAt"
        case firstName = "firstName"
        case lastName = "lastName"
        case latitude = "latitude"
        case longitude = "longitude"
        case mapString = "mapString"
        case mediaURL = "mediaURL"
        case objectId = "objectId"
        case uniqueKey = "uniqueKey"
        case updatedAt = "updatedAt"
    }
    
    func fullName() -> String {
        if let firstName = firstName, firstName != "", let lastName = lastName, lastName != "" {
            return "\(firstName) \(lastName)"
        }
        return "Missing Name"
    }
    
    static func locationsFromResults(_ results: [[String:AnyObject]]) -> [Student] {
        
        var locations = [Student]()
        
        for result in results {
            locations.append(Student(student: result))
        }
        
        return locations
    }
    
    public static func == (lhs: Student, rhs: Student) -> Bool {
        return lhs.objectId == rhs.objectId
    }
}
