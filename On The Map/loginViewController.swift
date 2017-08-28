//
//  loginViewController.swift
//  On The Map
//
//  Created by Safeen Azad on 8/26/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import UIKit

class loginViewController: UIViewController {
    
    
    var appDelegate : AppDelegate!
    var keyboardOnScreen = false
    
    
    //@IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        passwordTextField.delegate = self as? UITextFieldDelegate
        usernameTextField.delegate = self as? UITextFieldDelegate
        
        
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    /* Helper property to get a_sync queues */
    var GlobalMainQueue: DispatchQueue {
        return DispatchQueue.main
    }
    
    // MARK: Login
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        
        userDidTapView(self)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        }
        
        setUIEnabled(false)
        
        
        /* If you cannot verify the users credentials, show an error message. */
        guard self.verifyUserCredentials(username: self.usernameTextField.text, password: self.passwordTextField.text) else {
            
            alertController(withTitles: ["Ok"], message: "Please enter a valid email address and password.", callbackHandler: [nil])
            setUIEnabled(true)
            return
        }
        
        let parameters = [UdacityClient.ParameterKeys.Udacity :
            [UdacityClient.ParameterKeys.Username : self.usernameTextField.text!,
             UdacityClient.ParameterKeys.Password : self.passwordTextField.text!
            ]]
        
        /* Authenticate the session through Udacity */
        authenticateUdacitySession(parameters: parameters as [String : AnyObject])
        
        GlobalMainQueue.async(execute: {
            self.debugTextLabel.text = "Logging in"
        })
        
    } //loginPressed
    
    
    func authenticateUdacitySession(parameters : [String : AnyObject]) {
        
        UdacityClient.sharedInstance().authenticateWithViewController(parameters) { success, error in
            
            performUIUpdatesOnMain {
                self.setUIEnabled(true)
                
                if success {
                    
                    
                    self.GlobalMainQueue.async(execute: {
                        self.debugTextLabel.text = "Authenticated"
                        self.didLoginSuccessfully()
                    })
                } else{
                    
                    self.GlobalMainQueue.async(execute: {
                        
                        self.alertController(withTitles: ["Ok", "Retry"], message: "Account not found or invalid credentials.", callbackHandler: [nil, { Void in
                            self.loginPressed(self)
                            
                            }])
                        
                    })
                    
                }
            }
            
        }
    }//end of func
    
    /* If logged in successfully, get the user's data */
    func didLoginSuccessfully() {
        
        UdacityClient.sharedInstance().getUserData() {success, error in
            if success {
                
                
                /* Set user as authenticate */
                self.appDelegate.userAuthenticated = true
                
                
                
                performUIUpdatesOnMain {
                    self.debugTextLabel.text = "logged in."
                    self.setUIEnabled(true)
                    //            let controller = self.storyboard!.instantiateViewController(withIdentifier: "") as! UITabBarController
                    //            self.present(controller, animated: true, completion: nil)
                }
            } else {
                
                /* Present an alert controller with an appropriate message */
                self.GlobalMainQueue.async(execute: {
                    
                    self.alertController(withTitles: ["Ok", "Retry"], message: "Error!", callbackHandler: [nil, {Void in
                        self.loginPressed(self)
                        }])
                    
                })
                
                
            }
        }
    }// didLoginSuccessfully
    
    
    /* Verify that a proper username and password has been provided */
    func verifyUserCredentials(username: String?, password: String?) -> Bool {
        
        if password != nil && username!.contains("@") && username!.contains(".") {
            return true
            
        }
        
        return false
    }
    
    
}

// MARK: - LoginViewController (Notifications)

private extension loginViewController {
    
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: Show/Hide Keyboard
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            logoImageView.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y = 0
            logoImageView.isHidden = false
        }
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
    
    
    func setUIEnabled(_ enabled: Bool) {
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        //        debugTextLabel.text = ""
        debugTextLabel.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
}
