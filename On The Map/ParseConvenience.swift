//
//  ParseConvenience.swift
//  On The Map
//
//  Created by Safeen Azad on 8/29/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import Foundation

extension ParseClient {
    
    /* Get the most recent 100 results from Parse, Parse it and return in completion handler to be used. */
    func getMostRecentDataFromParse(_ completionHandler: @escaping (_ success: Bool, _ data: [studentInfo]?, _ error: String?)->Void) {
        
        let parameters: [String :AnyObject] = [ParseClient.ParameterKeys.limit : 100 as AnyObject, ParseClient.ParameterKeys.Order : "-\(ParseClient.JSONResponseKeys.updatedAt)" as AnyObject]
        
       let _ = taskForGETMethod(Methods.StudentLocations, parameters: parameters, queryParameters: nil){ JSONResult, error in
            if let error = error {
                
                completionHandler(false, nil, error)
                
            } else {
                
                /* If results are returned and we are able to parse the data, return it as an array of studentData */
                if let results = JSONResult?.value(forKey: ParseClient.JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    
                    let studentData = studentInfo.generateLocationDataFromResults(results)
                    
                    self.studentData = studentData
                    
                    completionHandler(true, self.studentData, nil)
                }
                
            }
        }
    }
    
    /* Either update object of post new if no objectId returned when querying */
    func postDataToParse(_ JSONBody: [String : AnyObject], completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        if lastPostObjectId != nil {
            
           let _ = taskForPUTMethod(ParseClient.Methods.StudentLocations, objectId: lastPostObjectId!, JSONBody: JSONBody, completionHandler: {success, error in
                
                if error != nil {
                    
                    completionHandler(false, error)
                    
                    
                } else {
                    
                    completionHandler(true, nil)
                    
                }
                
            })
            
        } else {
            
           let _ = ParseClient.sharedInstance().taskForPOSTMethod(ParseClient.Methods.StudentLocations, JSONBody: JSONBody, completionHandler: {success, error in
                
                if error != nil {
                    
                    completionHandler(false, error)
                    
                } else {
                    completionHandler(true, nil)
                    
                }
                
            })
            
        }
        
}
    
    /* Get data from Parse based on a query, limiting to the most recent post by you. */
    func queryParseDataForLastSubmission(_ completionHandler: @escaping (_ success: Bool, _ results: studentInfo?, _ error: String?) -> Void) {
        
        /* Limit to only the most recent submission, orderered by update time. */
        let parameters: [String : AnyObject] = [
            ParseClient.ParameterKeys.Order : "-\(ParseClient.JSONResponseKeys.updatedAt)" as AnyObject
        ]
        
        let queryParameters: [String : AnyObject] = ([ParseClient.QueryArguments.Where : [ParseClient.JSONResponseKeys.UniqueKey : UdacityClient.sharedInstance().IDKey!]] as AnyObject) as! [String : AnyObject]
        
        let _ = taskForGETMethod(ParseClient.Methods.StudentLocations, parameters: parameters, queryParameters: queryParameters, completionHandler: {results, error in
            
            /* If there was an error parsing, return an error */
            if error != nil {
                
                completionHandler(false, nil, error)
                
            } else {
                
                /* If results were returned, drill into the most recent objectId and return it */
                if let results = results?[ParseClient.JSONResponseKeys.Results] as? [[String : AnyObject]] {
                    
                    let studentDataArray = studentInfo.generateLocationDataFromResults(results)
                    
                    /* Ensure we have exactly on set of results and that it's the most recent */
                    let result = studentDataArray[0]
                    print(result)
                    /* Set shared instance's lastPostObjectId to update location */
                    self.lastPostObjectId = result.ObjectID
                    completionHandler(true, result, nil)
                    
                } else {
                    
                    completionHandler(false, nil, "An error occured while getting data from the network.")
                    
                }
            }
            
        })
        
    }
    
    
    
    
    
}
