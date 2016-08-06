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
            print("Could not get card")
            
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

}