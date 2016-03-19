//
//  BoardViewController.swift
//  Hack24
//
//  Created by Adam Mitchell on 19/03/2016.
//  Copyright © 2016 MultiPie. All rights reserved.
//

import Foundation
import UIKit

private let standardMargin:CGFloat = 16;

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

class BoardViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        var startTile:Tile? = nil;
        var tiles = [Tile]()
        for var i = 0; i < 3; i++ {
            let view = UIView();
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
        layoutViews(tiles);
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
        let width = scrollView.frame.width - (standardMargin * 2);
        let height = scrollView.frame.height - (standardMargin * 2);
        
        var rightEdge:Tile?
        var bottomEdge:Tile?
        
        for tile in positions {
            addTile(tile)
            print("Placing tile at pos " + NSStringFromCGRect(tile.rect))
//            let tileHeight = height * tile.rect.height;
//            let tileWidth = width * tile.rect.width;
            scrollView.addConstraint(constraint(item: tile.view, attribute: .Width, toItem:scrollView, multiplier:tile.rect.size.width, constant:-standardMargin * 2))
            scrollView.addConstraint(constraint(item: tile.view, attribute: .Height, toItem:scrollView, multiplier:tile.rect.size.height, constant:-standardMargin * 2))
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
    
}

extension BoardViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.containView;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
}
