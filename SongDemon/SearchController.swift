//
//  SeachController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 11/27/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import MediaPlayer

class SearchController: UITabBarController {

    @IBOutlet var btnCancel: UIButton!
    
    @IBAction func handleCancelClicked(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
        //put the VideoController back into normal mode
        YouTubeVideoManager.videoControllerMode = .default
    }
    
    var currentlyPlayingArtist: String?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //debug
        let mode = YouTubeVideoManager.videoControllerMode
        print ("SearchController:\(#function):\(mode)")
        
        btnCancel.center = self.tabBar.center
        let f = btnCancel.frame
        btnCancel.frame = CGRect(x: f.origin.x - 10, y: f.origin.y - 5, width: f.width + 20, height: f.height)
        self.view.addSubview(btnCancel)
        
        //swiping up allows user to select playlist
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(SearchController.handleCancelClicked(_:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        YouTubeVideoManager.videoControllerMode = .library

        //debug
        let mode = YouTubeVideoManager.videoControllerMode
        print ("SearchController:\(#function):\(mode)")
        
        let searchAlbumController = self.viewControllers![1] as! SearchAlbumController
        //a song may be playing that is not in our library
        if currentlyPlayingArtist != nil {
            searchAlbumController.selectedArtist = currentlyPlayingArtist!
            if LibraryManager.hasArtist(currentlyPlayingArtist!) {
                searchAlbumController.artistSelectedWithPicker = false
                self.selectedIndex = 1
            }
        }
        else {
            self.selectedIndex = 0
        }
    }
}
