//
//  newCell.swift
//  list
//
//  Created by donezio on 11/13/17.
//  Copyright © 2017 macbook pro. All rights reserved.
//

import UIKit
import FoldingCell

class newCell: FoldingCell {
   
    @IBOutlet weak var amount: UILabel!
    
    @IBOutlet weak var shortDes: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
       
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
}
