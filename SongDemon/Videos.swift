//
//  Videos.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/31/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//
import Foundation
import MediaPlayer
import Alamofire

let gVideos = Videos()
let apiKey = "AIzaSyDcpJS_v-iEX3eojZ7hsamDVvyrnQAyTdE"
let maxResults = 25

enum VideoState {
    case available
    case displayed
    case notAvailable
    case fetching
}

class Videos {

    var state = VideoState.fetching
    //this signals the the catched list has changed and the VideoListController will need to repaint
    var needsRefresh = true
    //we store this because if the one coming in is the same, its a noop
    var currentUrl = ""
    var videos = [YouTubeVideo]()
    
    class func fetchVideos(for song: MPMediaItem?) {
        guard let item = song else { return }
        
        gVideos.state = .fetching
        
        let query = Utils.inSimulator ?
            "Goatwhore In Deathless Tradition" :
            "\(item.safeArtist) \(item.safeTitle)"
        
        var urlStr = "https://www.googleapis.com/youtube/v3/search?key=\(apiKey)&part=snippet&q='\(query)'&type=video&order=viewCount&maxResults=\(maxResults)"

        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        //if there is no fetched url yet or the url is different than last one
        if gVideos.currentUrl.isEmpty || gVideos.currentUrl != urlStr {
            print("Loading google json async for: \(query)")
            gVideos.currentUrl = urlStr
            gVideos.needsRefresh = true
            
            Alamofire.request(urlStr, withMethod: .get)
                .responseString{ response in
                    guard response.result.isSuccess else {
                        gVideos.state = .notAvailable
                        return
                    }
                    let json = JSON(data: response.data!)
                    gVideos.state = .available
                    gVideos.videos = YouTubeVideo.fromJson(json: json, artist: item.safeArtist)
                    if let first = gVideos.videos.first {
                        let vc = RootController.getPlayVideoController()
                        vc.load(first)
                    }
            }
        }
        else {
            print("using cached google json")
        }
    }
}

