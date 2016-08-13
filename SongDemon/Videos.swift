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

    var State = VideoState.fetching
    var jsonVideos : JSON? = nil
    //this signals the the catched list has changed and the VideoListController will need to repaint
    var NeedsRefresh = true
    //we store this because if the one coming in is the same, its a noop
    var CurrentUrl = ""
  
    
    class func fetchVideosFor(_ song: MPMediaItem?) {
        guard let item = song else { return }
        
        gVideos.State = .fetching
        
        let query = Utils.inSimulator ?
            "Goatwhore In Deathless Tradition" :
            "\(item.safeArtist) \(item.safeTitle)"
        
        var urlStr = "https://www.googleapis.com/youtube/v3/search?key=\(apiKey)&part=snippet&q='\(query)'&type=video&order=viewCount&maxResults=\(maxResults)"

        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        //if there is no fetched url yet or the url is different than last one
        if gVideos.CurrentUrl.isEmpty || gVideos.CurrentUrl != urlStr {
            print("Loading google json async for: \(query)")
            
            Alamofire.request(urlStr, withMethod: .get)
                .responseString{ response in
                    guard response.result.isSuccess
                        else {
                            gVideos.State = .notAvailable
                            gVideos.NeedsRefresh = true
                            return
                        }
                    var json = JSON(data: response.data!)
                    
                    gVideos.jsonVideos = json
                    gVideos.State = .available
                    gVideos.NeedsRefresh = true
                    
                    var items = json["items"].array!
                    if items.count == 0 {
                        return;
                    }
                    let currentVid = items[0]
                    let id = currentVid["id"]["videoId"].string!
                    
                    let vc = RootController.getPlayVideoController()
                    
                    let url = "https://www.youtube.com/watch?v=\(id)"
                    let artworkUrl = currentVid["snippet"]["thumbnails"]["default"]["url"].string!
                    vc.loadVideo(url, artworkUrl: artworkUrl)
                    gVideos.CurrentUrl = urlStr
            }
        }
        else {
            print("using cached google json")
        }
    }
}

