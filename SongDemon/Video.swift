//
//  Video.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/13/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//
import ObjectMapper

struct Artwork {
    var url: String
    var height: Int
    var width: Int
    init(_ json: JSON) {
       self.url = json["snippet"]["thumbnails"]["high"]["url"].string!
       self.height = json["snippet"]["thumbnails"]["high"]["height"].int!
       self.width = json["snippet"]["thumbnails"]["high"]["width"].int!
    }
}

class Video: Mappable {
    var id: String = ""
    var title: String = ""
    var artist: String = ""
    var artworkHigh: Artwork!   //todo: convert others to this
    
    private var _artworkUrl : String = ""
    var artworkUrl: String {
        get {
            // fallback to the "standard" img URL if one is not supplied
            // (usu. for test data only)
            if (_artworkUrl.isEmpty && !id.isEmpty) {
                return "https://img.youtube.com/vi/\(self.id)/0.jpg"
            }
            else {
                return _artworkUrl
            }
        }
        set {
            _artworkUrl = newValue
        }
    }
    
    var bringIntoLibrary: Bool = false
    
    var url: String {
        get {
            return "https://www.youtube.com/watch?v=\(self.id)"
        }
    }
    
    init() {
    }
    
    //this will initialize it from youtube api
    init(json: JSON) {
        initialize(
            id: json["id"]["videoId"].string!,
            artist: json["snippet"]["thumbnails"]["default"]["url"].string!,
            title: json["snippet"]["title"].string!,
            artworkUrl: "")
        
        //todo: unify this all
        artworkHigh = Artwork(json)
    }
    
    init(id: String, artist: String, title: String, artworkUrl: String = "") {
        initialize(id: id, artist: artist, title: title, artworkUrl: artworkUrl)
    }
    
    required init?(_ map: Map) {
    }
    
    private func initialize(id: String, artist: String, title: String, artworkUrl: String) {
        self.id = id
        self.artist = artist
        self.title = title
        self.artworkUrl = artworkUrl
    }
    
    func mapping(_ map: Map) {
        id <- map["id"]
        title <- map["title"]
        artist <- map["artist"]
        artworkUrl <- map["artworkUrl"]
    }
    
    class func fromJson(jsonString: String) -> Video? {
        return Mapper<Video>().map(jsonString)
    }
    
    func toJson(prettyPrint: Bool = true) -> String {
        return Mapper().toJSONString(self, prettyPrint: prettyPrint)!
    }
    
    var cachedImage: UIImage? 
}


