//
//  ProfileViewController.swift
//  mycard
//
//  Created by Noah Frenkel on 8/9/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import UIKit
import Parse
import JSSAlertView

class ProfileViewController: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var newUser: PFUser!

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var confirmEmailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBAction func createUserButton(sender: AnyObject) {
        
        guard firstNameField.text != nil else {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let alertView = JSSAlertView().show(
                    self,
                    title: "Invalid First Name",
                    text: "Please enter your first name.",
                    buttonText: "Dismiss",
                    color: WET_ASPHALT
                )
                alertView.setTextTheme(.Light)
            }
            return
        }
        
        guard lastNameField.text != nil else {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let alertView = JSSAlertView().show(
                    self,
                    title: "Invalid Last Name",
                    text: "Please enter your last name.",
                    buttonText: "Dismiss",
                    color: WET_ASPHALT
                )
                alertView.setTextTheme(.Light)
            }
            return
        }
        
        guard ValidationManager.validateEmailAddress(emailField.text) else {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let alertView = JSSAlertView().show(
                    self,
                    title: "Invalid Email Address",
                    text: "Please enter a valid email.",
                    buttonText: "Dismiss",
                    color: WET_ASPHALT
                )
                alertView.setTextTheme(.Light)
            }
            return
        }
        
        guard ValidationManager.validatePassword(passwordField.text) else {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let alertView = JSSAlertView().show(
                    self,
                    title: "Invalid Password",
                    text: "Please enter a password of 6 characters or longer.",
                    buttonText: "Dismiss",
                    color: WET_ASPHALT
                )
                alertView.setTextTheme(.Light)
            }
            return
        }
        
        guard confirmEmailField.text! == emailField.text! else {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let alertView = JSSAlertView().show(
                    self,
                    title: "Please Confirm Email",
                    text: "Email does not match confirmation.",
                    buttonText: "Dismiss",
                    color: WET_ASPHALT
                )
                alertView.setTextTheme(.Light)
            }
            return
        }
        
        guard confirmPasswordField.text! == passwordField.text! else {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let alertView = JSSAlertView().show(
                    self,
                    title: "Please Confirm Password",
                    text: "Password does not match confirmation.",
                    buttonText: "Dismiss",
                    color: WET_ASPHALT
                )
                alertView.setTextTheme(.Light)
            }
            return
        }
        
        newUser = appDelegate.parseLoginManager.createNewUser(emailField.text!, password: passwordField.text!)
        
        newUser.signUpInBackgroundWithBlock() {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    let alertView = JSSAlertView().show(
                        self,
                        title: "Error Signing Up",
                        text: errorString! as String,
                        buttonText: "Dismiss",
                        color: WET_ASPHALT
                    )
                    alertView.setTextTheme(.Light)
                }
            } else {
                self.performSegueWithIdentifier("continueSignUp", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Dismisses keyboard when screen is touched
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "continueSignUp" {
            let cardInfoViewController = segue.destinationViewController as! CardInfoViewController
            
            cardInfoViewController.newUser = newUser
            cardInfoViewController.firstName = firstNameField.text!
            cardInfoViewController.lastName = lastNameField.text!
            cardInfoViewController.email = emailField.text!
            cardInfoViewController.password = passwordField.text!
            
        }
    }
    

}
