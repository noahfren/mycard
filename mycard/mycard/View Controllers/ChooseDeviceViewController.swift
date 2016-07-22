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
import JSSAlertView

let WET_ASPHALT = UIColorFromHex(0x34495e, alpha: 1)

class ChooseDeviceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userFirstNameLabel: UILabel!
    @IBOutlet weak var userLastNameLabel: UILabel!
    
    @IBOutlet weak var tblPeers: UITableView!
    
    var userCard: Card!
    var contactStore = CNContactStore()
    
    // Declaring and instantiating the app delegate
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Attempting to load user's contact info from Realm
        if let card = RealmHelper.retrieveUserCard() {
            userCard = card
            
            userFirstNameLabel.text = userCard.firstName
            userLastNameLabel.text = userCard.lastName
            
            if let image = UIImage(contentsOfFile: userCard.imageFilePath) {
                userImage.image = image.circle
            }
            
        }
        // If no info is found, segue to getContactInfoViewController
        else{
            self.performSegueWithIdentifier("GetContactInfo", sender: self)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if let card = RealmHelper.retrieveUserCard() {
            userCard = card
            
            userFirstNameLabel.text = userCard.firstName
            userLastNameLabel.text = userCard.lastName
            
            let image = UIImage(contentsOfFile: userCard.imageFilePath)
            userImage.image = image?.circle
            
        }
        // Setting the mpcManager's delegate to this View Controller
        appDelegate.mpcManager.delegate = self
        
        // Start searching for other devices running the app
        appDelegate.mpcManager.browser.startBrowsingForPeers()
        
        // Start advertising to other devices
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: MPCDelegate Functions
    
    func foundPeer() {
        tblPeers.reloadData()
    }
    
    func lostPeer() {
        tblPeers.reloadData()
    }
    
    // This function will create an alert to the user when they recieve an invitation to swap contacts
    func invitationWasReceived(fromPeer: String) {
        /*let alert = UIAlertController(title: "", message: "\(fromPeer) wants to share contact information with you.", preferredStyle: UIAlertControllerStyle.Alert)
        
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
        }*/
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            let alertView = JSSAlertView().show(
                self,
                title: "Invitation Recieved",
                text: "\(fromPeer) would like to share contact information with you.",
                buttonText: "Accept",
                cancelButtonText: "Cancel",
                color: WET_ASPHALT
            )
            alertView.setTextTheme(.Light)
            alertView.addAction() { () -> Void in
                self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
            }
        }
    }
    
    // This function will perform an operation when the user connects with their peer
    func connectedWithPeer(peerID: MCPeerID) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            // Sending contact data to peer at peerID
            self.appDelegate.mpcManager.sendData(dataToSend: self.userCard.toNSData(), toPeer: peerID)
        }
    }
    
    func dataRecieved(data: NSData) {
        let cardRecieved = dataToCard(data)
        let image = ImageHelper.dataToImage(data)
        
        
        // Display pop-up with contact info and offer to save
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            let alertView = JSSAlertView().show(
                self,
                title: "\(cardRecieved.firstName) \(cardRecieved.lastName)",
                text: "\nPhone: \(cardRecieved.phoneNumber)\nEmail: \(cardRecieved.emailAddress)",
                iconImage: image.circle,
                buttonText: "Save",
                cancelButtonText: "Cancel",
                color: WET_ASPHALT
            )
            alertView.setTextTheme(.Light)
            alertView.addAction() { () -> Void in
                do {
                    let saveRequest = CNSaveRequest()
                    saveRequest.addContact(cardRecieved.toCNContact(image), toContainerWithIdentifier: nil)
                    try self.contactStore.executeSaveRequest(saveRequest)
                }
                catch {
                    print("Could not save contact")
                }
            }
        }
    }
    
    // MARK: Table View Functions
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
    
    // MARK: Navigation
    
    // Preparing for segue to edit info screen
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Filling forms with existing contact info if the user is editing an already existing card
        if segue.identifier == "EditContactInfo" {
            let editInfoViewController = segue.destinationViewController as! EditInfoViewController
            
            editInfoViewController.card = userCard
        }
    }
    
    // unwind segue
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        
        // for now, simply defining the method is sufficient.
        // we'll add code later
        
    }
    
    
}

