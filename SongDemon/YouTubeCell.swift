//
//  YouTubeCell.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/14/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import UIKit
import YouTubePlayer

class YouTubeCell: UITableViewCell, YouTubePlayerDelegate {
    @IBOutlet var imgVideo: UIImageView!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet weak var YouTubePlayer: YouTubePlayerView!
    @IBOutlet weak var imgIsInLibrary: UIImageView!
    
    var video: Video!
    

    override func awakeFromNib() {
        super.awakeFromNib()
//        YouTubePlayer.playerVars = [
//            "playsinline": "1",
//            "controls": "0",
//            "showinfo": "0"
//        ]
//        YouTubePlayer.delegate = self
        //YouTubePlayer.isUserInteractionEnabled = false
    }

    
    func load(video: Video) {
        //recycle()
        self.video = video
        self.lblDescription.text = video.title
        //self.YouTubePlayer.loadVideoID(video.id)
        //hide the song icon if the library does not contain the video
        imgIsInLibrary.isHidden = !VideoLibrary.contains(id: video.id)
        imgVideo.isHidden = false
        YouTubePlayer.isHidden = true
        YouTubePlayer.loadVideoID(video.id)
        //this runs but is laggy
        if let url = URL(string: video.artworkUrl),
            let data = NSData(contentsOf: url) {
            self.imgVideo.image = UIImage(data: data as Data)
        }
    }
    
    func onPlay() {
        if (YouTubePlayer.ready) {
            YouTubePlayer.play()
        }
    }
    
    // MARK: - YouTubePlayer
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        print ("ready to play")
    }
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
    }
    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality:  YouTubePlaybackQuality) {
    }
}
