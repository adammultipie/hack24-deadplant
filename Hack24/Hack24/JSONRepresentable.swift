//
//  JSONRepresentable.swift
//  Hack24
//
//  Created by Adam Mitchell on 19/03/2016.
//  Copyright © 2016 MultiPie. All rights reserved.
//

import Foundation

protocol JSONRepresentiable {
    
    init?(json:NSDictionary);
    
}