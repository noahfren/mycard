//
//  ValidationManager.swift
//  mycard
//
//  Created by Noah Frenkel on 8/7/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import Foundation

class ValidationManager {
    
    static func validatePhoneNumber(number: String?) -> Bool {
        
        if let number = number {
            
            if number.characters.count != 14 {return false}
            
            let indexZero = number.startIndex
            if number[indexZero] != "(" {return false}
            
            let indexFour = number.startIndex.advancedBy(4)
            if number[indexFour] != ")" {return false}
            
            let indexFive = number.startIndex.advancedBy(5)
            if number[indexFive] != " " {return false}
            
            let indexNine = number.startIndex.advancedBy(9)
            if number[indexNine] != "-" {return false}
            
            return true
        }
        
        return false
    }
    
    static func validateEmailAddress(email: String?) -> Bool {
        
        var hasAtSymbol = false
        var hasPeriod = false
        if let email = email {
            
            if email.characters.count < 5 {return false}
            for char in email.characters {
                if char == "@" {hasAtSymbol = true}
                if char == "." {
                    if hasAtSymbol {
                        hasPeriod = true
                    }
                    else {
                        return false
                    }
                }
            }
            
            return hasPeriod && hasAtSymbol
        }
        
        return false
    }
    
    static func validatePassword(password: String?) -> Bool {
        
        if let password = password {
            
            if password.characters.count >= 6 {
                return true
            }
            
        }
        
        return false
    }
}