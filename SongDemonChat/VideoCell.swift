//
//  VideoCell.swift
//  SongDemon
//
//  Created by Adam Rothberg on 8/13/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import UIKit
import YouTubePlayer

class VideoCell: UITableViewCell {

    @IBOutlet weak var liker: UIImageView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var imgLiked: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!

    var player : YouTubePlayerView = YouTubePlayerView()
    var video : Video!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label1.backgroundColor = .none
        label2.backgroundColor = .none
        player.backgroundColor = .none
        
        playerView.addSubview(player)
        player.bindSizeToSuperview()
        player.playerVars = [
            "playsinline": "1",
            "controls": "0",
            "showinfo": "0"
        ]
        
        self.liker.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onLikedTapped))
        tapGesture.numberOfTapsRequired = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onLikedTapped() {
        video.bringIntoLibrary = !video.bringIntoLibrary
        if video.bringIntoLibrary {
            liker.image = UIImage(named: "Heart Filled-50")
        }
        else {
            liker.image = UIImage(named: "Heart-50")
        }
    }
    
    func load(video : Video) {
        recycle()
        if let url = URL(string: video.url) {
            player.loadVideoURL(url)
            label1.text = video.artist
            label2.text = video.title
        }
    }
    
    func recycle() {
        player.clear()
        label1.text = ""
        label2.text = ""
    }
}
