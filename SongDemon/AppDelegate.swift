//
//  AppDelegate.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 6/18/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Alamofire


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    
    func testVideos() {
        _ = VideoLibrary.addVideo(id: "5C-W3Tq-zgM", artist: "Inquisition", title: "Power From the Center of the Cosmic Black Spiral")
        
        _ = VideoLibrary.addVideo(id: "w5qmjNe7RVE", artist: "Sleep", title: "SLEEP live at Hellfest 2013")
        
        VideoLibrary.save()
        print (VideoLibrary.sharedInstance.videos.count)
        VideoLibrary.reload()
        print (VideoLibrary.sharedInstance.videos.count)
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        setupAppearance()
        //testVideos()
        Async.background {
            LibraryManager.scanLibrary()
        }
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("entering background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //LibraryManager.serializeCurrentPlaylist()
    }
    
    func setupAppearance() {
        UISlider.appearance().thumbTintColor = UIColor.red
        UISlider.appearance().setThumbImage(UIImage(named:"pentagram.png"), for: UIControlState())
        UISlider.appearance().setMaximumTrackImage(UIImage(named: "slider_maximum.png"), for: UIControlState())
        UISlider.appearance().setMinimumTrackImage(UIImage(named: "slider_minimum.png"), for: UIControlState())
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
}

