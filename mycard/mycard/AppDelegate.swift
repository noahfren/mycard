//
//  AppDelegate.swift
//  mycard
//
//  Created by Noah Frenkel on 7/6/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import UIKit
import Parse

let APP_ID = "myCard"
let SERVER_URL = "https://mycard-nf.herokuapp.com/parse"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mpcManager: MPCManager!
    var currentUserCard: Card!
    


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Override point for customization after application launch.
        
        
        // MARK: Initializing Parse
        let config = ParseClientConfiguration {
            $0.applicationId = APP_ID
            $0.server = SERVER_URL
        }
        
        Card.registerSubclass()
        
        Parse.initializeWithConfiguration(config)
        
        // MARK: Temporary user log-in mechanism
        do {
            try PFUser.logInWithUsername("test_user1", password: "password")
        } catch {
            print("Unable to log in")
        }
        
        if let currentUser = PFUser.currentUser() {
            print("\(currentUser.username!) logged in successfully")
            currentUserCard = ParseManager.getCardForCurrentUser()
            currentUserCard.fetchImage() {() -> Void in }
            self.mpcManager = MPCManager(currentUserCard: self.currentUserCard, currentUserID: currentUser.objectId!)
            
        } else {
            print("No logged in user :(")
        }
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // Stop advertising and browsing for peers when the app enters background
        // mpcManager.advertiser.stopAdvertisingPeer()
        // mpcManager.browser.stopBrowsingForPeers()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        // Start advertising and browsing for peers again when app comes to foreground
        // mpcManager.advertiser.startAdvertisingPeer()
        // mpcManager.browser.startBrowsingForPeers()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // Stop advertising and browsing for peers when the app enters terminates
        mpcManager.advertiser.stopAdvertisingPeer()
        mpcManager.browser.stopBrowsingForPeers()
    }

}

