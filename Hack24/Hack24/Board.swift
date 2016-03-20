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
    var alerts = [Notice]()
    
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
        if let noticesArray = json["alerts"] as? NSArray {
            for element in noticesArray {
                if let dict = element as? NSDictionary {
                    if let notice = Notice(json: dict) {
                        alerts.append(notice)
                    }
                }
            }
        }
    }
    
}
