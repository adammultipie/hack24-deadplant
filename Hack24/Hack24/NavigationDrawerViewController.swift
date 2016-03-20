//
//  NavigationDrawerViewController.swift
//  Hack24
//
//  Created by Adam Mitchell on 20/03/2016.
//  Copyright © 2016 MultiPie. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Alamofire
import KYDrawerController


class NavigationDrawerViewController: UIViewController {
    
    var boards = [Board]()
    
    var selected:Board?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("refresh"), name: NBBeaconsDiscovered, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func refresh() {
        AppDelegate.boardsInteractor.getBoardsForNearbyBeacons().responseJSON { (response:Response<AnyObject, NSError>) -> Void in
            self.boards = [Board]()
            if let array = response.result.value as? NSArray {
                for element in array {
                    if let json = element as? NSDictionary {
                        if let board = Board(json: json) {
                            self.boards.append(board)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func getAlerts() -> [Notice] {
        var alerts = [Notice]()
        for board in self.boards {
            for alert in board.alerts {
                if let _ = alert.title {
                     alerts.append(alert)
                }
            }
        }
        return alerts
    }
    
}

extension NavigationDrawerViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return getAlerts().count
        } else if section == 2 {
            if boards.count == 0 {
                return 0
            }
            return boards.count + 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell
        if indexPath.section == 0 {
            let mapCell = tableView.dequeueReusableCellWithIdentifier("map") as! NavMapCell
            mapCell.mapView.delegate = self;
            cell = mapCell;
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("header") as! NavHeaderCell
            } else {
                let boardCell = tableView.dequeueReusableCellWithIdentifier("board") as! NavBoardCell
                let board = self.boards[indexPath.row-1];
                let selectedBoard = AppDelegate.boardsInteractor.getSelectedBoard();
                if board.id == selectedBoard.id {
                    boardCell.label.textColor = UIColor.watermelonGreen()
                } else {
                    boardCell.label.textColor = UIColor.blackColor()
                }
                boardCell.label.text = board.name
                cell = boardCell
            }
            
        } else {
            let alert = getAlerts()[indexPath.row]
            let alertCell = tableView.dequeueReusableCellWithIdentifier("alert") as! NavAlertCell
            cell = alertCell
            alertCell.label.text = alert.title
        }
        return cell;
    }
}

extension NavigationDrawerViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        var region = MKCoordinateRegion();
        var span = MKCoordinateSpan();
        span.latitudeDelta = 0.005;
        span.longitudeDelta = 0.005;
        var location = CLLocationCoordinate2D();
        location.latitude = userLocation.coordinate.latitude;
        location.longitude = userLocation.coordinate.longitude;
        region.span = span;
        region.center = location;
        mapView.setRegion(region, animated: true);
    }
    
}

extension NavigationDrawerViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 250
        } else {
            return 50
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 250
        } else {
            return 50
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let alerts = getAlerts()[indexPath.row];
            if let file = alerts.file, let url = NSURL(string: file) {
                UIApplication.sharedApplication().openURL(url)
            }
            
        } else if indexPath.section == 2 && indexPath.row > 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true);
            tableView.reloadData()
            let board = self.boards[indexPath.row - 1];
            AppDelegate.boardsInteractor.selectNewBoard(board)
            if let drawer = self.parentViewController as? KYDrawerController {
                drawer.setDrawerState(.Closed, animated: true)
            }
            
        }
    }
}
