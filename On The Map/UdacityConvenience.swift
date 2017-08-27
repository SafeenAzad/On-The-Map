//
//  Convenience.swift
//  On The Map
//
//  Created by Safeen Azad on 8/26/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.

import Foundation

extension UdacityClient{
    
    func authenticateWithViewController(_ parameters: [String : AnyObject], completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void){
        /* get the session id */
        
        getSession(parameters) { success, sessionID, IDKey, error in
            if success {
                
                self.sessionID = sessionID
                self.IDKey = IDKey
                print(IDKey!)
                completionHandler(true, nil)
            } else {
                
                completionHandler(false, "error")
            }
        }
    }
    func getSession(_ parameters: [String : AnyObject]?, completionHandler: @escaping (_ success: Bool, _ sessionID: String?, _ userKey: String?, _ error: String?) -> Void) {
        /* Check for success */
        
        
        taskForPOSTMethod(UdacityClient.Methods.Session, parameters: parameters!) { JSONResult, error in
            if let error = error {
                
                completionHandler(false, nil, nil, "There is an error.")
                
            } else {
                /* Attempt to get the session ID */
                if let session = JSONResult?.value(forKey: UdacityClient.JSONResponseKeys.Session) {
                    
                    if let sessionID = (session as AnyObject).value(forKey: UdacityClient.JSONResponseKeys.SessionID) as? String {
                        
                        /* get the account and user from JSONResult */
                        if let account = JSONResult?[UdacityClient.JSONResponseKeys.Account]  {
                            
                            if let IDKey = (account as AnyObject)[UdacityClient.JSONResponseKeys.IDKey] as? String {
                                
                                completionHandler(true, sessionID, IDKey, nil)
                                
                            }
                        }
                    }
                }
            }
        }
    }
    /* Get the user's data */
    func getUserData(_ completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        /* Make request and check for success */
        
        
        guard let IDKey = IDKey else {
            
            completionHandler(false, "An error occured.  Please try again.")
            return
        }
        
        let method = UdacityClient.substituteKeyInMethod(UdacityClient.Methods.GetUserData, key: "id", value: IDKey)
        
        taskForGETMethod(method!, parameters: [:]) {JSONResult, error in
            
            if error != nil {
                completionHandler(false, "error")
                
            } else {
                
                /* If user data found, parse the results */
                if let result = JSONResult?[UdacityClient.JSONResponseKeys.User] {
                    print(result!)
                    if let firstName = (result as AnyObject)[UdacityClient.JSONResponseKeys.FirstName] as? String {
                        self.firstName = firstName
                        
                        if let lastName = (result as AnyObject)[UdacityClient.JSONResponseKeys.LastName] as? String{
                            self.lastName = lastName
                            
                            /* Return with completion handler */
                            completionHandler(true, nil)
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
    }

    func logoutOfSession(_ completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        /* call task for delete method to log user out */
        taskForDELETEMethod(Methods.Session) { result, error in
            
            if error != nil {
                
                completionHandler(false, "An error occured while trying to logout.")
                
            } else {
                completionHandler(true, nil)
            }
        }
    }
} //End extension
