//
//  ShareCardsViewController.swift
//  mycard
//
//  Created by Noah Frenkel on 7/28/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import UIKit
import iCarousel
import Parse

class ShareCardsViewController: UIViewController, iCarouselDataSource, iCarouselDelegate {
    
    // MARK: - Outlets and Properties
    var collectedCards = [Card]()
    
    @IBOutlet var carousel: iCarousel!
    @IBOutlet var cardView: CardView!
    
    // Declaring and instantiating the app delegate
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        carousel.type = .CoverFlow2
        
        cardView.card = appDelegate.currentUserCard
        
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
            
        }
        
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
            cardView = NSBundle.mainBundle().loadNibNamed("CardView", owner: self, options:nil)[0] as? CardView
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
