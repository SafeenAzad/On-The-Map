//  ListTableViewController.swift
//  On The Map
//
//  Created by Safeen Azad on 8/29/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Add refresh control, which is activated when pulling down on the tableview */
        self.refreshControl?.addTarget(self, action: #selector(ListTableViewController.refreshDataFromParse(_:)), for: .valueChanged)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ParseClient.sharedInstance().studentData != nil {
            
            tableView.reloadData()
            
        } else {
            
            refreshDataFromParse(self)
            
        }
    }
    @IBAction func refreshDataFromParse(_ sender: Any) {
        
        indicatorView.startAnimating()
        
        ParseClient.sharedInstance().getMostRecentDataFromParse({ success, results, error in
            
            if success {
                self.GlobalMainQueue.async(execute: {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    self.indicatorView.stopAnimating()
                })
            } else {
                self.GlobalMainQueue.async(execute: {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    self.alertController(withTitles: ["OK", "Retry"], message: "There is an error.", callbackHandler: [nil, {Void in
                        self.refreshDataFromParse(self)
                        }])
                    
                })
                
            }
            
        })
        
        
    }
///////////////////////////////////////////
    var GlobalMainQueue: DispatchQueue { //
        return DispatchQueue.main        //
    }                                    //
///////////////////////////////////////////
}

extension ListTableViewController {
    
    /* Open link if it is valid, or else notify user */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sharedApplication = UIApplication.shared
        
        if ParseClient.sharedInstance().studentData != nil {
            
            if let urlString = ParseClient.sharedInstance().studentData![indexPath.row].MediaURL {
                
                if let URL = URL(string: urlString) {
                    if #available(iOS 10.0, *) {
                        sharedApplication.open(URL , options: [:], completionHandler: { success in
                            if !success {
                                print("Invalid Link.")
                            }
                        })
                    } else {
                        // Fallback on earlier versions
                    }
                } else {
                    GlobalMainQueue.async(execute: {
                        self.alertController(withTitles: ["Ok"], message: "The link is not valid.  Please try again.", callbackHandler: [nil])
                    })
                    
                }
                
            }
            
        }
    }
    
    /* Create and return the tableview cell */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! locationTableViewCell
        
        if ParseClient.sharedInstance().studentData != nil {
            let data = ParseClient.sharedInstance().studentData![indexPath.row]
            
            cell.mainTextLabel.text = "\(data.FirstName) \(data.LastName)"
            cell.urlTextLabel.text = "\(data.MediaURL)"
            cell.geoTextLabel.text = "From: \(data.mapString) on: \(data.mapString)"
            
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ParseClient.sharedInstance().studentData != nil {
            return ParseClient.sharedInstance().studentData!.count
        } else {
            return 0
        }
    }
    
    
    
} // end extension
