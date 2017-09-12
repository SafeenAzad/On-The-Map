//
//  ParseClient.swift
//  On The Map
//
//  Created by Safeen Azad on 8/29/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import Foundation
import MapKit

class ParseClient: NSObject {
    
    static let sharedInstance = ParseClient()
    
    var session = URLSession.shared
    var requestToken: String? = nil
    var objectID: String? = nil
    var sessionID: String? = nil
    var userID: String? = nil
    var uniqueKey: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var annotations = [MKPointAnnotation]()
    
    
    override init() {
        super.init()
    }
    
    /* Task returned for GETting data from the Parse server */
    func taskForGETStudentLocations (withUniqueKey: String?, completionHandler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        var request:NSMutableURLRequest!
        if withUniqueKey != nil {
            request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(withUniqueKey)%22%7D")!)
        } else {
            request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
        }
        
        
        
        
        request.httpMethod = HTTPRequest.GET
        request.addValue(ParseParameterValues.appID, forHTTPHeaderField: HTTPHeaderField.parseAppID)
        request.addValue(ParseParameterValues.apiKey, forHTTPHeaderField: HTTPHeaderField.parseRestApiKey)
        
        let task = session.dataTask(with: request as URLRequest){ (data, response, error) in
            
            if error != nil {
                
                completionHandler(nil, "Could not connect to the network.  Please try again."
                )
                
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                completionHandler(nil, "Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                print("Could not find the data")
                return
                
            }
            let range = Range(uncheckedBounds: (5, data.count))
            let newData = data.subdata(in: range)
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            self.convertData(newData, completionHandlerForConvertData: completionHandler)
            
        }
        
        task.resume()
        return task
    }
    
     /* Task returned for POSTing data from the Parse server */
    func taskForPOSTSession (jsonBody: [String : AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        let userInfo = [JSONBodyKeys.udacityKey:jsonBody]
        var info: Data!
        do{
            info = try JSONSerialization.data(withJSONObject: userInfo, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            print("Cannot encode the data")
        }

        let method = Methods.session
        let urlString = Constants.getSessionURL + method
        let sessionURL = URL(string: urlString)
        let request = NSMutableURLRequest(url: sessionURL!)
        
        request.httpMethod = HTTPRequest.POST
        request.addValue(Constants.applicationJSON, forHTTPHeaderField: HTTPHeaderField.acceptField)
        request.addValue(Constants.applicationJSON, forHTTPHeaderField: HTTPHeaderField.contentType)
        request.httpBody = info
        
       
        let task = session.dataTask(with: request as URLRequest){ (data, response, error) in
            
            if error != nil {
                
                completionHandler(nil, "Could not connect to the network.  Please try again."
                )
                
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                completionHandler(nil, "Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                print("Could not find the data")
                return

            }
            let range = Range(uncheckedBounds: (5, data.count))
            let newData = data.subdata(in: range)
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            self.convertData(newData, completionHandlerForConvertData: completionHandler)
            
            }
        
        task.resume()
        return task
    }
    
    func taskForDeleteSession (_ method: String, completionHandler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
    
        let urlString = Constants.getSessionURL + method
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = HTTPRequest.DELETE
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                completionHandler(nil, "There is an error.")
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("The status code is not in order of 2xx")
                return
            }
            
            print (statusCode)
            
            guard let data = data else {
                print("Cannot find the data")
                return
            }
            
            let range = Range(uncheckedBounds: (5, data.count))
            let newData = data.subdata(in: range)
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            self.convertData(newData, completionHandlerForConvertData: completionHandler)
        }
        
        task.resume()
        return task

    }
      func taskForPOSTStudentLocation(jsonBody : [String : AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        let userInfo = jsonBody
        var info: Data!
        do{
            info = try JSONSerialization.data(withJSONObject: userInfo, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            print("Cannot encode the data")
        }
        
        let request = NSMutableURLRequest(url: parseURLFromParameters([:],withPathExtension: nil))
        request.httpMethod = HTTPRequest.POST
        request.addValue(HTTPHeaderField.parseAppID, forHTTPHeaderField: ParseParameterValues.apiKey)
        request.addValue(HTTPHeaderField.parseRestApiKey, forHTTPHeaderField:ParseParameterValues.appID)
        request.addValue(Constants.applicationJSON, forHTTPHeaderField: HTTPHeaderField.contentType)
        request.httpBody = info
        
        let task = session.dataTask(with: request as URLRequest) {(data,response,error) in

            if error != nil {
                
                completionHandler(nil, "There is an error.")
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("The status code is not in order of 2xx")
                return
            }
            
            print(statusCode)
            guard let data = data else {
                print("Could not find the data")
                return
            }
            
            let range = Range(uncheckedBounds: (5, data.count))
            let newData = data.subdata(in: range)
            self.convertData(newData, completionHandlerForConvertData: completionHandler)
            
        }
        task.resume()
        return task

    }
    func taskForGETUsersData(completionHandler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) {
        
        let urlString = Constants.getSessionURL + Methods.users+"/\(userID!)"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
            
                completionHandler(nil, "There was an error with the request")
            }else {
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    print("The status code is not in order of 2xx")
                    return

                }
                print(statusCode)
                guard let data = data else {
                    print("Cannot find the user's data")
                    return
                }
                
                let range = Range(uncheckedBounds: (5,data.count))
                let newData = data.subdata(in: range)
                print(NSString(data:newData, encoding:String.Encoding.utf8.rawValue)!)
                self.convertData(newData, completionHandlerForConvertData: completionHandler)
            }
        }
        task.resume()
    }
    
    
    func taskForPUTStudentLocation(jsonBody:[String:AnyObject], method:String, completionHandler: @escaping(_ results:AnyObject?,_ error: String?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: parseURLFromParameters([:], withPathExtension: method))
        request.httpMethod = HTTPRequest.PUT
        let userInfo = jsonBody
        var info: Data!
        do{
            info = try JSONSerialization.data(withJSONObject: userInfo, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            print("Cannot encode the data")
        }
        request.addValue(HTTPHeaderField.parseAppID, forHTTPHeaderField: ParseParameterValues.apiKey)
        request.addValue(HTTPHeaderField.parseRestApiKey, forHTTPHeaderField: ParseParameterValues.appID)
        request.addValue(Constants.applicationJSON, forHTTPHeaderField: HTTPHeaderField.contentType)
        request.httpBody = info
        
        let task = session.dataTask(with: request as URLRequest) {(data, response, error) in
            
            if error != nil {
                completionHandler(nil, "There was an error puting the data.")
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("The status code is not in order of 2xx")
                return
            }
            
            print(statusCode)
            guard let data = data else {
                print("Cannot find the data")
                return
            }
            
            let range = Range(uncheckedBounds: (5,data.count))
            let newData = data.subdata(in: range)
            completionHandler(newData as AnyObject,nil)
            self.convertData(newData, completionHandlerForConvertData: completionHandler)
        }
        
        task.resume()
        return task
    }

    func taskForGETMethod(_ method: String, parameters: [String:AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        var parameters = parameters
        
        let request = NSMutableURLRequest(url: parseURLFromParameters(parameters, withPathExtension: method))
        request.addValue(ParseParameterValues.appID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseParameterValues.apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, "There was an error getting the data.")
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            self.convertData(data, completionHandlerForConvertData: completionHandler)
        }
        task.resume()
        return task
    }

    
    
    func parseURLFromParameters(_ parameters: [String: AnyObject], withPathExtension:String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.apiScheme
        components.host = Constants.apiHost
        components.path = Constants.apiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        print(components.url!)
        return components.url!
    }
    
    private func convertData(_ data: Data, completionHandlerForConvertData: (_ result:AnyObject?,_ error: String?) -> Void) {
        var parsedData:AnyObject!
        do {
            parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            if JSONSerialization.isValidJSONObject(parsedData) {
                completionHandlerForConvertData(parsedData, nil)
            }
        } catch {
            completionHandlerForConvertData(nil, "Cannot parse the \(data) into json Format")
        }
        completionHandlerForConvertData(parsedData,nil)
    }

}
