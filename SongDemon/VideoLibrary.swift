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
    
    class func getVideos() -> [Video] {
        return sharedInstance.videos.values.map { x in x }
    }
    
    class func addVideo(id: String, artist: String, title: String) -> Video {
        let v = Video(id: id, artist: artist, title: title)
        sharedInstance.videos[id] = v
        return v
    }
    
    class func addVideo(video: Video) {
        sharedInstance.videos[video.id] = video
        sharedInstance.save()
    }
    
    class func removeVideo(video: Video) {
        sharedInstance.videos[video.id] = nil
        sharedInstance.save()
    }
    
    class func contains(id: String) -> Bool {
        return sharedInstance.videos[id] != nil
    }
    
    class func get(id: String) -> Video? {
        return sharedInstance.videos[id]
    }
    
    class func toJson(prettyPrint: Bool = false) -> String {
        let json = Mapper().toJSONString(sharedInstance, prettyPrint: prettyPrint)
        return json!
    }
    
    func fromJson(jsonString: String) -> VideoLibrary? {
        return Mapper<VideoLibrary>().map(jsonString)
    }
    
    //don't expose this to outside.  persistance should be handled internally to this class
    private func save() {
        let defaults = Utils.AppGroupDefaults
        let json = VideoLibrary.toJson()
        defaults.set(json, forKey: VIDEOS)
    }
    
    private func load() {
        let defaults = Utils.AppGroupDefaults
        print ("loading videos")
        if let json = defaults.string(forKey: VIDEOS),
            let library = self.fromJson(jsonString: json) {
            self.videos = library.videos
            self.videos.forEach { result in
                print (result.value.title)
            }
        }
    }
    
    class func reload() {
        sharedInstance.load()
    }
    
    //this will take the return of the YouTube API query and return a bunch of parsed videos
    //the artist came from the current song and has to be supplied by the caller
    class func fromYouTube(json: JSON, artist: String = "") -> [Video] {
        return json["items"].array!.map {
            let vid = Video(json: $0)
            vid.artist = artist
            return vid
        }
    }
}

