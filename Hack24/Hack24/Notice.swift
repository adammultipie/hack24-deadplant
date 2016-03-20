//
//  Notice.swift
//  Hack24
//
//  Created by Adam Mitchell on 19/03/2016.
//  Copyright © 2016 MultiPie. All rights reserved.
//

import Foundation

class Notice:JSONRepresentiable {
    
    let id:String
    
    var author:String?
    var created:String?
    var file:String?
    var title:String?
    var text:String?
    var thumbnail:String?
    
    required init?(json: NSDictionary) {
        guard let pk = json["pk"] as? Int else {
            id = "";
            return nil
        }
        
        id = "\(pk)"
        author = json["author"] as? String
        created = json["created"] as? String
        file = json["file"] as? String
        title = json["title"] as? String
        text = json["text"] as? String
        thumbnail = json["thumb"] as? String
    }
    
}
