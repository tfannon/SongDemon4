//
//  Video.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/13/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//
import ObjectMapper

public class Video: Mappable {
    var id: String = ""
    var title: String = ""
    var artist: String = ""
    var artworkUrl: String = ""
    var bringIntoLibrary: Bool = false
    
    var url: String {
        get {
            return "https://www.youtube.com/watch?v=\(self.id)"
        }
    }
    
    init() {
    }
    
    //this will initialize it from youtube api
    public init(json: JSON) {
        self.id = json["id"]["videoId"].string!
        self.artworkUrl = json["snippet"]["thumbnails"]["default"]["url"].string!
        self.title = json["snippet"]["title"].string!
    }
    
    public init(id: String, artist: String, title: String, artworkUrl: String = "") {
        self.id = id
        self.artist = artist
        self.title = title
        self.artworkUrl = artworkUrl
    }
    
    required public init?(_ map: Map) {
    }
    
    public func mapping(_ map: Map) {
        id <- map["id"]
        title <- map["title"]
        artist <- map["artist"]
        artworkUrl <- map["artworkUrl"]
    }
    
    public class func fromJson(_ jsonString: String) -> Video? {
        return Mapper<Video>().map(jsonString)
    }
    
    //this will take the return of the YouTube API query and return a bunch of parsed videos
    //the artist came from the current song and has to be supplied by the caller
    public class func fromJson(_ json: JSON, artist: String = "") -> [Video] {
        return json["items"].array!.map {
            let vid = Video(json: $0)
            vid.artist = artist
            return vid
        }
    }
}

