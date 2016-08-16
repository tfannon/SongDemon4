//
//  VideoCell.swift
//  SongDemon
//
//  Created by Adam Rothberg on 8/16/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {

    private var video : Video? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func load(video : Video) {
        let videoId = video.id
        self.video = video
        self.textLabel?.text = video.artist
        self.detailTextLabel?.text = video.title
        
        // load up the artwork async
        if let url = URL(string: video.artworkUrl) {
            url.getImageAsync { image, error in
                // make sure by the time we get here that
                // this cell is still used for the original video object
                // and wasn't recycled before this got called
                if self.video?.id == videoId {
                    if let image = image {
                        DispatchQueue.main.async {
                            self.imageView?.image = image
                            print (video.title)
                        }
                    }
                    else if let error = error {
                        print (error)
                    }
                }
            }
        }
    }
    
    func recycle() {
        print ("\(video?.title) recycled")
        video = nil
        self.textLabel?.text = ""
        self.detailTextLabel?.text = ""
        self.imageView?.image = nil
    }
}
