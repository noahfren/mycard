//
//  CardView.swift
//  mycard
//
//  Created by Noah Frenkel on 8/1/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import UIKit

@IBDesignable class CardView: UIView {
    
    var view: UIView!

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var firstNameLabel : UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    
    var card: Card! {
        didSet {
            if let temp = card.image {
                image.image = temp
            }
            else {
                card.fetchImage() { () -> Void in
                    self.image.image = self.card.image!
                }
            }
            firstNameLabel.text = card.firstName
            lastNameLabel.text = card.lastName
            phoneNumber.text = card.phoneNumber
            emailAddress.text = card.email
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        // Adding custom subview on top of our view
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "CardView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}