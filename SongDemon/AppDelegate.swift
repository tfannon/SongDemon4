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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        setupAppearance()
        //FBLoginView.self
        let defaults = Utils.AppGroupDefaults
        defaults.set("Hello from SongDemon", forKey: "SongDemonMain")
        if let foo = defaults.object(forKey: "SongDemonMain") as? String {
            print (foo)
        }
        
        if let bar = defaults.object(forKey: "SongDemonChat") as? String {
            print (bar)
        }
        
        Async.background {
            LibraryManager.scanLibrary()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        //let wasHandled = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
        //return wasHandled
        return true;
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
//        FBAppEvents.activateApp()
//        FBAppCall.handleDidBecomeActive()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //LibraryManager.serializeCurrentPlaylist()
        //FBSession.activeSession().close()
    }
    
    func setupAppearance() {
        UISlider.appearance().thumbTintColor = UIColor.red
        UISlider.appearance().setThumbImage(UIImage(named:"pentagram.png"), for: UIControlState())
        UISlider.appearance().setMaximumTrackImage(UIImage(named: "slider_maximum.png"), for: UIControlState())
        UISlider.appearance().setMinimumTrackImage(UIImage(named: "slider_minimum.png"), for: UIControlState())
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
}

