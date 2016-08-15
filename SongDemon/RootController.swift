//
//  RootController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 7/29/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

class RootController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var mainController: MainController!
    var lyricsController: UIViewController!
    var playlistController: UITableViewController!
    var videoController: UITableViewController!
    var controllers : [UIViewController] = []
    var currentIndex = 1
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self;
        self.dataSource = self;

        mainController = self.storyboard!.instantiateViewController(withIdentifier: "MainController") as! MainController
        lyricsController = self.storyboard!.instantiateViewController(withIdentifier: "LyricsController") 
        playlistController = self.storyboard!.instantiateViewController(withIdentifier: "PlaylistController") as! UITableViewController
        videoController = self.storyboard!.instantiateViewController(withIdentifier: "VideoController") as! UITableViewController

        controllers = [playlistController, mainController, videoController, lyricsController]

        //set the initial controller to the main one
        let viewControllers : [UIViewController] = [mainController]
        self.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        
        findScrollView()
        
        LibraryManager.addListener(self.mainController)
    }
    
    //  this will allow the slider to interpret the touch events and NOT pass them onto the underlying scroll view.  without this, the user is required to hold the slider to activate it before scrolling
    func findScrollView() {
        for x in self.view.subviews {
            if x.isKind(of: UIScrollView.self) {
                let scrollView = x as! UIScrollView
                scrollView.delaysContentTouches = false
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    // MARK: - Page View Controller Data Source
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return controllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }


    //get the controller before the current one displayed
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewControllerBeforeViewController : UIViewController) -> UIViewController? {
        var index = controllers.index(of: viewControllerBeforeViewController)!
        if index == 0  {
            return nil
        }
        index -= 1
        return controllers[index]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewControllerAfterViewController : UIViewController) -> UIViewController? {
        var index = controllers.index(of: viewControllerAfterViewController)!
        index += 1
        if index == controllers.count {
            return nil
        }
        return controllers[index]
    }
    
    class func switchToMainView() {
        let root = UIApplication.shared.keyWindow!.rootViewController as! RootController
        root.currentIndex = 1
        let viewControllers : [UIViewController] = [root.mainController]
        root.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
    }
    
    class func getVideoController() -> VideoController {
        let root = UIApplication.shared.keyWindow!.rootViewController as! RootController
        return root.videoController as! VideoController
    }
    
    class func getLyricsController() -> LyricsController {
        let root = UIApplication.shared.keyWindow!.rootViewController as! RootController
        return root.lyricsController as! LyricsController
    }
    
    class func getPlaylistController() -> PlaylistController {
        let root = UIApplication.shared.keyWindow!.rootViewController as! RootController
        return root.playlistController as! PlaylistController
    }
}
