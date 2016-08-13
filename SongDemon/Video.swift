//
//  Video.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/13/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//
import ObjectMapper

class Video: Mappable {
    var title: String!
    var artist: String!
    var url: String!
    var bringIntoLibrary: Bool = false
    
    init() {
    }
    
    init(artist: String, title: String, url: String) {
        self.artist = artist
        self.title = title
        self.url = url
    }
    
    
    required init?(_ map: Map) {
    }
    
    func mapping(_ map: Map) {
        title <- map["title"]
        artist <- map["artist"]
        url <- map["url"]
    }
    
    class func fromJson(jsonString: String) -> Video? {
        return Mapper<Video>().map(jsonString)
    }
    
}


