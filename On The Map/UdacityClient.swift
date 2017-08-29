//
//  UdacityClient.swift
//  On The Map
//
//  Created by Safeen Azad on 8/26/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import UIKit

class UdacityClient: NSObject {
    
    var IDKey: String? = nil
    var sessionID: String? = nil
    var firstName:String? = nil
    var lastName:String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    var mapString: String? = nil
    var mediaURL: String? = nil
    var imageURL: String? = nil

    var session: URLSession
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    /* Task for GETting data from Udacity */
    func taskForGETMethod(_ method: String, parameters: [String : AnyObject]?, completionHandler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        /* Build the URL, using parameters if there are any */
        var urlString = Constants.BaseURLSecure + method
        
        if let parameters = parameters {
            
            urlString += UdacityClient.stringByEscapingParameters(parameters, queryParameters: nil)
            
        }
        
        let url = URL(string: urlString)
        
        /* Make the request */
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = UdacityClient.HTTPRequest.GET
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            /* Guard for an error connecting to network */
            guard error == nil else {
                completionHandler(nil, "Could not connect to the network.  Please try again.")
                return
            }
            
            self.guardForHTTPResponses(response as? HTTPURLResponse) {proceed, error in
                if error != nil {
                    
                    completionHandler(nil, "error")
                    
                }
            }
            
            /* Make sure the data is parsed before returning it */
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            UdacityClient.parseJSONDataWithCompletionHandler(newData!, completionHandler: completionHandler)
            
            completionHandler(data as AnyObject, nil)
            
        })
        task.resume()
        return task
    }
    
    /* Task for POSTing data */
    func taskForPOSTMethod(_ method: String, parameters: [String : AnyObject]?, completionHandler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        /* Build the URL */
        let urlString = Constants.BaseURLSecure + method
        let url = URL(string: urlString)
        
        /* Construct the request */
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters!, options: .prettyPrinted)
        } catch {
            request.httpBody = nil
            
            completionHandler(nil, "An error occured while getting data from the network.")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            /* GUARD: was there an error? */
            guard error == nil else {
                completionHandler(nil, "Could not connect to the network.  Please try again.")
                return
            }
            
            
            /* GUARD: Did we get a successful response code of 2XX? */
            self.guardForHTTPResponses(response as? HTTPURLResponse) {proceed, error in
                if error != nil {
                    
                    completionHandler(nil, "error")
                    
                }
            }
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            UdacityClient.parseJSONDataWithCompletionHandler(newData!, completionHandler: completionHandler)
        })
        
        task.resume()
        
        return task
    }
    
    /* Delete (logout) a session */
    func taskForDELETEMethod(_ method: String, completionHandler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        /* Configure URL */
        let urlString = Constants.BaseURLSecure + method
        let url = URL(string: urlString)
        
        /* Make the request */
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = UdacityClient.HTTPRequest.DELETE
        
        /* MMM.. Cookies*/
        var xsrfCookie: HTTPCookie? = nil
        
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        if let cookies = sharedCookieStorage.cookies as [HTTPCookie]! {
            
            for cookie in cookies {
                
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
                
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            /* GUARD: was there an error? */
            guard error == nil else {
                
                completionHandler(nil, "Could not connect to the network.  Please try again.")
                return
            }
            
            
            /* GUARD: Did we get a successful response code of 2XX? */
            self.guardForHTTPResponses(response as? HTTPURLResponse) {proceed, error in
                if error != nil {
                    
                    completionHandler(nil, "error")
                    
                }
            }
            
            
            UdacityClient.parseJSONDataWithCompletionHandler(data!, completionHandler: completionHandler)
            
        })
        task.resume()
        return task
    }
    
    
    class func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    
    class func parseJSONDataWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: String?) -> Void) {
        
        var parsedResult: Any!
        do {
            
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
        } catch {
            completionHandler(nil, "There is an error while parsing the result.")
        }
        print("Parsed result: \(parsedResult)")
        completionHandler(parsedResult as AnyObject, nil)
    }
    
    /*  Given an optional dictionary of parameters and an optional dictionary of query parameters, convert to a URL encoded string */
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
    /* Helper function, takes a string as an argument and returns an escaped version of it to be sent in an HTTP Request */
    class func escapedString(_ string: String) -> String {
        let escapedString = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        return escapedString!
    }
    
    /* Abstraction of repetive guard statements in each request function */
    func guardForHTTPResponses(_ response: HTTPURLResponse?, completionHandler: (_ proceed: Bool, _ error: String?) -> Void) -> Void {
        /* GUARD: Did we get a successful response code of 2XX? */
        guard let statusCode = response?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            
            print("Status code is not 2xx")
            
            completionHandler(false, "Account not found or invalid credentials.")
            return
        }
        
        
        completionHandler(true, nil)
    }
    
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            
            static var sharedInstance = UdacityClient()
            
        }
        
        return Singleton.sharedInstance
    }
    
    
}
