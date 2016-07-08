//
//  ViewController.swift
//  mycard
//
//  Created by Noah Frenkel on 7/6/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Contacts
import ContactsUI

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate {

    @IBOutlet weak var tblPeers: UITableView!
    var contactToSend: NSData!
    var contactStore = CNContactStore()
    
    // Declaring and instantiating the app delegate
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting the mpcManager's delegate to this View Controller
        appDelegate.mpcManager.delegate = self
        
        // Start searching for other devices running the app
        appDelegate.mpcManager.browser.startBrowsingForPeers()
        
        // Start advertising to other devices
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Attempting to load user's contact info
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("contact") as? NSData {
            contactToSend = data
        }
        // If no info is found, segue to getContactInfoViewController
        else{
            self.performSegueWithIdentifier("GetContactInfo", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func foundPeer() {
        tblPeers.reloadData()
    }
    
    func lostPeer() {
        tblPeers.reloadData()
    }
    
    // This function will create an alert to the user when they recieve an invitation to swap contacts
    func invitationWasReceived(fromPeer: String) {
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to share contact information with you.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
        }
        
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            self.appDelegate.mpcManager.invitationHandler(false, self.appDelegate.mpcManager.session)
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // This function will perform an operation when the user connects with their peer
    // MARK: TODO: Add pop up functionality to display the connected peer's contact info
    func connectedWithPeer(peerID: MCPeerID) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            print("Connection has been made!")
            
            // Sending contact data to peer at peerID
            self.appDelegate.mpcManager.sendData(dataToSend: self.contactToSend, toPeer: peerID)
        }
    }
    
    func dataRecieved(data: NSData) {
        let contactRecieved = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! CNContact
        
        /*let contactViewController = CNContactViewController(forContact: contactRecieved)
        contactViewController.displayedPropertyKeys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
        showViewController(contactViewController, sender: self)
 */
        // Extracting contact info to display from recievedContact
        let number = (contactRecieved.phoneNumbers[0].value as! CNPhoneNumber).valueForKey("digits") as! String
        let email = contactRecieved.emailAddresses.first?.value as! String
        let alert = UIAlertController(title: "", message: "\(contactRecieved.givenName)  \(contactRecieved.familyName)\nPhone: \(number)\nEmail: \(email)", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Save to Contacts", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            do {
                let saveRequest = CNSaveRequest()
                saveRequest.addContact(contactRecieved as! CNMutableContact, toContainerWithIdentifier: nil)
                try self.contactStore.executeSaveRequest(saveRequest)
            }
            catch {
                print("Could not save contact")
            }
        }
        
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }

        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mpcManager.foundPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("peerIDCell")! as! PeerTableViewCell
        
        cell.peerIDLabel?.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedPeer = appDelegate.mpcManager.foundPeers[indexPath.row] as MCPeerID
        
        appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // unwind segue
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        
        // for now, simply defining the method is sufficient.
        // we'll add code later
        
    }
    
    
}

