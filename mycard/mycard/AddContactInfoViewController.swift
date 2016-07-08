//
//  AddContactInfoViewController.swift
//  mycard
//
//  Created by Benjamin Bucca on 7/8/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import UIKit
import Contacts

class AddContactInfoViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    @IBAction func saveContactInfo(sender: AnyObject) {
        
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Save" {
            
            let firstName = firstNameTextField.text
            let lastName = lastNameTextField.text
            let phoneNumber = phoneNumberTextField.text
            let emailAddress = emailAddressTextField.text
            
            let newContact = CNMutableContact()
            
            // Adding info from text field to newContact object
            newContact.givenName = firstName!
            newContact.familyName = lastName!
            let email = CNLabeledValue(label: CNLabelHome, value: emailAddress!)
            newContact.emailAddresses = [email]
            let phone = CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: phoneNumber!))
            newContact.phoneNumbers = [phone]
            
            // Saving the newContact as NSData
            let contactData = NSKeyedArchiver.archivedDataWithRootObject(newContact)
            
            // Sending contactData to main ViewController
            let viewController = segue.destinationViewController as! ViewController
            viewController.contactToSend = contactData
            
            // Saving contactData to NSUserDefault
            NSUserDefaults.standardUserDefaults().setValue(contactData, forKey: "contact")
        }
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
