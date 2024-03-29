//
//  VideoController.swift
//  SongDemon
//
//  Created by Adam Rothberg on 8/14/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import UIKit
import YouTubePlayer

protocol VideoControllerDelegate: class {
    func dismissed()
}

class VideoController: UIViewController {

    // MARK: - Fields
    var video : Video! {
        didSet {
            if let url = URL(string: video.artworkUrl) {
                url.getImageAsync { image, error in
                    if let image = image {
                        DispatchQueue.main.async {
                            self.image.image = image
                        }
                    }
                    else if let error = error {
                        print (error)
                    }
                }
            }
            artistLabel.text = video.artist
            titleLabel.text = video.title
            self.youtubePlayer.loadVideoID(video.id)
            if VideoLibrary.contains(id: video.id) {
                button.isHidden = true
            }
            else {
                button.setTitle("Add to Library", for: .normal)
                button.isHidden = false
            }
        }
    }
    weak var delegate : VideoControllerDelegate?
    
    private var youtubePlayer : YouTubePlayerView!
    
    // MARK: - Outlets & Actions
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    @IBAction func buttonClicked(_ sender: UIButton) {
        if VideoLibrary.contains(id: self.video.id) {
            VideoLibrary.remove(video: self.video)
        }
        else {
            VideoLibrary.add(video: self.video)
        }
        delegate?.dismissed()
    }
    // MARK: - UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tap for image
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapImage))
        gesture.numberOfTapsRequired = 1
        image.addGestureRecognizer(gesture)
        image.isUserInteractionEnabled = true
        
        self.youtubePlayer = YouTubePlayerView()
        self.stackView.addSubview(youtubePlayer)
        self.youtubePlayer.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        youtubePlayer.bindSizeTo(view: stackView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func tapImage() {
        if youtubePlayer.ready {
            if youtubePlayer.playerState == .Playing {
                youtubePlayer.pause()
            } else {
                youtubePlayer.play()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
