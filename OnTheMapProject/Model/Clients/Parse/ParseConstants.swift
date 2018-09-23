//
//  SharedConstants.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 9/19/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit

extension ParseClient {
   
    // MARK: PARSE
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
        static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let AppId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    }
    
    // MARK: Parse Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "X-Parse-REST-API-Key"
        static let AppId = "X-Parse-Application-Id"
        static let Limit = "?limit={num}"
        static let Skip = "?skip"
        static let Order = "?order"
        static let Where = "?where"
        static let ObjectId = "objectId"
    }
    
    // MARK: Methods
    struct Methods {
        static let StudentLocation = "/studentlocation"
        
    }
    
    // MARK: Parse Response Keys
    struct JSONResponseKeys {
        static let Results = "Results"
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaUrl = "mediaURL"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
    }
}
