//
//  Card.swift
//  mycard
//
//  Created by Noah Frenkel on 7/13/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import Foundation
import RealmSwift
import Contacts

class Card: Object {
    // Contact info fields
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var phoneNumber = ""
    dynamic var emailAddress = ""
    
    // Profile picture
    // TODO: Set default to first and last initials a la Apple's contacts
    dynamic var imageFilePath = ""
    
    // Function to parse card data into CNContact object
    // TODO: handle error cases where not all data is available
    func toCNContact(image: UIImage) -> CNMutableContact {
        
        let returnContact = CNMutableContact()
        
        returnContact.givenName = firstName
        returnContact.familyName = lastName
        
        let phoneCN = CNPhoneNumber(stringValue: phoneNumber)
        
        // Add email as Work email
        returnContact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: emailAddress)]
        
        // Add phone number as Mobile number
        returnContact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: phoneCN)]
        
        // Add contact picture
        returnContact.imageData = NSKeyedArchiver.archivedDataWithRootObject(image)
        
        return returnContact
    }
    
    // Function to convert card data into NSData object
    // This could potentially convert the data to a dictionary then codify that (for added flexibility with contact fields)
    func toNSData() -> NSData {
        
        let imageData = ImageHelper.imageToNSData(self.imageFilePath)
        let cardDictionary = ["firstName": self.firstName, "lastName": self.lastName, "phoneNumber": self.phoneNumber, "emailAddress": self.emailAddress, "imageData": imageData]
        return NSKeyedArchiver.archivedDataWithRootObject(cardDictionary)
        
    }
}

// Function to convert NSData to a card object
// Requires data to be a codified Card object
// This could potentially convert the data to a dictionary then codify that (for added flexibility with contact fields)
func dataToCard(data: NSData) -> Card {
    
    let cardDictionary =  NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Dictionary<String, AnyObject>
    
    let card = Card()
    
    card.firstName = cardDictionary["firstName"]! as! String
    card.lastName = cardDictionary["lastName"]! as! String
    card.phoneNumber = cardDictionary["phoneNumber"]! as! String
    card.emailAddress = cardDictionary["emailAddress"]! as! String

    let imageData = cardDictionary["imageData"]! as! NSData
    let image = NSKeyedUnarchiver.unarchiveObjectWithData(imageData) as! UIImage
    let imageFileName = ImageHelper.randomImageFileName()
    let imageFilePath = ImageHelper.getImageDirectory(withFileName: imageFileName)
    
    card.imageFilePath = imageFilePath
    ImageHelper.saveImageAsJPEG(imageFilePath, image: image)
    
    return card
}
