//
//  ParseConstants.swift
//  On The Map
//
//  Created by Safeen Azad on 8/29/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import Foundation

extension ParseClient {
    struct Constants {
        static let baseURLSecure = "https://parse.udacity.com/parse/classes/"
        
        static let app_id = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let api_key = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
    }
    
    struct Methods {
        static let StudentLocations = "StudentLocation"
}
    
    struct ParameterKeys {
        static let limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
    }
    
    struct QueryArguments {
        static let Where = "where"
    }
    
    struct JSONResponseKeys {
        
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let mapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        static let ACL = "ACL"
        static let Results = "results"
        static let Error = "error"
        static let Status = "status"
    }
    
    
    enum HTTPRequest {
        static let GET = "GET"
        static let POST = "POST"
        static let PUT = "PUT"
        static let DELETE = "DELETE"
    }
}
