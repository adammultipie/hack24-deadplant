//
//  Board.swift
//  Hack24
//
//  Created by Adam Mitchell on 19/03/2016.
//  Copyright © 2016 MultiPie. All rights reserved.
//

import Foundation

class Board:JSONRepresentiable {
    
    let id:String;
    let name:String;
    
    required init?(json: NSDictionary) {
        guard
            let pk = json["pk"] as? Int,
            let name = json["name"] as? String
            
            else {
                self.id = "";
                self.name = "";
                return nil
        }
        
        self.id = "\(pk)";
        self.name = name;
    }
    
}
