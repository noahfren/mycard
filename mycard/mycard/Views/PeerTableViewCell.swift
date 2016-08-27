//
//  PeerTableViewCell.swift
//  mycard
//
//  Created by Noah Frenkel on 7/6/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import UIKit

class PeerTableViewCell: UITableViewCell {

    @IBOutlet weak var peerIDLabel: UILabel!
    @IBOutlet weak var peerIDImage: UIImageView!
    
    var firstName: String!
    var lastName: String!
    var card: Card! {
        didSet {
            card.fetchImage() { () -> Void in
                self.peerIDImage.image = self.card.image!.circle!
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
