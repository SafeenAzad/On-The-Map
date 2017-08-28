//
//  ExtendsUIViewController.swift
//  On The Map
//
//  Created by Safeen Azad on 8/28/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import UIKit

extension UIViewController{
    
    /* Helper - Create an alert controller with an array of callback handlers   */
    func alertController(withTitles titles: [String], message: String, callbackHandler: [((UIAlertAction)->Void)?]) {
        
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        
        for title in titles.enumerated() {
            
            if let callbackHandler = callbackHandler[title.offset] {
                
                let action = UIAlertAction(title: title.element, style: .default, handler: callbackHandler)
                
                alertController.addAction(action)
                
            } else {
                
                let action = UIAlertAction(title: title.element, style: .default, handler: nil)
                
                alertController.addAction(action)
                
            }
            
            
            
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
}
