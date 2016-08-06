//
//  ShareCardsViewController.swift
//  mycard
//
//  Created by Noah Frenkel on 7/28/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import UIKit
import iCarousel
import JSSAlertView
import Parse
import MultipeerConnectivity

class ShareCardsViewController: UIViewController, MPCManagerShareDataDelegate, iCarouselDataSource, iCarouselDelegate {
    
    // MARK: - Outlets and Properties
    var collectedCards = [Card]()
    
    @IBOutlet var carousel: iCarousel!
    @IBOutlet var userCardSuperview: UIView!
    
    var userCardView: CardView!
    
    var connectedUser: PFUser!
    var connectedUserCard: Card!
    var connectedPeerId: MCPeerID!
    
    // Declaring and instantiating the app delegate
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Declaring and instantiating the app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        // Do any additional setup after loading the view.
        carousel.type = .Rotary
        carousel.vertical = true
        
        ParseManager.getCardsRecievedByUser() {
            (results: [PFObject]?, error: NSError?) -> Void in
            
            if error != nil {
                print("error retrieving current user's cards")
                return
            }
            guard results != nil || results!.count > 0 else {
                print("User has no cards")
                return
            }
            
            for result in results! {
                let card = result["card"] as! Card
                self.collectedCards.append(card)
            }
            
            self.carousel.reloadData()
        }
        
        // Setting this VC as findDevicesDelegate for MPCManager
        self.appDelegate.mpcManager.shareDataDelegate = self
        
        // Setting up gesture recognizer for user's card
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ShareCardsViewController.tap(_:)))
        userCardSuperview.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        if userCardView == nil {
            userCardView = CardView(frame: userCardSuperview.bounds)
            userCardSuperview.addSubview(userCardView)
        }
        userCardView.card = appDelegate.currentUserCard
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - iCarousel Delegate Functions
    
    func numberOfItemsInCarousel(carousel:iCarousel) -> Int {
        
        return collectedCards.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        var cardView: CardView?
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
            
            // Set up view inside items here
            let cardWidth = (self.carousel.frame.width - 20)
            let cardHeight = cardWidth * (4/7)
            cardView = CardView(frame: CGRect(origin: CGPointZero, size: CGSizeMake(cardWidth, cardHeight)))
        }
        else
        {
            //get a reference to the label in the recycled view
            cardView = view as? CardView
        }
        
        
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        
        // set properties of view items here
        cardView!.card = collectedCards[index]
        
        return cardView!
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        
        let selectedCard = collectedCards[index]
        sendCard(selectedCard)
    }

    // MARK: - MPC Share Data Delegate Functions
    
    func recievedData(data: NSData) {
        
        let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Dictionary<String, String>
        let notificationStruct = RecievedCardNotification(sentFrom: dict["sentFrom"]!, cardId: dict["cardId"]!)
        let recievedCardId = notificationStruct.cardId
        let senderName = notificationStruct.sentFrom
        
        // MARK: TODO: Display alert view of card rather than a JSS Alert View
        let query = PFQuery(className: "Card")
        query.whereKey("objectId", equalTo: recievedCardId)
        query.findObjectsInBackgroundWithBlock() {
            (results: [PFObject]?, error: NSError?) -> Void in
                let cardRecieved = results?.first as! Card?
                if cardRecieved != nil {
                    dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                        let notification = JSSAlertView().show(
                            self,
                            title: "New Card Recieved",
                            text: "\(senderName) sent you a card.",
                            buttonText: "Okay",
                            color: WET_ASPHALT
                        )
                        notification.setTextTheme(.Light)
                    }
                    self.collectedCards.append(cardRecieved!)
                    self.carousel.reloadData()
                    self.carousel.scrollToItemAtIndex((self.collectedCards.count - 1), animated: true)
                }
        }
        
    }
    
    func sendCard(selectedCard: Card) {
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            let alertView = JSSAlertView().show(
                self,
                title: "Send Card",
                text: "Send \(selectedCard.firstName!) \(selectedCard.lastName!)'s card to \(self.connectedUserCard.firstName!) \(self.connectedUserCard.lastName!)?",
                buttonText: "Confirm",
                cancelButtonText: "Cancel",
                color: WET_ASPHALT
            )
            alertView.setTextTheme(.Light)
            alertView.addAction() { () -> Void in
                ParseManager.sendCard(self.connectedUser, card: selectedCard)
                let recievedCardNotification = RecievedCardNotification(
                    sentFrom: "\(self.userCardView.card.firstName!) \(self.userCardView.card.lastName!)",
                    cardId: selectedCard.objectId!
                )
                self.appDelegate.mpcManager.sendNotification(recievedCardNotification, connectedPeer: self.connectedPeerId)
            }
        }
    }
    
    // MARK: - Gesture Recognizers
    
    func tap(sender: AnyObject) {
        
        sendCard(userCardView.card)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
