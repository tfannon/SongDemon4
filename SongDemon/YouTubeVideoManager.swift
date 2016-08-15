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

enum VideoState {
    case available
    case displayed
    case notAvailable
    case fetching
}


class YouTubeVideoManager {
    
    // MARK: - Singleton
    private static let sharedInstance = YouTubeVideoManager()
    private var videos = [Video]()
    
    private init() {
        //self.load()
    }

    private var currentUrl = ""
    private var state = VideoState.fetching

    //the consumer of this will poll.  returning a positive answer will reset the flag
    private var needsRefresh = true
    private func evaluateRefresh() -> Bool {
        let retVal = needsRefresh && state == .available
        if retVal {
            print ("refreshing videos and resetting flag")
            needsRefresh = false
            return true
        }
        return false
    }
    
    
    class func getVideos() -> [Video] {
        return sharedInstance.videos
    }
    
    class func fetchVideos(for song: MPMediaItem?) {
        guard let item = song else { return }
        
        sharedInstance.state = .fetching
        
        let query = Utils.inSimulator ?
            "Goatwhore In Deathless Tradition" :
            "\(item.safeArtist) \(item.safeTitle)"
        
        var urlStr = "https://www.googleapis.com/youtube/v3/search?key=\(apiKey)&part=snippet&q='\(query)'&type=video&order=viewCount&maxResults=\(maxResults)"

        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        //if there is no fetched url yet or the url is different than last one
        if sharedInstance.currentUrl.isEmpty || sharedInstance.currentUrl != urlStr {
            print("Loading google json async for: \(query)")
            sharedInstance.currentUrl = urlStr
            sharedInstance.needsRefresh = true
            
            Alamofire.request(urlStr, withMethod: .get)
                .responseString { response in
                    guard response.result.isSuccess else {
                        sharedInstance.state = .notAvailable
                        return
                    }
                    let json = JSON(data: response.data!)
                    sharedInstance.state = .available
                    sharedInstance.videos = VideoLibrary.fromYouTube(json: json, artist: item.safeArtist)
                    if let first = sharedInstance.videos.first {
                        RootController.getVideoController().queueVideo(first)
                    }
            }
        }
        else {
            print("using cached google json")
        }
    }
}

