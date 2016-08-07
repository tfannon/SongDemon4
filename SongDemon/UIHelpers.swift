//
//  UIHelpers.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 7/9/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import Foundation
import UIKit


class UIHelpers  {
    class func messageBox(_ title:String?=nil, message:String = "") {
        let v = UIAlertView()
        if title != nil {
            v.title = title!
        }
        v.message = message
        v.addButton(withTitle: "Ok")
        v.show()
    }
}
