//
//  LogInViewController.swift
//  mycard
//
//  Created by Noah Frenkel on 8/9/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import UIKit
import JSSAlertView

class LogInViewController: UIViewController {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func signIn(sender: AnyObject) {
        
        if let email = emailField.text, let password = passwordField.text {
            appDelegate.parseLoginManager.signInUser(email, password: password)
        }
        else {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let alertView = JSSAlertView().show(
                    self,
                    title: "Invalid Email Address and/or Password",
                    text: "Please enter a valid email address and password.",
                    buttonText: "Dismiss",
                    color: WET_ASPHALT
                )
                alertView.setTextTheme(.Light)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
