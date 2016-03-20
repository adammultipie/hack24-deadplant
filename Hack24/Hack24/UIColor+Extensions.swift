//
//  UIColor+Extensions.swift
//  Hack24
//
//  Created by Adam Mitchell on 19/03/2016.
//  Copyright © 2016 MultiPie. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static func random() -> UIColor {
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    static func watermelonGreen() -> UIColor {
        return UIColor(hexString:"#255a27");
    }
    
    static func watermelonPink() -> UIColor {
        return UIColor(hexString:"#fe2e4d");
    }
    
    convenience init(hexString:String?) {
        if let hex = hexString {
            var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
            if (cString.hasPrefix("#")) {
                cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
            }
            
            if (cString.characters.count != 6) {
                self.init(red: 170.0/255.0, green: 38.0/255.0, blue: 23.0/255.0, alpha: 1.0)
            } else {
                var rgbValue:UInt32 = 0
                NSScanner(string: cString).scanHexInt(&rgbValue)
                
                self.init(
                    red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                    green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                    blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                    alpha: CGFloat(1.0)
                )
            }
        } else {
            self.init(red: 170.0/255.0, green: 38.0/255.0, blue: 23.0/255.0, alpha: 1.0)
        }
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}
