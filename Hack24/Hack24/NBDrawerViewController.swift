//
//  NBDrawerViewController.swift
//  Hack24
//
//  Created by Adam Mitchell on 20/03/2016.
//  Copyright © 2016 MultiPie. All rights reserved.
//

import Foundation
import UIKit
import KYDrawerController

let NBCloseDrawer = "NBCloseDrawer"
let NBOpenDrawer = "NBOpenDrawer"

class NBDrawerViewController:KYDrawerController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("openDrawer"), name: NBOpenDrawer, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("closeDrawer"), name: NBCloseDrawer, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func closeDrawer() {
        setDrawerState(.Closed, animated: true)
    }
    
    func openDrawer() {
        setDrawerState(.Opened, animated: true)
    }
    
}