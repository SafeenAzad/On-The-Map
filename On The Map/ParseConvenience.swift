//
//  ParseConvenience.swift
//  On The Map
//
//  Created by Safeen Azad on 8/29/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import Foundation

extension ParseClient {
    
    
    func getStudentLocations(_ completionHandler: @escaping (_ result: [StudentInformation]?, _ error: String?) -> Void) {
        
        let parameters = [ParseParameterKeys.limit: ParseParameterValues.limit,
                          ParseParameterKeys.order:ParseParameterValues.order]
        
        let methods: String = Methods.studentLocations
        
        let _ = taskForGETMethod(methods, parameters: parameters as [String : AnyObject]) { (results, error) in
            
            if let error = error {
                
                completionHandler(nil, error)
            } else {
                if let results = results?[JSONResponseKeys.results] as? [[String:AnyObject]] {
                    let students = StudentInformation.locationsFromResults(results)
                    print(results)
                    for result in results {
                        if let userID = result[JSONResponseKeys.uniqueKey] as? String , userID == self.userID {
                            guard let firstName = result[JSONResponseKeys.firstName] as? String else {
                                print("Cannot find key 'firstName' in \(results)")
                                return
                            }
                            guard let lastName = result[JSONResponseKeys.lastName] as? String else {
                                print("Cannot find key 'lastName' in \(results)")
                                return
                            }
                            guard let objectID = result[JSONResponseKeys.objectID] as? String else {
                                print("Cannot find key 'objectID' in \(results)")
                                return
                            }
                            self.firstName = firstName
                            self.lastName = lastName
                            self.objectID = objectID
                        }
                    }
                    
                    completionHandler(students, nil)
                } else {
                    
                    completionHandler(nil, "Could not parse getStudentLocations")
                }
            }
        }
    }
    
    ///Method for posting session to server
    func PostSession(userName: String, password: String, completionHandler:@escaping(_ success: Bool, _ result:AnyObject?,_ error:String?)-> Void) {
        let dictionary = [JSONBodyKeys.userNameKey: userName,
                          JSONBodyKeys.passwordKey: password]
        
        _ = taskForPOSTSession(jsonBody: dictionary as [String : AnyObject]) {(results, error) in
            if error != nil {
                completionHandler(false, nil, error)
            } else {
                if let sessionResults = results as? [String:AnyObject] {
                    if let accounts = sessionResults[JSONResponseKeys.account] as? [String:AnyObject] {
                        if let userID = accounts[JSONResponseKeys.key] as? String {
                            ParseClient.sharedInstance.userID = userID
                            print ("UserID = \(userID)")
                        }
                    }
                    
                    if let session = sessionResults[JSONResponseKeys.session] as? [String:AnyObject] {
                        if let sessionID = session[JSONResponseKeys.sessionId] as? String {
                            ParseClient.sharedInstance.sessionID = sessionID
                            print ("Session ID = \(sessionID)")
                        }
                    }
                    
                    completionHandler(true, sessionResults as AnyObject,nil)
                } else {
                    completionHandler(false, nil, "Could not parse the data")
                }
            }
        }
    }
    
    
    ///Method for deleting session ID when logout
    func DeleteSession(completionHandler: @escaping(_ results: AnyObject?,_ error: String?) -> Void) {
        
        let methodString = Methods.session
        
        _ = taskForDeleteSession(methodString) { (results, error) in
            
            if error != nil {
                completionHandler(nil, error)
            } else {
                if let results = results {
                    completionHandler(results, nil)
                } else {
                    completionHandler(nil, "Couldn't parse the data")
                }
            }
        }
    }
    
    func PostStudentLocation(json: [String:AnyObject],completionHandler:@escaping(_ results: AnyObject?,_ error: String?) -> Void) {
        
        let httpBody = json
        
        _ = taskForPOSTStudentLocation(jsonBody: httpBody) {(results, error) in
            
            if error != nil {
                completionHandler(nil, error)
            } else {
                if let results = results as? [String:AnyObject] {
                    if let objectID = results[JSONResponseKeys.objectID] as? String {
                        ParseClient.sharedInstance.objectID = objectID
                        print ("Object ID = \(objectID)")
                    }
                    completionHandler(results as AnyObject?, nil)
                } else {
                    completionHandler(nil, "Could not parse the data")
                }
            }
        }
    }
    
    ///Method for getting public user's data
    func GetPublicUserData(completionHandler: @escaping(_ results: AnyObject?,_ error:String?) -> Void) {
        
        taskForGETUsersData() {(results,error) in
            
            if error != nil {
                completionHandler(nil, error)
            } else {
                if let resultDictionary = results as? [String : AnyObject] {
                    if let userDictionary = resultDictionary["user"] as? [String : AnyObject] {
                        
                        if let firstName = userDictionary["nickname"] as? String {
                            ParseClient.sharedInstance.firstName = firstName
                        }
                        if let lastName = userDictionary["last_name"] as? String {
                            ParseClient.sharedInstance.lastName = lastName
                        }
                        
                        completionHandler(results, nil)
                    }
                } else {
                    completionHandler(nil, "Could not parse the data")
                }
            }
        }
    }
    
    func OverwriteStudentLocation(json: [String:AnyObject], completionHandler: @escaping(_ results:AnyObject?,_ error: String?) -> Void) {
        let methodString = "/\(ParseClient.sharedInstance.objectID)"
        
        let httpBody = json
        
        _ = taskForPUTStudentLocation(jsonBody: httpBody, method: methodString) {(results,error) in
            
            if error != nil {
                completionHandler(nil, error)
            } else {
                if let results = results {
                    completionHandler(results, nil)
                } else {
                    completionHandler(nil, "Cannot parse the data")
                }
            }
        }
    }

    
    
    
}
