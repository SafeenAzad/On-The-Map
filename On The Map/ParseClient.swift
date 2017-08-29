//
//  ParseClient.swift
//  On The Map
//
//  Created by Safeen Azad on 8/29/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import Foundation
import UIKit

class ParseClient: NSObject {
  //  var session: URLSession?
    var studentData: [studentInfo]?
    var lastPostObjectId: String?
    
    /* Task returned for GETting data from the Parse server */
    func taskForGETMethod (_ method: String, parameters: [String : AnyObject]?, queryParameters: [String : AnyObject]?, completionHandler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        var urlString = Constants.baseURLSecure + method
        
        /* If our request includes parameters, add those parameters to our URL */
        if parameters != nil {
            urlString += ParseClient.stringByEscapingParameters(parameters!, queryParameters: queryParameters)
            print(urlString)
        }
        
        
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = HTTPRequest.GET
        request.addValue(Constants.app_id, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.api_key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        
        /*Create a session and then a task */
        let session = URLSession.shared
        let task = session.dataTask(with: (request as URLRequest), completionHandler: { data, response, error in
            if error != nil {
                
                completionHandler(nil, "Could not connect to the network.  Please try again.")
                
            } else {
                
                /* GUARD: Did we get a successful response code of 2XX? */
                self.guardForHTTPResponses(response as? HTTPURLResponse) {proceed, error in
                    if error != nil {
                        
                        completionHandler(nil, error)
                        
                    }
                }
                
                
                /* Parse the results and return in the completion handler with an error if there is one. */
                ParseClient.parseJSONDataWithCompletionHandler(data!, completionHandler: completionHandler)
                
            }
        })
        task.resume()
        return task
    }
    
     /* Task returned for POSTing data from the Parse server */
    func taskForPOSTMethod (_ method: String, JSONBody: [String : AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        let urlString = Constants.baseURLSecure + method
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = HTTPRequest.POST
        request.addValue(Constants.app_id, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.api_key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            
            request.httpBody = try JSONSerialization.data(withJSONObject: JSONBody, options: .prettyPrinted)
        } catch {
            
            request.httpBody = nil
            completionHandler(nil, "An error occured when sending data to the network.")
            
        }
        
        /* Create a session and then a task.  Parse results if no error. */
        let session = URLSession.shared
        
        let task = session.dataTask(with: (request as URLRequest), completionHandler: { data, response, error in
            
            if error != nil {
                
                completionHandler(nil, "Could not connect to the network.  Please try again."
                )
                
            } else {
                
                /* GUARD: Did we get a successful response code in the realm of 2XX? */
                self.guardForHTTPResponses(response as? HTTPURLResponse) {proceed, error in
                    if error != nil {
                        
                        completionHandler(nil, error)
                        
                    }
                }
                
                /* Parse the results and return in the completion handler with an error if there is one. */
                ParseClient.parseJSONDataWithCompletionHandler(data!, completionHandler: completionHandler)
                
            }
        })
        task.resume()
        return task
    }

    /* Update a user's location */
    func taskForPUTMethod(_ method: String, objectId: String, JSONBody : [String : AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        let urlString = ParseClient.Constants.baseURLSecure + method + "/" + objectId
        
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = HTTPRequest.PUT
        request.addValue(Constants.app_id, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.api_key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            
            request.httpBody = try JSONSerialization.data(withJSONObject: JSONBody, options: .prettyPrinted)
            
        } catch {
            request.httpBody = nil
            completionHandler(nil, "An error occured when sending data to the network.")
            
        }
        
        /*Create a session and then a task.  Parse results if no error. */
        let session = URLSession.shared
        
        let task = session.dataTask(with: (request as URLRequest), completionHandler: { data, response, error in
            
            if error != nil {
                
                completionHandler(nil, "Could not connect to the network.  Please try again.")
                
            } else {
                
                /* GUARD: Did we get a successful response code of 2XX? */
                self.guardForHTTPResponses(response as? HTTPURLResponse) {proceed, error in
                    if error != nil {
                        
                        completionHandler(nil, error)
                        
                    }
                }
                
                /* Parse the results and return in the completion handler with an error if there is one. */
                ParseClient.parseJSONDataWithCompletionHandler(data!, completionHandler: completionHandler)
                
            }
        })
        task.resume()
        return task
        
    }

    /* Helper Function: Convert JSON to a Foundation object */
    class func parseJSONDataWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: String?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            completionHandler(nil, "An error occured while getting data from the network.")
        }
        
        completionHandler(parsedResult, nil)
    }
    
    /* Helper Function: Given an optional dictionary of parameters and an optional dictionary of query parameters, convert to a URL encoded string */
    class func stringByEscapingParameters(_ parameters: [String : AnyObject]?, queryParameters: [String : AnyObject]?) -> String {
        print(parameters!)
        var components = [String]()
        
        
        if parameters != nil {
            components.append(URLString(fromParameters: parameters!, withSeperator: ":"))
        }
        
        if queryParameters != nil {
            components.append(URLString(fromParameters: queryParameters!, withSeperator: "="))
        }
        
        return (!components.isEmpty ? "?" : "") + components.joined(separator: "&")
        
    }

    class func URLString(fromParameters parameters: [String : AnyObject], withSeperator seperator: String) -> String {
        var queryComponents = [(String, String)]()
        
        for (key, value) in parameters {
            queryComponents += recursiveURLComponents(key, value)
        }
        
        return (queryComponents.map {"\($0)\(seperator)\($1)" } as [String]).joined(separator: "&")
        
    }
    
    class func recursiveURLComponents(_ keyString : String, _ parameters: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let parameterDict = parameters as? [String : AnyObject] {
            for (key, value) in parameterDict {
                components += recursiveURLComponents("\(keyString)[\(key)]", value)
            }
        } else if let parameterArray = parameters as? [AnyObject] {
            for parameter in parameterArray {
                components += recursiveURLComponents("\(keyString)[]", parameter)
            }
            
        } else {
            components.append((escapedString(keyString), escapedString("\(parameters)")))
        }
        return components
    }

    class func escapedString(_ string: String) -> String {
        let escapedString = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        return escapedString!
    }
    
    func DictionaryForPostLocation(_ mediaURL: String, mapString: String) -> [String : AnyObject]{
        let dictionary: [String : AnyObject] = [
            ParseClient.JSONResponseKeys.UniqueKey : UdacityClient.sharedInstance().IDKey! as AnyObject,
            ParseClient.JSONResponseKeys.FirstName : UdacityClient.sharedInstance().firstName! as AnyObject,
            ParseClient.JSONResponseKeys.LastName : UdacityClient.sharedInstance().lastName! as AnyObject,
            ParseClient.JSONResponseKeys.Latitude : UdacityClient.sharedInstance().latitude! as AnyObject,
            ParseClient.JSONResponseKeys.Longitude : UdacityClient.sharedInstance().longitude! as AnyObject,
            ParseClient.JSONResponseKeys.mapString : mapString as AnyObject,
            ParseClient.JSONResponseKeys.MediaURL : mediaURL as AnyObject
        ]
        return dictionary
    }

/* Singleton shared instance of ParseClient */
class func sharedInstance() -> ParseClient {
    struct Singleton {
        static var sharedInstance = ParseClient()
    }
    return Singleton.sharedInstance
}

/* Abstraction of repetive guard statements in each request function */
func guardForHTTPResponses(_ response: HTTPURLResponse?, completionHandler: (_ proceed: Bool, _ error: String?) -> Void) -> Void {
    /* GUARD: Did we get a successful response code of 2XX? */
    guard let statusCode = response?.statusCode, statusCode >= 200 && statusCode <= 299 else {
        var statusError: String?
        
        /* IF not, what was our status code?  Provide appropriate error message and return */
        if let response = response {
            if response.statusCode >= 400 && response.statusCode <= 599 {
                statusError = "The network returned an invalid response.  Please re-enter your credentials and try again."
            }
        } else {
            statusError = "Invalid response from the server. Please make sure your username and password are correct and try again."
        }
        completionHandler(false, statusError)
        return
    }
    completionHandler(true, nil)
}

/* Shared date formatter for Parse Client dates returned */
class var sharedDateFormatter: DateFormatter {
    struct Singleton {
        static let dateFormatter = Singleton.generateDateFormatter()
        
        static func generateDateFormatter() -> DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-mm-dd"
            
            return formatter
        }
    }
    return Singleton.dateFormatter
}
    
}
