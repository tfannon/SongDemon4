//
//  Utils.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 7/8/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit


class Utils {
    static var MIGRATED : String = "Migrated"

    class var inSimulator : Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
    }
    
    //app group has been created in the ios provisioning portal
    //was using this to communicate with the watch
    static var AppGroupDefaults : UserDefaults = {
        let groupId = "group.com.crazy8dev.songdemon"
        let defaults = UserDefaults(suiteName: groupId)
        return defaults!
    }()
    
    //generates random number between 0 and max-1
    class func random(_ max : Int) -> Int {
        return Int(arc4random_uniform((UInt32(max))))
    }
}

class Stopwatch {
    
    private var timer = Date()
    private var title : String = ""

    class func start() -> Stopwatch {
        return Stopwatch.start("")
    }
    
    class func start(_ title : String) -> Stopwatch {
        let sw = Stopwatch()
        sw.title = title
        if !title.isEmpty {
            print(title + " started")
        }
        sw.start()
        return sw
    }

    func start() {
        timer = Date()
    }
    
    func stop() -> Double {
        return stop("")
    }
    
    func stop(_ message : String) -> Double {
        let ret = Date().timeIntervalSince(timer) * 1000
        if !title.isEmpty {
            print("\(title): \(message) completed in \(Int(ret))ms")
        }
        return ret
    }
    
    func takeTiming(_ message : String) -> Double {
        let ret = stop(message)
        start()
        return ret
    }
    
}

extension URL {
    public func getImage() -> UIImage? {
        var image : UIImage? = nil
        if let data = NSData(contentsOf: self) {
            image = UIImage(data: data as Data)
        }
        return image
    }
    public func getImageAsync(completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        //todo: asynch fetch with cache
        let task = URLSession.shared.dataTask(with: self) { data, response, error in
            var image : UIImage? = nil
            if error == nil {
                image = UIImage(data: data!)
            }
            completion(image, error)
        }
        task.resume()
    }
}



