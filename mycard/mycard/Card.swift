//
//  Card.swift
//  mycard
//
//  Created by Noah Frenkel on 7/13/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import Parse

class Card: PFObject, PFSubclassing {
    
    // MARK: - Properties
    // Contact info fields
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var phoneNumber: String?
    @NSManaged var email: String?
    
    // Profile picture
    @NSManaged var imageFile: PFFile?
    var image: UIImage?
    
    // Owner of card
    @NSManaged var isOwnedBy: PFUser?
    
    
    // MARK: PFSubclassing Protocol
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Card"
    }
    
    // Function to parse card data into CNContact object
    // TODO: handle error cases where not all data is available
    func toCNContact() -> CNMutableContact {
        
        let returnContact = CNMutableContact()
        
        returnContact.givenName = firstName!
        returnContact.familyName = lastName!
        
        let phoneCN = CNPhoneNumber(stringValue: phoneNumber!)
        
        // Add email as Work email
        returnContact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: email!)]
        
        // Add phone number as Mobile number
        returnContact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: phoneCN)]
        
        // Add contact picture
        returnContact.imageData = NSKeyedArchiver.archivedDataWithRootObject(image!)
        
        return returnContact
    }
    
    func fetchImage(completionBlock: () -> Void) {
        do {
            let data = try self.imageFile?.getData()
            self.image = UIImage(data: data!, scale:1.0)
            completionBlock()
        }
        catch {
            ErrorManager.defaultError(self)
        }
    }
    
}

