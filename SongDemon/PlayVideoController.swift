//
//  PlayVideoController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 9/1/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import WebKit

class PlayVideoController : UIViewController {
    
    var myWeb = WKWebView()
    var currentVideoUrl = ""
    var currentArtworkUrl = ""
  
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myWeb.frame=CGRect(x: 0, y: 32, width: 320, height: 560-32)
        self.view.addSubview(myWeb)
    }
    
    func loadVideo(_ videoUrl : String, artworkUrl : String) {
        if !videoUrl.isEmpty && videoUrl != currentVideoUrl {
            print("loading video:\(videoUrl)")
            let requestURL = URL(string: videoUrl)
            let request = URLRequest(url: requestURL!)
            myWeb.load(request)
            currentVideoUrl = videoUrl
            currentArtworkUrl = artworkUrl
        }
        else {
            print("video already loaded")
        }
    }
}
