//
//  VideoCell.swift
//  SongDemon
//
//  Created by Adam Rothberg on 8/13/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {

    @IBOutlet weak var playerView: UIView!
    var player : YouTubePlayerView = YouTubePlayerView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
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
        unload()
        if let url = URL(string: video.Link) {
            player.loadVideoURL(url)
        }
    }
    
    func unload() {
        player.clear()
    }
}
