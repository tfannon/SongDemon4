//
//  VideoLibrary.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/13/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//
import ObjectMapper

let VIDEOS = "Videos"

class VideoLibrary: Mappable {
    static let sharedInstance = VideoLibrary()
    
    var videos = [String:Video]()
    
    private init() {
        self.load()
    }
    
    required init?(_ map: Map) {
    }
    
    func mapping(_ map: Map) {
        videos <- map["videos"]
    }
    
    class func addVideo(url: String, artist: String, title: String) -> Video {
        let v = Video(artist: artist, title: title, url: url)
        sharedInstance.videos[url] = v
        return v
    }
    
    class func addVideo(url: String, video: Video) {
        sharedInstance.videos[url] = video
    }
    
    
    class func getVideo(url: String) -> Video? {
        return sharedInstance.videos[url]
    }
    
    class func toJson(prettyPrint: Bool = false) -> String {
        let json = Mapper().toJSONString(sharedInstance, prettyPrint: prettyPrint)
        return json!
    }
    
    func fromJson(jsonString: String) -> VideoLibrary? {
        return Mapper<VideoLibrary>().map(jsonString)
    }
    
    class func save() {
        let defaults = Utils.AppGroupDefaults
        let json = VideoLibrary.toJson()
        defaults.set(json, forKey: VIDEOS)
    }
    
    private func load() {
        let defaults = Utils.AppGroupDefaults
        if let json = defaults.string(forKey: VIDEOS),
            let library = self.fromJson(jsonString: json) {
            self.videos = library.videos
        }
    }
    
    class func reload() {
        sharedInstance.load()
    }
}

