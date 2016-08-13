//
//  VideoCell.swift
//  SongDemon
//
//  Created by Adam Rothberg on 8/13/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {

    @IBOutlet weak var liker: UIImageView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!

    var player : YouTubePlayerView = YouTubePlayerView()
    
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func load(video : DemonVideo) {
        recycle()
        if let url = URL(string: video.Link) {
            player.loadVideoURL(url)
            label1.text = video.Artist
            label2.text = video.Title
        }
    }
    
    func recycle() {
        player.clear()
        label1.text = ""
        label2.text = ""
    }
}
