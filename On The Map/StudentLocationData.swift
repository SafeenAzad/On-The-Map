//
//  StudentLocationData.swift
//  On The Map
//
//  Created by Safeen Azad on 8/29/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import Foundation
import UIKit

struct studentInfo {
    
    var ObjectID: String!
    var UniqueKey: String!
    
    var FirstName : String!
    var LastName : String!
    
    var mapString : String!
    var MediaURL : String!
    
    var Latitude: Double!
    var Longitude: Double!
    
    var updatedAt : String!
    
    init(studentLocationDictionary: [String: AnyObject]) {
        ObjectID = studentLocationDictionary[ParseClient.JSONResponseKeys.ObjectID] as! String
        UniqueKey = studentLocationDictionary[ParseClient.JSONResponseKeys.UniqueKey] as! String
        
        FirstName = studentLocationDictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        LastName = studentLocationDictionary[ParseClient.JSONResponseKeys.LastName] as! String
        
        mapString = studentLocationDictionary[ParseClient.JSONResponseKeys.mapString] as! String
        MediaURL = studentLocationDictionary[ParseClient.JSONResponseKeys.MediaURL] as! String
        
        Latitude = studentLocationDictionary[ParseClient.JSONResponseKeys.Latitude] as! Double
        Longitude = studentLocationDictionary[ParseClient.JSONResponseKeys.Longitude] as! Double
        
       let updatedAtString = studentLocationDictionary[ParseClient.JSONResponseKeys.updatedAt] as! String
        let index = updatedAtString.characters.index(of: "T")
        
        updatedAt = updatedAtString.substring(to: index!)
    }
    
    /* Handle date/time formatting, when applicable */
    func formatDateString(_ dateString: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM-dd-yyyy h:mm", options: 0, locale: Locale(identifier: "en-US"))
        
        if let formattedDate = dateFormatter.date(from: dateString) {
            return formattedDate
        }
        return nil
        
    }
    
    /* Create an array of student location data from results returned by ParseClient */
    static func generateLocationDataFromResults(_ results: [[String : AnyObject]]) -> [studentInfo] {
        var locationDataArray = [studentInfo]()
        
        for result in results {
            
            locationDataArray.append(studentInfo(studentLocationDictionary: result))
            
        }

        return locationDataArray
    }
    
    
}
