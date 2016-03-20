//
//  NavMapCell.swift
//  Hack24
//
//  Created by Adam Mitchell on 20/03/2016.
//  Copyright © 2016 MultiPie. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class NavMapCell: UITableViewCell {
    @IBOutlet weak var mapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mapView.showsUserLocation = true
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
    }

}
