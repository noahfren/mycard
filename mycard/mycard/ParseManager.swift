//
//  ParseManager.swift
//  mycard
//
//  Created by Noah Frenkel on 7/27/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import Foundation
import Parse

class ParseManager {
    
    // MARK: - Relation Strings
    // UserHasCard Relation
    static let ParseUserHasCardUser = "user"
    static let ParseUserHasCardCard = "card"
    
    // Card Relation
    static let ParseCardBelongsToUser = "isOwnedBy"
    
    
    // MARK: - Querying Functions
    
    // Synchronous getCard
    static func getCardForCurrentUser() -> Card? {
        
        let query = PFQuery(className: "Card")
        var card: Card? = nil
        
        query.whereKey(ParseCardBelongsToUser, equalTo: PFUser.currentUser()!)
        do {
            card = try query.getFirstObject() as? Card
        } catch {
            
        }
        return card
    }
    
    static func getCardsRecievedByUser(completionBlock: PFQueryArrayResultBlock) {
        
        let query = PFQuery(className: "UserHasCard")
        
        query.whereKey(ParseUserHasCardUser, equalTo: PFUser.currentUser()!)
        query.includeKey(ParseUserHasCardCard)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func sendCard(user: PFUser, card: Card) {
        
        let userHasCardObject = PFObject(className: "UserHasCard")
        userHasCardObject.setObject(user, forKey: ParseUserHasCardUser)
        userHasCardObject.setObject(card, forKey: ParseUserHasCardCard)
        
        let query = PFQuery(className: "UserHasCard")
        query.whereKey(ParseUserHasCardUser, equalTo: user)
        query.whereKey(ParseUserHasCardCard, equalTo: card)
        query.findObjectsInBackgroundWithBlock() {
            (results: [PFObject]?, error: NSError?) -> Void in
            
            if (error != nil) {
                ErrorManager.defaultError(self)
            }
            if let results = results {
                if results.count == 0 {
                    userHasCardObject.saveInBackgroundWithBlock(nil)
                }
            }
            else {
                userHasCardObject.saveInBackgroundWithBlock(nil)
            }
        }
    }
    
    static func deleteCard(card: Card) {
        
        let query = PFQuery(className: "UserHasCard")
        query.whereKey(ParseUserHasCardCard, equalTo: card)
        query.whereKey(ParseUserHasCardUser, equalTo: PFUser.currentUser()!)
        
        query.findObjectsInBackgroundWithBlock() {
            (results: [PFObject]?, error: NSError?) -> Void in
            
            if (error != nil) {
                
                ErrorManager.defaultError(self)
            }
            
            if let userHasCard = results?.first {
                userHasCard.deleteInBackground()
            }
        }
    }
    
    static func updateCard(card: Card) {
        
        let query = PFQuery(className: "Card")
        query.whereKey(ParseCardBelongsToUser, equalTo: PFUser.currentUser()!)
        
        query.findObjectsInBackgroundWithBlock() {
            (results: [PFObject]?, error: NSError?) -> Void in
            
            if (error != nil) {
                ErrorManager.defaultError(self)
            }
            
            if let userCard = results?.first as? Card {
                userCard["firstName"] = card.firstName!
                userCard["lastName"] = card.lastName!
                userCard["email"] = card.email!
                userCard["phoneNumber"] = card.phoneNumber!
                
                let imageData = NSKeyedArchiver.archivedDataWithRootObject(card.image!)
                
                userCard["image"] = PFFile(name: "profilePic.jpg", data: imageData)
                
                userCard.saveInBackground()
            }
        }
    }

}