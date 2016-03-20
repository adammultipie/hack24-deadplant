//
//  BeaconInteractor.swift
//  Hack24
//
//  Created by Adam Mitchell on 19/03/2016.
//  Copyright © 2016 MultiPie. All rights reserved.
//

import Foundation
import CoreLocation

typealias BeaconRequest = ([CLBeaconRegion]?) -> Void

class BeaconInteractor: NSObject {
    
    let locationManager = CLLocationManager()
    var boardInteractor:BoardsInteractor?
    var beacons:[CLBeaconRegion]?;
    
    func start() {
        self.locationManager.delegate = self;
        self.locationManager.requestAlwaysAuthorization();
        getBeacons { (regions:[CLBeaconRegion]?) -> Void in
            self.beacons = regions;
            if let beacons = self.beacons {
                for region in beacons {
                    self.locationManager.startMonitoringForRegion(region);
                    self.locationManager.startRangingBeaconsInRegion(region);
                }
            }
            
        }
    }
    
    func stop() {
        if let beacons = self.beacons {
            for beacon in beacons {
                self.locationManager.startMonitoringForRegion(beacon)
                self.locationManager.startRangingBeaconsInRegion(beacon)
            }
        }
    }
    
    func getBeacons(callback:BeaconRequest) {
        let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "96B0EF22-19B2-4EBF-9CD1-868FA48DFBD8")!, identifier: "beacon")
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            callback([region])
        }
    }
}

extension BeaconInteractor: CLLocationManagerDelegate {
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Failed monitoring region: \(error.description)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager failed: \(error.description)")
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        self.boardInteractor?.onBeaconsDiscovered(beacons);
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region " + region.description)
    }
    
}

