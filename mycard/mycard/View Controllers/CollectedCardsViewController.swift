//
//  CollectedCardsViewController.swift
//  mycard
//
//  Created by Noah Frenkel on 8/6/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import UIKit
import iCarousel
import JSSAlertView
import DZNEmptyDataSet
import Parse

class CollectedCardsViewController: UIViewController, iCarouselDelegate, iCarouselDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    // MARK: - Outlets and Properties
    
    @IBOutlet var carousel: iCarousel!
    
    var collectedCards = [Card]()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting up iCarousel
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
            
            if self.collectedCards.count == 0 {
            
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    
                    let alert = JSSAlertView().show(
                        self,
                        title: "You Don't Have Any Cards Yet",
                        text: "Connect with users to get their cards and expand your network!",
                        buttonText: "Oh.",
                        color: WET_ASPHALT
                    )
                    alert.setTextTheme(.Light)
                    alert.addAction() {
                        self.performSegueWithIdentifier("NoCards", sender: self)
                    }
                    
                }
            
            }
            
            self.carousel.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: iCarousel Delegate and Data Source Functions
    
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
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            
            let alert = JSSAlertView().show(
                self,
                title: "\(selectedCard.firstName!) \(selectedCard.lastName!)",
                buttonText: "Dismiss",
                cancelButtonText: "Delete",
                iconImage: selectedCard.image!.resizeForPreview!.circle!,
                color: WET_ASPHALT
            )
            alert.setTextTheme(.Light)
            
            alert.addCancelAction() {
                self.collectedCards.removeAtIndex(index)
                ParseManager.deleteCard(selectedCard)
                carousel.reloadData()
            }
        }
    }
    
    // MARK: DZNEmptyDataSet Delegate and Data Dource functions
    
    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString {
        let text = "You Don't Have Any Cards Yet"
        let attributes: [String : AnyObject] = ["NSFontAttributeName": UIFont.boldSystemFontOfSize(18.0), "NSForegroundColorAttributeName": UIColor.darkGrayColor()]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString {
        let text: String = "Connect with other users to get their cards and expand your network!"
        let paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph.alignment = .Center
        let attributes: [String : AnyObject] = ["NSFontAttributeName": UIFont.systemFontOfSize(14.0), "NSForegroundColorAttributeName": UIColor.lightGrayColor(), "NSParagraphStyleAttributeName": paragraph]
        return NSAttributedString(string: text, attributes: attributes)
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
