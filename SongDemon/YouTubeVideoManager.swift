//
//  YouTubeVideoManager.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/31/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//
import Foundation
import MediaPlayer
import Alamofire


let apiKey = "AIzaSyDcpJS_v-iEX3eojZ7hsamDVvyrnQAyTdE"
let maxResults = 25

class YouTubeVideoManager {
    
    // MARK: - Singleton
    private static let sharedInstance = YouTubeVideoManager()
    private var videosBySong = [Video]()
    private var videosByArtist = [Video]()
    private var currentSong: MPMediaItem?
    
    private init() {
    }

    class var videosForSong: [Video] {
        return sharedInstance.videosBySong
    }
    
    class var videosForArtist: [Video] {
        return sharedInstance.videosByArtist
    }
    
    class func fetchVideos(for song: MPMediaItem?) {
        guard let item = song else { return }
        if sharedInstance.currentSong != item {
            let songQuery = Utils.inSimulator ? "Goatwhore In Deathless Tradition" :
                "\(item.safeArtist) \(item.safeTitle)"
            let artistQuery = Utils.inSimulator ? "Goatwhore" :
                "\(item.safeArtist) music"
            print("Loading google json async for \(songQuery)")
            fetch(query: songQuery, artist: item.safeArtist) { self.sharedInstance.videosBySong = $0 }
            fetch(query: artistQuery, artist: item.safeArtist) { self.sharedInstance.videosByArtist = $0 }
        }
        else {
            print ("using cached google query")
        }
    }
    
    private class func fetch(query: String, artist: String, completion: (result: [Video]) -> Void) {
        let urlStr = getUrl(from: query)
        Alamofire.request(urlStr, withMethod: .get)
            .responseString { response in
                guard response.result.isSuccess else { return }
                print ("fetched \(query)")
                let json = JSON(data: response.data!)
                completion(result: VideoLibrary.fromYouTube(json: json, artist: artist))
        }
    }
    
    private class func getUrl(from query: String) -> String {
        var urlStr = "https://www.googleapis.com/youtube/v3/search?key=\(apiKey)&part=snippet&q='\(query)'&type=video&order=viewCount&maxResults=\(maxResults)"
        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return urlStr
    }
}

