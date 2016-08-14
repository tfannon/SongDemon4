//
//  LyricsController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 7/29/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import WebKit

//had to put key in plist for NSAppTransportSecurity iOS9.0
class LyricsController: UIViewController {

    var webView = WKWebView()
    var currentUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame=CGRect(x: 0, y: 32, width: self.view.frame.width, height: self.view.frame.height-32)
        self.view.addSubview(webView)
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    func loadLyrics(_ url : String) {
        if !url.isEmpty && url != currentUrl {
            //the url may be malformed
            if let requestURL = URL(string: url) {
                print("loading lyrics:\(url)")
                let request = URLRequest(url: requestURL)
                self.webView.load(request)
                currentUrl = url
            }
            else {
                print ("\(url) is not a valid URL")
            }
        }
        else {
            print("lyrics already loaded")
        }
    }
}
