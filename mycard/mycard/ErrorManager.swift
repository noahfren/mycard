//
//  ErrorManager.swift
//  myCard
//
//  Created by Noah Frenkel on 8/26/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import Foundation
import JSSAlertView

class Error {
    
    var sender: AnyObject
    var message: String
    var title: String
    
    init(sender: AnyObject, message: String, title: String) {
        
        self.sender = sender
        self.message = message
        self.title = title
    }
    
    init(sender: AnyObject) {
        
        self.sender = sender
        self.message = "Something went wrong. Please try again later."
        self.title = "Uh-Oh."
    }
}

class ErrorManager {
    
    static func showError(error: Error) {
        
        let viewcontroller = UIApplication.sharedApplication().windows[0].rootViewController!
        dispatch_async(dispatch_get_main_queue()) {
            let errorView = JSSAlertView().show(
                viewcontroller,
                title: error.title,
                text: error.message,
                buttonText: "Dismiss",
                color: WET_ASPHALT
            )
            errorView.setTextTheme(.Light)
        }
    }
    
    static func defaultError(sender: AnyObject) {
        
        let error = Error(sender: sender)
        showError(error)
    }
    
    static func signInError(sender: AnyObject) {
        
        let error = Error(
            sender: sender,
            message: "Could not sign in to your myCard account at this time. Please try again later.",
            title: "Houston, we have a problem."
        )
        
        showError(error)
    }
    
    static func signUpError(sender: AnyObject) {
        
        let error = Error(
            sender: sender,
            message: "Could not create your account at this time. Please try again later.",
            title: "Oh-No."
        )
        
        showError(error)
    }
    
}