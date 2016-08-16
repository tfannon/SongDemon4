//
//  AppleMusicManager.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/16/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import Foundation
import MediaPlayer

class AppleMusicManager {
    
    // MARK: - Singleton
    private static let sharedInstance = AppleMusicManager()
    
    private init() {
    }
    
    var applePlayer: MPMusicPlayerController = MPMusicPlayerController.systemMusicPlayer()
    var mediaLibrary: MPMediaLibrary = MPMediaLibrary.default()
    
    //todo: add callback
    class func addCurrentSong() {
        if let track = sharedInstance.applePlayer.nowPlayingItem {
            //make sure
            if ITunesUtils.getSongFrom(track.hashKey) == nil {
                if let artist = getValidArtist(for: track),
                    let title = track.title {
            
                ITunesApi.find(media: Media.Music)
                    .by(artist: artist, song: title)
                    .limit(limit: 1)
                    .request { json, error in
                        print (json)
                        //guard?
                        if let id = json?["results"][0]["trackId"].stringValue {
                            self.sharedInstance.mediaLibrary.addItem(withProductID: id) { result in
                                if let item = result.0[0] as? MPMediaItem {
                                    let message = self.sharedInstance.getTrackInfo(item)
                                    print("Added: \(message)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    class func getValidArtist(for track: MPMediaItem) -> String? {
        if track.artist != nil {
            return track.artist!
        }
        if track.albumArtist != nil {
            return track.albumArtist!
        }
        return nil
    }
    
    func getTrackInfo(_ track: MPMediaItem) -> String {
        var trackInfo: String = ""
        if track.albumArtist != nil {
            trackInfo += "\(track.albumArtist!)"
        }
        trackInfo += " : "
        
        if track.artist != nil {
            trackInfo += "\(track.artist!)"
        }
        trackInfo += " : "

        if track.albumTitle != nil {
            trackInfo += "\(track.albumTitle!)"
        }
        trackInfo += " : "
        
        if track.title != nil {
            trackInfo += "\(track.title!)"
        }
        return trackInfo
    }
    
    
}
