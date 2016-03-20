//
//  CardView.swift
//  Hack24
//
//  Created by Adam Mitchell on 19/03/2016.
//  Copyright © 2016 MultiPie. All rights reserved.
//

import UIKit
import AVFoundation

typealias ClickHandler = (Void) -> Void

class CardView: UIView {
    
    var view: UIView!
    let nibName = "CardView"
    
    var clickHandler:ClickHandler?

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentsLabel: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(view)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("onTap")))
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    func onTap() {
        if let handler = clickHandler {
            handler()
        }
    }
    
    @IBAction func onSpeechClicked(sender: AnyObject) {
        let synth = AVSpeechSynthesizer()
        if let text = self.title.text {
            let utterance = AVSpeechUtterance(string: text)
            synth.speakUtterance(utterance)
        }
        if let text = self.contentsLabel.text {
            let contentUtterance = AVSpeechUtterance(string: text)
            synth.speakUtterance(contentUtterance)
        }
        
        
    }
    
}
