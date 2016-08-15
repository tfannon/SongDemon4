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
    
    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the view.
    
    func bindSizeTo(view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let viewsDictionary = ["subView": self]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|", options: NSLayoutFormatOptions.alignAllTop, metrics: nil, views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|", options: NSLayoutFormatOptions.alignAllLeft, metrics: nil, views: viewsDictionary))
    }
}
