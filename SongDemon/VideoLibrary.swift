//
//  VideoLibrary.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/13/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//
import ObjectMapper
import SwiftyJSON

let VIDEOS = "Videos"

class VideoLibrary: Mappable {
    
    // MARK: - Singleton
    private static let sharedInstance = VideoLibrary()
    
    private var videos = [String:Video]()
    
    private init() {
        self.load()
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        videos <- map["videos"]
    }
    
    class func getAll() -> [Video] {
        return Array(sharedInstance.videos.values)
    }
    
    class func add(id: String, artist: String, title: String, artworkUrl: String = "") -> Video {
        let v = Video(id: id, artist: artist, title: title, artworkUrl: artworkUrl)
        sharedInstance.videos[id] = v
        sharedInstance.save()
        return v
    }
    
    class func add(video: Video) {
        sharedInstance.videos[video.id] = video
        sharedInstance.save()
    }
    

    class func removeAll() {
        sharedInstance.videos.removeAll()
    }
    
    class func remove(video: Video) {
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
        return Mapper<VideoLibrary>().map(JSONString: jsonString)
    }

    // MARK: - persistance - don't expose to outside

    private func save() {
        let defaults = Utils.AppGroupDefaults
        let json = VideoLibrary.toJson()
        defaults.set(json, forKey: VIDEOS)
    }
    
    private func load() {
        let defaults = Utils.AppGroupDefaults
        if let json = defaults.string(forKey: VIDEOS),
            let library = self.fromJson(jsonString: json) {
            self.videos = library.videos
            self.videos.forEach { result in
                print ("\(result.value.id) : \(result.value.title)")
            }
        }
    }
    
    //this will take the result of the YouTube API query and return a bunch of parsed videos
    //the artist came from the current song and has to be supplied by the caller
    class func fromYouTube(json: JSON, artist: String = "") -> [Video] {
        return json["items"].array!.map {
            let vid = Video(json: $0)
            vid.artist = artist
            return vid
        }
    }
    
    class func createTestData() {
        //don't accidentally kill real data
        if Utils.inSimulator {
            sharedInstance.videos.removeAll()
            _ = VideoLibrary.add(id: "2XsEmI0pidA", artist: "Inquisition", title: "Inquisition - Desolate Funeral Chant (Cambridge,MA 4/28/12)", artworkUrl: "https://i.ytimg.com/vi/2XsEmI0pidA/default.jpg")
            _ = VideoLibrary.add(id: "w5qmjNe7RVE", artist: "Sleep", title: "SLEEP live at Hellfest 2013", artworkUrl: "https://i.ytimg.com/vi/w5qmjNe7RVE/default.jpg" )
        }
    }
}

