//
//  Location.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/22/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import Foundation
import MapKit

public struct ParseLocation: Codable {
    
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
    
    // MARK: Initializers
    
    init(location: [String:AnyObject]) {
        createdAt = location["createdAt"] as? String ?? ""
        firstName = location["firstName"] as? String ?? ""
        lastName = location["lastName"] as? String ?? ""
        latitude = location["latitude"] as? Double ?? 0.0
        longitude = location["longitude"] as? Double ?? 0.0
        mapString = location["mapString"] as? String ?? ""
        mediaURL = location["mediaURL"] as? String ?? ""
        objectId = location["objectId"] as? String ?? ""
        updatedAt = location["updatedAt"] as? String ?? ""
        uniqueKey = location["uniqueKey"] as? String ?? ""
    }
    
    static func locationsFromResults(_ results: [[String:AnyObject]]) -> [ParseLocation] {
        
        var locations = [ParseLocation]()
        
        for result in results {
            locations.append(ParseLocation(location: result))
        }
        
        return locations        
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

    
    public static func == (lhs: ParseLocation, rhs: ParseLocation) -> Bool {
        return lhs.objectId == rhs.objectId
    }
}


//extension Location {
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        do {
//            createdAt = try values.decode(String.self, forKey: .createdAt)
//            firstName = try values.decode(String.self, forKey: .firstName)
//            lastName = try values.decode(String.self, forKey: .lastName)
//            latitude = try values.decode(Float.self, forKey: .latitude)
//            longitude = try values.decode(Float.self, forKey: .longitude)
//            mapString = try values.decode(String.self, forKey: .mapString)
//            mediaURL = try values.decode(String.self, forKey: .mediaURL)
//            objectId = try values.decode(String.self, forKey: .objectId)
//            uniqueKey = try values.decode(Int.self, forKey: .uniqueKey)
//            updatedAt = try values.decode(String.self, forKey: .updatedAt)
//        } catch DecodingError.typeMismatch {
//            do {
//                throw DecodingError.typeMismatch(Location.self,
//                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
//            }
//        }
//    }
//}




