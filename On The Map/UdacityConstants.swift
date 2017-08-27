//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Safeen Azad on 8/26/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//
import Foundation

extension UdacityClient{

struct Constants {
    
        static let BaseURLSecure = "https://www.udacity.com/api/"
        
        // fb remaining
    
    }
    struct Methods {
        static let Session = "session"
        static let GetUserData = "users/{id}"
    }
    
    
    struct ParameterKeys {
    
    static let Udacity = "udacity"
    static let Username = "username"
    static let Password = "password"
    static let AccessToken = "access_token"
    }

    struct URLKeys {
        static let id = "id"
    }
    
    struct JSONResponseKeys {
        static let Session  = "session"
        static let SessionID = "id"
        static let Account = "account"
        static let User = "user"
        static let FirstName = "nickname"
        static let LastName = "last_name"
        static let IDKey = "key"
    }
    
    enum HTTPRequest {
        static let GET = "GET"
        static let POST = "POST"
        static let DELETE = "DELETE"
    }
}
