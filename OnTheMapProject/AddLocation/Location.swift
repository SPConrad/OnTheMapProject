//
//  Location.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 8/22/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import Foundation
import MapKit

struct Location: Codable {
    var createdAt: String!
    var firstName: String!
    var lastName: String!
    var latitude: Float!
    var longitude: Float!
    var mapString: String!
    var mediaURL: String!
    var objectId: String!
    var uniqueKey: Int!
    var updatedAt: String!
    
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




