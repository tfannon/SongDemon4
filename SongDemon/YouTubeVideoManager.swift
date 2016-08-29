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
    private var videoControllerMode = VideoControllerMode.default
    
    private init() {
    }
    
    class var videoControllerMode: VideoControllerMode {
        get {
            return sharedInstance.videoControllerMode
        }
        set {
            sharedInstance.videoControllerMode = newValue
        }
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
    
    //used to test externally
    class func fetch(query: String, artist: String, completion: @escaping (_ result: [Video]) -> Void) {
        let urlStr = getUrl(from: query)
        Alamofire.request(urlStr, withMethod: .get)
            .responseString { response in
                guard response.result.isSuccess else { return }
                guard let data = response.data else { return }
                print ("fetched \(query)")
                //let theString = String(data: response.data!, encoding:String.Encoding.utf8)
                //print (theString)
                let jsonObject = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print (jsonObject)
                let json = JSON(data: response.data!)
                completion(VideoLibrary.fromYouTube(json: json, artist: artist))
        }
    }
    
//    class func foo() {
//        let URL = "https://raw.githubusercontent.com/tristanhimmelman/AlamofireObjectMapper/d8bb95982be8a11a2308e779bb9a9707ebe42ede/sample_json"
//        Alamofire.request(URL, withMethod: .get)
//            
//            .responseObject { (response: Response<Video, NSError>) in
//            
//            let weatherResponse = response.result.value
//            print(weatherResponse?.location)
//            
//            if let threeDayForecast = weatherResponse?.threeDayForecast {
//                for forecast in threeDayForecast {
//                    print(forecast.day)
//                    print(forecast.temperature)           
//                }
//            }
//        }
//    }
    
    //used to test externally
    class func fetch2(type: QueryType, query: String, artist: String, completion: @escaping (_ result: [Video]) -> Void) {
        let urlStr = getUrl2(type: type, query: query)
        Alamofire.request(urlStr, withMethod: .get)
            //.responseObject { _ in }
            .responseString { response in
                //guard response.result.isSuccess else { return }
                guard response.data != nil else { return }
                print ("fetched \(urlStr)")
                let json = JSON(data: response.data!)
                //let jsonObject = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
                //print (jsonObject)
                completion(VideoLibrary.fromYouTube(json: json, artist: artist))
        }
    }
    
    enum QueryType: String {
        case currentSong
        case mostPopular
        case live
        case recent
    }
    
    
    private class func getUrl(from query: String) -> String {
        var urlStr = "https://www.googleapis.com/youtube/v3/search?key=\(apiKey)&part=snippet&q='\(query)'&type=video&order=viewCount&maxResults=\(maxResults)"
        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return urlStr
    }

    //uses fields to limit results
    private class func getUrl2(type: QueryType = .currentSong, query: String) -> String {
        var newQuery: String
        switch type {
            case .currentSong: newQuery = getUrlImpl(query)
            case .mostPopular: newQuery = getUrlImpl(query + "+band")
            case .live: newQuery = getUrlImpl(query + "+band+live")
            case .recent: newQuery = getUrlImpl(query + "+band", newest: true)
        }
        return newQuery
    }
    
    private class func getUrlImpl(_ query: String, newest: Bool = false) -> String {
        let fields = "items(id(videoId),snippet(title,description,thumbnails(default(url))))"
        var urlStr = "https://www.googleapis.com/youtube/v3/search?key=\(apiKey)&part=snippet&fields=\(fields)&q='\(query)'&type=video&videoCategoryId=10&maxResults=\(maxResults)"
        if newest {
            urlStr += "&order=date"
        }
        return urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    
    

    
    /*playlists
    private class func getUrl3(from query: String) -> String {
        //let fields = "items(id(videoId),snippet(title,thumbnails(default(url))),statistics)"
        var urlStr = "https://www.googleapis.com/youtube/v3/search?key=\(apiKey)&part=snippet&q='\(query)'&type=playlist&order=viewCount&maxResults=\(maxResults)"
        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return urlStr
    }
    
    //knowledge graph
    private class func getUrl4(from query: String) -> String {
        let urlStr = "https://kgsearch.googleapis.com/v1/entities:search?query=inquisition+band&key=\(apiKey)&limit=1&indent=True".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return urlStr!
    }
    */
}

