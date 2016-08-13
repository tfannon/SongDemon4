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

    
    init() {
    }
    
    init(artist: String, title: String) {
        self.artist = artist
        self.title = title
    }
    
    
    required init?(_ map: Map) {
    }
    
    func mapping(_ map: Map) {
        title <- map["title"]
        artist <- map["artist"]
    }
    
    class func fromJson(jsonString: String) -> Video? {
        return Mapper<Video>().map(jsonString)
    }
    
}


