//
//  YouTubeVideo.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/13/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//


class YouTubeVideo {
    var id: String!
    var title: String!
    var artist: String!
    var artworkUrl: String!

    var bringIntoLibrary: Bool = false
    
    var url: String {
        get {
            return "https://www.youtube.com/watch?v=\(self.id!)"
        }
    }
    
    init() {
    }
    
    init(json: JSON) {
        self.id = json["id"]["videoId"].string!
        self.artworkUrl = json["snippet"]["thumbnails"]["default"]["url"].string!
        self.title = json["snippet"]["title"].string!
    }
    
    init(id: String, artist: String, title: String, artworkUrl: String) {
        self.id = id
        self.artist = artist
        self.title = title
        self.artworkUrl = artworkUrl
    }
//    class func fromJson(jsonString: String) -> YouTubeVideo? {
//        let json = JSON(jsonString)
//        
//        let video = YouTubeVideo()
//        video.id = id
//        video.title = title
//        return video
//    }
    
}

