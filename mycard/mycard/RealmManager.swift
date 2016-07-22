//
//  RealmManager.swift
//  mycard
//
//  Created by Noah Frenkel on 7/13/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHelper {
    
    // Add card
    static func addCard(card: Card) {
        
        let realm = try! Realm()
        try! realm.write() {
            realm.add(card)
        }
    }
    
    // Update Card
    static func updateCard(cardToBeUpdated: Card, updatedCard: Card) {
        
        let realm = try! Realm()
        try! realm.write() {
            cardToBeUpdated.firstName = updatedCard.firstName
            cardToBeUpdated.lastName = updatedCard.lastName
            cardToBeUpdated.emailAddress = updatedCard.emailAddress
            cardToBeUpdated.phoneNumber = updatedCard.phoneNumber
            cardToBeUpdated.imageFilePath = updatedCard.imageFilePath
        }
    }
    
    // Retrieve User's card
    static func retrieveUserCard() -> Card? {
        
        let realm = try! Realm()
        return realm.objects(Card).first
    }
}
