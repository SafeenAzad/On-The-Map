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
        static let apiScheme = "https"
        static let apiHost = "parse.udacity.com"
        static let apiPath = "/parse/classes"
        static let applicationJSON = "application/json"
        static let getSessionURL = "https://www.udacity.com/api"
    }

    
    struct ParseParameterKeys {
        static let limit = "limit"
        static let skip = "skip"
        static let order = "order"
    }
    
    struct ParseParameterValues {
        static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let appID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let limit = "100"
        static let skip = "400"
        static let order = "-updatedAt"
    }
    
    struct Methods {
        
        static let studentLocations = "/StudentLocation"
        static let session = "/session"
        static let users = "/users"
    }
    
    struct HTTPHeaderField {
        
        static let parseAppID = "X-Parse-Application-Id"
        static let parseRestApiKey = "X-Parse-REST-API-Key"
        static let contentType = "Content-Type"
        static let acceptField = "Accept"
    }
    
    struct JSONResponseKeys {
        
        static let objectID = "objectId"
    
        static let uniqueKey = "uniqueKey"
        
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        
        static let account = "account"
        static let registered = "registered"
        static let key = "key"
        
        static let session = "session"
        static let sessionId = "id"
        static let expiration = "expiration"
        
        static let results = "results"
        static let statusCode = "status_code"
    }
    
    struct JSONBodyKeys {
        static let udacityKey = "udacity"
        static let userNameKey = "username"
        static let passwordKey = "password"
    }
    
    struct Str {
        static let noConnection = "No internet connection"
        static let checkConnection = "Check connection and try again"
    }
    
    enum HTTPRequest {
        static let GET = "GET"
        static let POST = "POST"
        static let PUT = "PUT"
        static let DELETE = "DELETE"
    }
}
