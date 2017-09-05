//  PostLocationViewController.swift
//  On The Map
//
//  Created by Safeen Azad on 9/5/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import UIKit
import MapKit

class PostLocationViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var Find: UIButton!
    
    let coordinateSpan = MKCoordinateSpan()
    let regionRadius: CLLocationDistance = 1000
    
    
    var isSubmittingURL = false
    var locationStringToPost: String? = nil
    var mediaURLToPost: String? = nil
    
    
///////////////////////////////////////////
    var GlobalMainQueue: DispatchQueue { //
        return DispatchQueue.main        //
    }                                    //
///////////////////////////////////////////
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkTextField.delegate = self
        locationTextField.delegate = self
        
        mapView.delegate = self
        
    }
    
    func queryParseForResults() {
        ParseClient.sharedInstance().queryParseDataForLastSubmission({success, results, error in
            
            if success {
                
                self.GlobalMainQueue.async(execute: {
                    
                    /* Show alert controller showing that you're about to overwrite the recently submitted location */
                    self.alertController(withTitles: ["OK", "Cancel"], message: "You have already submitted your location.  Press OK to update it, or Cancel to go back.", callbackHandler: [nil, {Void in
                        self.didTapCancelButton(self)
                        }])
                    
                    /* Update UI to show last submitted location */
                    self.locationStringToPost = results!.mapString
                    self.mediaURLToPost = results!.MediaURL
                    self.linkTextField.text = self.mediaURLToPost
                    self.locationTextField.text = self.locationStringToPost
                    
                })
                
            }
        })
        
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSubmitButton(_ sender: Any) {
        
        /* If user is submitting a location and it is not nil, verify the location */
        if isSubmittingURL == false {
            
            guard locationTextField.text != nil else {
                alertController(withTitles: ["OK"], message:  "Missing something.  Please make sure all text fields are filled out appropriately.", callbackHandler: [{Void in return}])
                return
            }
            
            /* Verify the location and get rid of activity indicator when complete */
            self.verifyLocation(self.locationTextField.text!, completionCallback: {success, error in
                
                if error != nil {
                    
                    /* Alert if unable to geocode location */
                    self.alertController(withTitles: ["Ok"], message: "There is an error.", callbackHandler: [nil])
                    
                }
            })
        }else {
            /* Once location is verified, go ahead and submit the location and URL as long as URL is valid */
            guard linkTextField.text != nil else {
                alertController(withTitles: ["OK"], message: "Missing something.  Please make sure all text fields are filled out appropriately.", callbackHandler: [nil])
                return
            }
            mediaURLToPost = linkTextField.text
            
            /* GUARD : Do we have a valid URL? */
            guard let _ = URL(string: mediaURLToPost!) else {
                alertController(withTitles: ["Try Again"], message: "The link is not valid.  Please try again.", callbackHandler: [{Void in
                    self.mediaURLToPost = nil
                    self.isSubmittingURL = true
                    }])
                return
                
            }
            
            postLocationAndURLToParse()
            
        }
        
    }
    
    /* Post location and URL to Parse */
    func postLocationAndURLToParse() {
        
        
        let JSONBody = ParseClient.sharedInstance().DictionaryForPostLocation(mediaURLToPost!, mapString: locationStringToPost!)
        
        
        ParseClient.sharedInstance().postDataToParse(JSONBody, completionHandler: {success, error in
            
            if success {
                self.GlobalMainQueue.async(execute: {
                    
                    ParseClient.sharedInstance().studentData  = nil
                    
                    self.dismiss(animated: true, completion: nil)
                    
                })
                
            } else {
                
                /* Hide the activity indicator and show alert */
                self.GlobalMainQueue.async(execute: {
                    
                    self.alertController(withTitles: ["Cancel", "Try Again"], message: "There is an error.", callbackHandler: [{Void in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                        }, {Void in
                            
                            self.postLocationAndURLToParse()
                            
                        }])
                    
                })
                
            }
            
        })
        
        
    }
    
    /* Verify that the location is geocoded properly */
    func verifyLocation(_ locationString: String, completionCallback: @escaping (_ success: Bool, _ error: String?)-> Void){
        let geocoder = CLGeocoder()
        
        GlobalMainQueue.async(execute: {
            
            geocoder.geocodeAddressString(locationString, completionHandler: { placemarks, error in
                
                if placemarks != nil {
                    
                    self.locationStringToPost = locationString
                    
                    
                    let selectedPlacemark = placemarks![0]
                    
                    self.isSubmittingURL = true
                    self.configureDisplay(false)
                    
                    
                    UdacityClient.sharedInstance().latitude = CLLocationDegrees(selectedPlacemark.location!.coordinate.latitude)
                    UdacityClient.sharedInstance().longitude = CLLocationDegrees(selectedPlacemark.location!.coordinate.longitude)
                    
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: selectedPlacemark.location!.coordinate.latitude, longitude: selectedPlacemark.location!.coordinate.longitude)
                    
                    
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(selectedPlacemark.location!.coordinate, self.regionRadius * 2.0, self.regionRadius * 2.0)
                    
                    self.mapView.setRegion(coordinateRegion, animated: true)
                    
                    self.mapView.addAnnotation(annotation)
                    
                    completionCallback(true, nil)
                    
                } else {
                    
                    completionCallback(false, "Could not geocode your location. Enter a more specific location and try again.")
                    
                }
                
            })
            
        })
        
    }
    
    
    /* configure display for reset */
    func configureDisplay(_ reset: Bool) {
        
        
        mapView.isHidden = reset
        linkTextField.isHidden = reset
        linkTextField.isHidden = reset
        
        locationTextField.isHidden = !reset
        HeaderLabel.isHidden = !reset
        
        if !reset {
            TopView.backgroundColor = UIColor.blue
        }
    }
    /* create a mapView indicator */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            
            return nil
        }
        
        let pin = "pin"
        
        var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pin) as? MKPinAnnotationView
        if pinAnnotationView  == nil {
            pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pin)
            if #available(iOS 9.0, *) {
                pinAnnotationView?.pinTintColor = UIColor.cyan
            } else {
                pinAnnotationView?.pinColor = .green
            }
            
        } else {
            pinAnnotationView?.annotation = annotation
        }
        
        return pinAnnotationView
        
    }
}
