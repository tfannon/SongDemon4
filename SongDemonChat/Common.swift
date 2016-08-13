//
//  Common.swift
//  SongDemon
//
//  Created by Adam Rothberg on 8/13/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    func bindSizeToSuperview() {
        
        if let sv = self.superview {
            self.translatesAutoresizingMaskIntoConstraints = false
            let viewsDictionary = ["subView": self]
            sv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|", options: NSLayoutFormatOptions.alignAllTop, metrics: nil, views: viewsDictionary))
            sv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|", options: NSLayoutFormatOptions.alignAllLeft, metrics: nil, views: viewsDictionary))
        }
        else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
    }
    
}
