//
//  BoardViewController.swift
//  Hack24
//
//  Created by Adam Mitchell on 19/03/2016.
//  Copyright © 2016 MultiPie. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import KYDrawerController

private let standardMargin:CGFloat = 16;

class BoardViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containView: UIView!
    
    var selectedBoard:Board? {
        didSet {
            refresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = AppDelegate.boardsInteractor.getSelectedBoard().name
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1;
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "home_icon")?.imageWithRenderingMode(.AlwaysOriginal), style: .Plain, target: self, action: Selector("openDrawer"))
        
    }
    
    override func viewWillAppear(animated: Bool) {
        refresh()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("refresh"), name: NBNewBoardSelected, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func openDrawer() {
        if let drawer = self.parentViewController?.parentViewController as? KYDrawerController {
            drawer.setDrawerState(.Opened, animated: true);
        }
    }
    
    func refresh() {
        let board = AppDelegate.boardsInteractor.getSelectedBoard()
        let id = board.id
        self.title = AppDelegate.boardsInteractor.getSelectedBoard().name
        AppDelegate.boardsInteractor.getBoardMessages(id).responseJSON { (response:Response<AnyObject, NSError>) -> Void in
            print(response.result.value)
            var messages = [Notice]()
            if let array = response.result.value as? NSArray {
                for element in array {
                    if let dict = element as? NSDictionary {
                        if let message = Notice(json: dict) {
                            messages.append(message);
                        }
                    }
                }
            }
            var startTile:Tile? = nil;
            var tiles = [Tile]()
            for var i = 0; i < messages.count; i++ {
                let view = CardView();
                let message = messages[i];
                
                view.layer.masksToBounds = false;
                view.layer.shadowOffset = CGSizeMake(-3.75, 5);
                view.layer.shadowRadius = 5;
                view.layer.shadowOpacity = 0.5;
                view.layer.shadowColor = UIColor.blackColor().CGColor
                
                view.clickHandler = { Void in
                    if let fileUrl = message.file, let url = NSURL(string: fileUrl) {
                        self.presentAssetInterface(url);
                    }
                }
                view.title.text = message.title
                view.imageView.image = nil;
                view.contentsLabel.text = message.text
                if let imageFile = message.thumbnail {
                    // request(imageFile).
                    request(.GET, imageFile).responseImage(completionHandler: { (response:Response<Image, NSError>) -> Void in
                        view.imageView.image = response.result.value
                    })
                }
                
                view.translatesAutoresizingMaskIntoConstraints = false;
                view.backgroundColor = UIColor.random();
                if let _ = startTile {
                    let newTile:Tile;
                    if i % 2 == 0 {
                        newTile = tiles[i - 2].bottom(view)
                    } else {
                        newTile = tiles[i-1].right(view)
                    }
                    newTile.rect.size.width = 0.8;
                    if (i == 1) {
                        newTile.rect.size.height = 0.5;
                    } else {
                        newTile.rect.size.height = 1;
                    }
                    
                    tiles.append(newTile)
                } else {
                    startTile = Tile(view: view)
                    startTile?.rect.size.height = 1;
                    startTile?.rect.size.width = 0.8;
                    tiles.append(startTile!)
                }
            }
            self.layoutViews(tiles);
        }
    }
    
    private func addTile(tile:Tile?) {
        if let tile = tile where tile.view.superview != self.containView {
            self.containView.addSubview(tile.view);
            addTile(tile.leftTile)
            addTile(tile.rightTile)
            addTile(tile.belowTile)
            addTile(tile.aboveTile)
        }
        
    }
    
    private func layoutViews(positions:[Tile]) {
        for child in containView.subviews {
            child.removeFromSuperview()
        }
        
        var rightEdge:Tile?
        var bottomEdge:Tile?
        
        for tile in positions {
            addTile(tile)
            print("Placing tile at pos " + NSStringFromCGRect(tile.rect))
            scrollView.addConstraint(constraint(item: tile.view, attribute: .Width, toItem:scrollView, multiplier:tile.rect.size.width, constant:-standardMargin * 2))
//            scrollView.addConstraint(constraint(item: tile.view, attribute: .Height, toItem:scrollView, multiplier:tile.rect.size.height, constant:-standardMargin * 2))
            if let left = tile.leftTile {
                containView.addConstraint(horizontalConstraint(left.view, right: tile.view))
            } else {
                containView.addConstraint(constraint(item: tile.view, attribute: .LeadingMargin, relatedBy: .Equal, toItem: containView, attribute: .LeadingMargin, multiplier: 1, constant: standardMargin))
            }
            
            if let right = tile.rightTile {
                containView.addConstraint(horizontalConstraint(tile.view, right: right.view))
            } else {
                if let edge = rightEdge {
                    if CGRectGetMaxX(tile.rect) > CGRectGetMaxX(edge.rect) {
                        rightEdge = tile
                    }
                } else {
                    rightEdge = tile
                }
            }
            
            if let top = tile.aboveTile {
                containView.addConstraint(verticalConstraint(top.view, bottom: tile.view))
            } else {
                containView.addConstraint(constraint(item: tile.view, attribute: .TopMargin, relatedBy: .Equal, toItem: containView, attribute: .TopMargin, multiplier: 1, constant: standardMargin))
            }
            
            if let bottom = tile.belowTile {
                containView.addConstraint(verticalConstraint(tile.view, bottom: bottom.view))
            } else {
                if let edge = bottomEdge {
                    if CGRectGetMaxY(tile.rect) > CGRectGetMaxY(edge.rect) {
                        bottomEdge = tile;
                    }
                } else {
                    bottomEdge = tile;
                }
                
            }
        }
        
        if let edge = rightEdge {
            containView.addConstraint(constraint(item: containView, attribute: .TrailingMargin, relatedBy: .Equal, toItem: edge.view, attribute: .TrailingMargin, multiplier: 1, constant: standardMargin))
        }
        if let edge = bottomEdge {
            containView.addConstraint(constraint(item: containView, attribute: .BottomMargin, relatedBy: .Equal, toItem: edge.view, attribute: .BottomMargin, multiplier: 1, constant: standardMargin))
        }
        
        self.view.layoutIfNeeded()
        
    }
    
    private func verticalConstraint(top:UIView, bottom:UIView) -> NSLayoutConstraint {
        return constraint(item: bottom, attribute: .Top, relatedBy: .Equal, toItem: top, attribute: .Bottom, multiplier: 1, constant: standardMargin)
    }
    
    private func horizontalConstraint(left:UIView, right:UIView) -> NSLayoutConstraint {
        return constraint(item: right, attribute: .Left, relatedBy: .Equal, toItem: left, attribute: .Right, multiplier: 1, constant: standardMargin)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.scrollView.subviews {
            print(view.frame)
        }
    }
    
    private func getTileBoundaries(tile:Tile) -> [CGFloat] {
        let tileMinX = CGRectGetMinX(tile.rect);
        let tileMinY = CGRectGetMinY(tile.rect);
        let tileMaxX = CGRectGetMaxX(tile.rect);
        let tileMaxY = CGRectGetMaxY(tile.rect);
        
        return [tileMinX, tileMinY, tileMaxX, tileMaxY];
    }
    
    private func presentAssetInterface(url:NSURL) {
        UIApplication.sharedApplication().openURL(url);
    }
    
}

extension BoardViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.containView;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
}

class Tile {
    var rect:CGRect = CGRect()
    let view:UIView!
    
    var rightTile:Tile? = nil
    var leftTile:Tile? = nil
    var aboveTile:Tile? = nil
    var belowTile:Tile? = nil
    
    private init(view:UIView) {
        self.view = view;
    }
    
    private init(view:UIView, tile:Tile) {
        self.view = view;
        rect.origin.x = tile.rect.origin.x;
        rect.origin.y = tile.rect.origin.y;
        rect.size.width = tile.rect.width;
        rect.size.height = tile.rect.height;
    }
    
    static func start(view:UIView) -> Tile {
        return Tile(view: view)
    }
    
    func right(view:UIView) -> Tile {
        let tile = Tile(view: view, tile: self);
        tile.rect.origin.x = self.rect.origin.x + self.rect.size.width;
        tile.rect.origin.y = self.rect.origin.y;
        self.rightTile = tile;
        tile.leftTile = self;
        tile.aboveTile = self.aboveTile?.rightTile
        self.aboveTile?.rightTile?.belowTile = tile
        return tile;
    }
    
    func bottom(view:UIView) -> Tile {
        let tile = Tile(view: view, tile: self);
        tile.rect.origin.x = self.rect.origin.x;
        tile.rect.origin.y = self.rect.origin.y + self.rect.size.height
        self.belowTile = tile;
        tile.aboveTile = self;
        return tile
    }
}
