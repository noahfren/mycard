//
//  ParseLoginManager.swift
//  mycard
//
//  Created by Noah Frenkel on 8/8/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import Foundation
import Parse
import ParseUI

typealias ParseLoginManagerCallback = (PFUser?, NSError?) -> Void

class ParseLoginManager : NSObject {
    
    let callback: ParseLoginManagerCallback
    
    init(callback: ParseLoginManagerCallback) {
        self.callback = callback
    }
    
    
    func signInUser(email: String, password: String) {
        
        PFUser.logInWithUsernameInBackground(email, password: password, block: self.callback)
    }
    
    func signOutUser() {
        
        PFUser.logOutInBackground()
    }
    
    func createNewUser(email: String, password: String) -> PFUser {
        
        let newUser = PFUser()
        newUser.username = email
        newUser.password = password
        newUser.email = email
        
        return newUser
    }
    
}