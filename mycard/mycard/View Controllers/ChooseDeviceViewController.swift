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
import Parse
import DZNEmptyDataSet

let WET_ASPHALT = UIColorFromHex(0x34495e, alpha: 1)

class ChooseDeviceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    // MARK: - Outlets and Properties
    @IBOutlet weak var userCard: CardView!
    @IBOutlet weak var tblPeers: UITableView!
    
    var contactStore = CNContactStore()
    
    // Declaring and instantiating the app delegate
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Attempting to load user's contact info from Parse
        if let card = appDelegate.currentUserCard {
            
            print(card.firstName)
            //userCard.card = card
            
        }
        // If no info is found, segue to getContactInfoViewController
        else{
            self.performSegueWithIdentifier("GetContactInfo", sender: self)
        }
        
        // Setting this VC as data source and delegate for DZNEmptyDataSet
        self.tblPeers.emptyDataSetSource = self
        self.tblPeers.emptyDataSetDelegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Setting the mpcManager's delegate to this View Controller
        appDelegate.mpcManager.delegate = self
        
        // Start searching for other devices running the app
        appDelegate.mpcManager.browser.startBrowsingForPeers()
        
        // Start advertising to other devices
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - MPCDelegate Functions
    
    func foundPeer() {
        tblPeers.reloadData()
    }
    
    func lostPeer() {
        tblPeers.reloadData()
    }
    
    // This function will create an alert to the user when they recieve an invitation to swap contacts
    func invitationWasReceived(fromPeer: String) {
        
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
        // Segue here
        self.performSegueWithIdentifier("ConnectedWithPeer", sender: self)
    }
    
    
    // MARK: - Table View Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mpcManager.foundPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("peerIDCell")! as! PeerTableViewCell
        let selectedPeerUserInfo = appDelegate.mpcManager.foundPeers[indexPath.row].userInfo
        
        cell.peerIDLabel.text = "\(selectedPeerUserInfo["firstName"]!) \(selectedPeerUserInfo["lastName"]!)"
        cell.peerIDImage.image = UIImage(named: "defaultUser")!.circle
        
        let query = PFQuery(className: "Card")
        query.getObjectInBackgroundWithId(selectedPeerUserInfo["cardId"]!) {
            (result: PFObject?, error: NSError?) -> Void in
                cell.card = result as? Card
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedPeer = appDelegate.mpcManager.foundPeers[indexPath.row] as peerStruct
        
        appDelegate.mpcManager.browser.invitePeer(selectedPeer.id, toSession: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    // MARK: - Empty Data Set Delegate / Data Source
    /*func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage {
        return UIImage(named: "empty_placeholder")!
    }*/
    
    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString {
        let text = "Can't Find Nearby Users"
        let attributes: [String : AnyObject] = ["NSFontAttributeName": UIFont.boldSystemFontOfSize(18.0), "NSForegroundColorAttributeName": UIColor.darkGrayColor()]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString {
        let text: String = "Make sure your Wi-Fi and Bluetooth are turned on. Also, make sure other mycard users have the app open!"
        let paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph.alignment = .Center
        let attributes: [String : AnyObject] = ["NSFontAttributeName": UIFont.systemFontOfSize(14.0), "NSForegroundColorAttributeName": UIColor.lightGrayColor(), "NSParagraphStyleAttributeName": paragraph]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    
    // MARK: - Navigation
    
    // Preparing for segue to edit info screen
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    // unwind segue
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        
    }
}

