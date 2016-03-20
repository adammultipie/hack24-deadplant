//
//  GlobalFunc.swift
//  Hack24
//
//  Created by Adam Mitchell on 19/03/2016.
//  Copyright © 2016 MultiPie. All rights reserved.
//

import Foundation
import UIKit


// Convenience method to help make NSLayoutConstraint in a less verbose way
public func constraint(item view1: AnyObject, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation = .Equal, toItem view2: AnyObject?, attribute attr2: NSLayoutAttribute? = nil, multiplier: CGFloat = 1, constant c: CGFloat = 0, priority: Float = 1000) -> NSLayoutConstraint {
    
    let attribute2 = attr2 != nil ? attr2! : attr1
    
    let constraint = NSLayoutConstraint(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attribute2, multiplier: multiplier, constant: c)
    constraint.priority = priority
    return constraint
}

public func notifyCloseDrawer() {
    NSNotificationCenter.defaultCenter().postNotificationName(NBCloseDrawer, object: nil)
}

public func notifyOpenDrawer() {
    NSNotificationCenter.defaultCenter().postNotificationName(NBOpenDrawer, object: nil);
}