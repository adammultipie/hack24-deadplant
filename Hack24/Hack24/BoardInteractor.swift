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

let NBBeaconsDiscovered = "NBBeaconsDiscovered"
let NBNewBoardSelected = "NBNewBoardSelected"

class BoardsInteractor {
    
    var retrievedBeacons = [String]();
    
    var boardsBeaconsRequest:Request?;
    
    var discoveredBeacons = [CLBeacon]();
    
    private var selectedBoard:Board?
    
    func selectNewBoard(board:Board) {
        self.selectedBoard = board
        NSNotificationCenter.defaultCenter().postNotificationName(NBNewBoardSelected, object: board)
    }
    
    func getSelectedBoard() -> Board {
        if let _ = self.selectedBoard {
            return self.selectedBoard!
        } else {
            let dict = ["pk":2, "name":"HACK\u{00b2}\u{2074}"];
            return Board(json: dict)!
        }
    }
    
    func getBoardsForNearbyBeacons() -> Request {
        var beaconArray = [[String:String]]();
        //var boolean =
        for beacon in self.discoveredBeacons {
            var beaconDict = [String:String]();
            beaconDict["uuid"] = beacon.proximityUUID.UUIDString;
            beaconDict["major"] = beacon.major.stringValue;
            beaconDict["minor"] = beacon.minor.stringValue;
            beaconArray.append(beaconDict);
        }
        
        var requestBody = [String:AnyObject]();
        requestBody["beacons"] = beaconArray;
        
        if let currentRequest = boardsBeaconsRequest {
            return currentRequest
        } else {
            let url = "http://192.168.252.129:8080/api/noticeboard/";
            self.boardsBeaconsRequest = request(.POST, url, parameters: requestBody, encoding: ParameterEncoding.JSON, headers: ["Content-Type":"application/json", "X-CLIENT-NB":"App"]).responseJSON { (response:Response<AnyObject, NSError>) -> Void in
                //print(response.result.value)
                
                if response.result.isSuccess {
                    self.onBoardsRetrievedForBeacons(self.discoveredBeacons, boards: response.result.value);
                } else {
                    print(response.result.error!.userInfo);
                }
                self.boardsBeaconsRequest = nil;
            }
        }
        return self.boardsBeaconsRequest!
    }
    
    func onBeaconsDiscovered(beacons:[CLBeacon]) {
        var beaconArray = [[String:String]]();
        //var boolean =
        for beacon in beacons {
            var beaconDict = [String:String]();
            let key = beacon.proximityUUID.UUIDString + "/" + beacon.major.stringValue + "/" + beacon.minor.stringValue;
            if self.retrievedBeacons.contains({ (contents:String) -> Bool in
                return key == contents
            }) {
                continue;
            }
            beaconDict["uuid"] = beacon.proximityUUID.UUIDString;
            beaconDict["major"] = beacon.major.stringValue;
            beaconDict["minor"] = beacon.minor.stringValue;
            beaconArray.append(beaconDict);
            self.retrievedBeacons.append(key);
            discoveredBeacons.append(beacon);
            NSNotificationCenter.defaultCenter().postNotificationName(NBBeaconsDiscovered, object: nil);
        }
    }
    
    func isRetrievingBeacons() -> Bool {
        return self.boardsBeaconsRequest != nil
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
    
    func getBoardMessages(id:String) -> Request {
        let url = "http://192.168.252.129:8080/api/noticeboard/" + id + "/messages";
        return request(.GET, url, parameters: nil, encoding: .JSON, headers: ["Authorization": "Token eee5f4a34a581f08b6a63b416521507cf4c6cbba"])
    }
    
}
