//
//  Video.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/13/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//
import ObjectMapper

public class Video: Mappable {
    public var id: String = ""
    public var title: String = ""
    public var artist: String = ""
    public var artworkUrl: String = ""
    public var bringIntoLibrary: Bool = false
    
    public var url: String {
        get {
            return "https://www.youtube.com/watch?v=\(self.id)"
        }
    }
    
    public init() {
    }
    
    //this will initialize it from youtube api
    public init(json: String) {
        let json = JSON.parse(json)
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
}


