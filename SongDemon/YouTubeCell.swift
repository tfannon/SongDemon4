//
//  YouTubeCell.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/14/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import UIKit
import YouTubePlayer

class YouTubeCell: UITableViewCell {

    @IBOutlet var imgVideo: UIImageView!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet weak var imgIsInLibrary: UIImageView!

    var video: Video!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func load(video: Video) {
        self.video = video
        self.lblDescription.text = video.title
    }
}
