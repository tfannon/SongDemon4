//
//  Extensions.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/10/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//
import MediaPlayer


extension String {
    var length: Int { return self.characters.count }  // Swift 1.2
}


extension MPMediaItem {
    var songInfo: String {
        //return "\(self.albumArtist ?? "") - \(self.albumTitle!) : \(self.albumTrackNumber). \(self.title!)"
        return "\(self.albumArtist ?? "") - \(self.albumTitle ?? "") : \(self.albumTrackNumber). \(self.title ?? "")"
    }
    
    var year : String {
        let yearAsNum = self.value(forProperty: "year") as! NSNumber
        if yearAsNum.isKind(of: NSNumber.self) {
            return yearAsNum == 0 ? "" : "\(yearAsNum.int32Value)"
        }
        return ""
    }
    
    func getArtworkWithSize(_ frame : CGSize) -> UIImage? {
        //return self.artwork != nil ? self.artwork!.imageWithSize(frame) : nil
        return self.artwork?.image(at: frame)
    }
    
    var playTime : TimeStruct {
        get {
            let totalPlaybackTime = Int(self.playbackDuration)
            let hours = (totalPlaybackTime / 3600)
            let mins = ((totalPlaybackTime/60) - hours*60)
            let secs = (totalPlaybackTime % 60 )
            return TimeStruct(hours: hours, mins: mins, seconds: secs)
        }
    }
    
    var safeArtist: String {
        if let ret = self.albumArtist {
            return ret
        }
        if let ret = self.artist {
            return ret
        }
        return ""
    }
    
    var safeAlbum: String {
        if let ret = self.albumTitle {
            return ret
        }
        return ""
    }
    
    var safeTitle: String {
        return self.title ?? ""
//        if let ret = self.title {
//            return ret
//        }
//        return ""
    }
    
    //provides a way to persist
    var hashKey: String {
        return self.persistentID.description;
    }
    
    var albumHashKey : String {
        return self.albumPersistentID.description;
    }
    
    var artistHashKey: String {
        return self.artistPersistentID.description
    }
}

extension UIViewController {
    func alert(title: String? = nil, message:String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

extension UISlider {
    var timeValue : TimeStruct {
        get {
            return TimeStruct(totalSeconds: self.value)
        }
        set(time) {
            self.value = Float(time.totalSeconds)
        }
    }
}

extension Array {
    func find(_ includedElement: (Element) -> Bool) -> Int? {
        for (idx, element) in self.enumerated() {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }

    //shuffle the array in place
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}

extension Dictionary {
    init(_ elements: [Element]){
        self.init()
        for (k, v) in elements {
            self[k] = v
        }
    }
    
    func map<U>(_ transform: (Value) -> U) -> [Key : U] {
        return Dictionary<Key, U>(self.map({ (key, value) in (key, transform(value)) }))
    }
    
    func map<T : Hashable, U>(_ transform: (Key, Value) -> (T, U)) -> [T : U] {
        return Dictionary<T, U>(self.map(transform))
    }
    
    func filter(_ includeElement: (Element) -> Bool) -> [Key : Value] {
        return Dictionary(self.filter(includeElement))
    }
    
    func reduce<U>(_ initial: U, combine: (U, Element) -> U) -> U {
        return self.reduce(initial, combine: combine)
    }
}
