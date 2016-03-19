//
//  BoardInteractor.swift
//  Hack24
//
//  Created by Adam Mitchell on 19/03/2016.
//  Copyright © 2016 MultiPie. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

class BoardsInteractor {
    
    var retrievedBeacons = [String]();
    var waitingBeacons = [CLBeacon]();
    
    var boardsBeaconsRequest:Request?;
    
    func onBeaconsDiscovered(beacons:[CLBeacon]) {
        var beaconArray = [[String:String]]();
        var keys = self.retrievedBeacons;
        for beacon in beacons {
            var beaconDict = [String:String]();
            let key = beacon.proximityUUID.UUIDString + "/" + beacon.major.stringValue + "/" + beacon.minor.stringValue;
            if keys.contains({ (contents:String) -> Bool in
                return key == contents
            }) {
                continue;
            }
            beaconDict["uuid"] = beacon.proximityUUID.UUIDString;
            beaconDict["major"] = beacon.major.stringValue;
            beaconDict["minor"] = beacon.minor.stringValue;
            beaconArray.append(beaconDict);
            keys.append(key);
        }
        if keys.count == 0 {
            return
        }
        var requestBody = [String:AnyObject]();
        requestBody["beacons"] = beaconArray;
        
        if let currentRequest = boardsBeaconsRequest {
            currentRequest.response(completionHandler: { (request:NSURLRequest?, response:NSHTTPURLResponse?, data:NSData?, error:NSError?) -> Void in
                self.onBeaconsDiscovered(beacons)
            })
        } else {
            let url = "http://192.168.252.129:8080/noticeboard/";
            let req = NSURLRequest(URL: NSURL(string: url)!)
            do {
                let json = try NSString(data: NSJSONSerialization.dataWithJSONObject(requestBody, options: .PrettyPrinted), encoding: NSUTF8StringEncoding)
                print(json)
            } catch {
                print("JSON error")
            }
            self.boardsBeaconsRequest = request(.POST, url, parameters: requestBody, encoding: ParameterEncoding.JSON, headers: ["Content-Type":"application/json", "X-CLIENT-NB":"App"]).responseJSON { (response:Response<AnyObject, NSError>) -> Void in
                //print(response.result.value)
                
                if response.result.isSuccess {
                    self.retrievedBeacons.appendContentsOf(keys)
                    self.onBoardsRetrievedForBeacons(beacons, boards: response.result.value);
                } else {
                    print(response.result.error!.userInfo);
                }
            }
        }
    }
    
    func onBoardsRetrievedForBeacons(beacons:[CLBeacon], boards:AnyObject?) {
        if let boards = boards as? NSArray {
            for board in boards {
                if let board = board as? NSDictionary {
                    print(board.debugDescription);
                }
            }
        }
        
    }
    
}
