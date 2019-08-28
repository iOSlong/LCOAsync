//
//  LCLabel.swift
//  LCOAsync
//
//  Created by lxw on 2019/8/27.
//

import UIKit

public class LCLabel: UILabel {
    public func startBlinking() {
        let options : UIViewAnimationOptions = UIViewAnimationOptions(rawValue: UIViewAnimationOptions.repeat.rawValue | UIViewAnimationOptions.autoreverse.rawValue)
        UIView.animate(withDuration: 0.25, delay:0.0, options:options, animations: {
            self.alpha = 0
        }, completion: nil)
    }
    
    public func stopBlinking() {
        alpha = 1
        layer.removeAllAnimations()
    }
}
