//
//  StudentInformation.swift
//  On The Map
//
//  Created by Safeen Azad on 8/29/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import Foundation
import UIKit

struct StudentInformation {
    
    var objectId: String?
    var uniqueKey: String?
    
    var firstName : String?
    var lastName : String?
    
    var mapString : String?
    var mediaURL : String?
    
    var latitude: Double?
    var longitude: Double?
    
    var createdAt: String?
    var updatedAt : String?
    
    init(dictionary: [String:AnyObject]) {
        objectId = dictionary[ParseClient.JSONResponseKeys.objectID] != nil ? dictionary[ParseClient.JSONResponseKeys.objectID] as? String : ""
        uniqueKey = dictionary[ParseClient.JSONResponseKeys.uniqueKey] != nil ? dictionary[ParseClient.JSONResponseKeys.uniqueKey] as? String : ""
        firstName = dictionary[ParseClient.JSONResponseKeys.firstName] != nil ? dictionary[ParseClient.JSONResponseKeys.firstName] as? String : ""
        lastName = dictionary[ParseClient.JSONResponseKeys.lastName] != nil ? dictionary[ParseClient.JSONResponseKeys.lastName] as? String : ""
        mapString = dictionary[ParseClient.JSONResponseKeys.mapString] != nil ? dictionary[ParseClient.JSONResponseKeys.mapString] as? String : ""
        mediaURL = dictionary[ParseClient.JSONResponseKeys.mediaURL] != nil ? dictionary[ParseClient.JSONResponseKeys.mediaURL] as? String : ""
        latitude = dictionary[ParseClient.JSONResponseKeys.latitude] != nil ? dictionary[ParseClient.JSONResponseKeys.latitude] as? Double : 0
        longitude = dictionary[ParseClient.JSONResponseKeys.longitude] != nil ? dictionary[ParseClient.JSONResponseKeys.longitude] as? Double : 0
        createdAt = dictionary[ParseClient.JSONResponseKeys.createdAt] != nil ? dictionary[ParseClient.JSONResponseKeys.createdAt] as? String : ""
        updatedAt = dictionary[ParseClient.JSONResponseKeys.updatedAt] != nil ? dictionary[ParseClient.JSONResponseKeys.updatedAt] as? String : ""
    }
    
    
    static func locationsFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        
        for result in results {
            StudentLocations.sharedInstance.studentLocations.append(StudentInformation(dictionary: result))
        }
        return StudentLocations.sharedInstance.studentLocations
    }


    
}
