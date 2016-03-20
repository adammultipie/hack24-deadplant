//
//  NavBoardCell.swift
//  Hack24
//
//  Created by Adam Mitchell on 20/03/2016.
//  Copyright © 2016 MultiPie. All rights reserved.
//

import UIKit
import Foundation

class NavBoardCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = UIColor.watermelonPink()
    }
    
}
