//
//  YouTubeVideoController.swift
//  SongDemon
//
//  Created by Thomas Fannon on 8/29/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//
import UIKit
import YouTubePlayer

class YouTubeVideoController: UIViewController, YouTubePlayerDelegate {
    var youTubePlayer = YouTubePlayerView()
    var imageView: UIImageView!


    override func viewDidLoad() {
        self.youTubePlayer.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override var previewActionItems: [UIPreviewActionItem] {
        let action1 = UIPreviewAction(title: "Option 1", style: .default) { (_, _) -> Void in
            print("点击了赞")
        }
        
        let action2 = UIPreviewAction(title: "Option 2", style: .default) { (_, _) -> Void in
            print("点击了分享")
        }
        
        let actions = [action1,action2]
        return actions
    }
    
    var video: Video! {
        didSet {
            self.youTubePlayer.loadVideoID(video.id)
            self.imageView = UIImageView(image: video.cachedImage!)
            self.view.addSubview(self.imageView)
        }
    }
    
    func play() {
        if youTubePlayer.ready {
            youTubePlayer.play()
        }
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {}

    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        if playerState == .Paused || playerState == .Ended {
            self.dismiss(animated: false)
        }
    }

    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        
    }
    
}
