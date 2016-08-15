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
    @IBOutlet weak var imgIsInLibrary: UIImageView!
    
    var YouTubePlayer: YouTubePlayerView?
    var video: Video!

    override func awakeFromNib() {
        super.awakeFromNib()
        //YouTubePlayer.delegate = self
    }

    func load(video: Video) {
        self.video = video
        self.lblDescription.text = video.title
        self.YouTubePlayer?.loadVideoID(video.id)
    }
    
    func play() {
        if YouTubePlayer != nil && YouTubePlayer!.ready {
            YouTubePlayer?.play()
        }
    }
    
    // MARK: - YouTubePlayer
    func playerReady(_ videoPlayer: YouTubePlayerView) {
    }
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
    }
    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality:  YouTubePlaybackQuality) {
    }
}
