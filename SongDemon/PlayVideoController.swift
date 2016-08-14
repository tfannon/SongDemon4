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
    var currentVideo: YouTubeVideo?
  
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myWeb.frame=CGRect(x: 0, y: 32, width: 320, height: 560-32)
        self.view.addSubview(myWeb)
    }
    
    func load(_ video: YouTubeVideo) {
        let request = URLRequest(method: .get, urlString: video.url)
        myWeb.load(request)
    }
}
