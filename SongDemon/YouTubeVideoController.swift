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
    var video: Video! //this must be set before the view is instantiated


    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var vDescription: UILabel!
    @IBOutlet weak var publishDate: UILabel!
    @IBOutlet weak var views: UILabel!
    @IBOutlet weak var channel: UILabel!
    @IBOutlet weak var videos: UILabel!
    
    override func viewDidLoad() {
        self.youTubePlayer.delegate = self
        
        self.youTubePlayer.loadVideoID(video.id)
        let image = video.cachedImageHigh ?? video.cachedImage!
        self.imageView.image = image

        vDescription.text = video.description
        //let index = video.publishDate.startIndex;
        publishDate.text = "Published:  \(String(video.publishDate.characters.prefix(10)))" //beautify
        channel.text = "Channel:  \(video.channelTitle)"

        //need to go fetch stats and channel videos
        YouTubeVideoManager.fetchStats(for: video, controller: self)
        
    }
    

    //callback from YouTubeManager
    func setViewCount(_ views: String) {
        DispatchQueue.main.async {
            self.views.text = "Views:  \(views)"
        }
    }
    
    override var previewActionItems: [UIPreviewActionItem] {
        let action1 = UIPreviewAction(title: "Save to library", style: .default) { (_, _) -> Void in
            print("点击了赞")
        }
        
        let action2 = UIPreviewAction(title: "Show popular videos", style: .default) { (_, _) -> Void in
            print("点击了分享")
        }
        
        let action3 = UIPreviewAction(title: "Show live videos", style: .default) { (_, _) -> Void in
            print("点击了分享")
        }
        
        let action4 = UIPreviewAction(title: "Show channel videos", style: .default) { (_, _) -> Void in
            print("点击了分享")
        }
        
        
        let actions = [action1, action2, action3, action4]
        return actions
    }
    
    
    func play() {
        if youTubePlayer.ready {
            youTubePlayer.play()
        }
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        //youTubePlayer.play()
    }

    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        if playerState == .Paused || playerState == .Ended {
            self.dismiss(animated: false)
        }
    }

    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        
    }
    
}
