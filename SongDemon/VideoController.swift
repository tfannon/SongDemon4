//
//  VideosController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/31/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

enum VideoControllerMode {
    case library
    case youTubeSong
    case youTubeArtist
    
    var isYouTube: Bool {
        return self == VideoControllerMode.youTubeSong || self == VideoControllerMode.youTubeArtist
    }
    
    static var `default` = VideoControllerMode.youTubeSong
}

class VideoController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    var videos = [Video]()
    var mode = VideoControllerMode.default
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.black
        //empty cells wont create lines
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        self.tableView.addGestureRecognizer(longPress)
        
        if Utils.inSimulator {
            videos = VideoLibrary.getVideos()
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print ("VideoController:\(#function):\(mode)")
        super.viewWillAppear(animated)
        //this doesn't have a nav bar coming in from main view.  it only gets one from search view
        //we only do this so the elements are not hidden in the storyboard.  this is probably a hack
        //self.navigationController?.navigationBar.isHidden = true
        redrawList()
    }
    
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: p) else { return }
        if gestureRecognizer.state == .ended {
            let video = videos[indexPath.row]
            let sheet = UIAlertController(title: "\(video.title)", message: "Choose an action for this video", preferredStyle: .actionSheet)
            let isInLibrary = VideoLibrary.contains(id: video.id)
            if isInLibrary {
                let action = UIAlertAction(title: "Remove from library", style: .destructive) { result in
                    VideoLibrary.removeVideo(video: video)
                    self.redrawList()
                }
                sheet.addAction(action)
            } else {
                let action = UIAlertAction(title: "Add to library", style: .default) { result in
                    VideoLibrary.addVideo(video: video)
                    self.redrawList()
                }
                sheet.addAction(action)
            }
            let action = UIAlertAction(title: "Info", style: .default) { result in
                print (video.toJson(prettyPrint: true))
            }
            sheet.addAction(action)
            //if we are currently retrieving youtube videos keyed on song, change to key on just artist
            if mode == .youTubeSong {
                let action = UIAlertAction(title: "Search \(video.artist) Hits", style: .default) { result in
                    print ("Now displaying most popular vids by \(video.artist)")
                }
                sheet.addAction(action)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            sheet.addAction(cancel)
            self.present(sheet, animated: true) { }
        }
    }
    
    func queueVideo(_ video: Video) {
        
    }
    
    func redrawList() {
        //when its list mode, sort by artist
        if mode == .library {
            self.navigationController?.title = "Library Mode"
            self.videos = VideoLibrary.getVideos().sorted { vid in
                return vid.0.artist < vid.1.artist
            }
        }
        else {
            self.videos = YouTubeVideoManager.getVideos()
        }
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let video = videos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "YouTubeCell", for: indexPath) as! YouTubeCell
        //hide it before asynch fetch so we don't reuse a stale picture
        cell.imgVideo.image = nil
        //the load method will paint the cell as needed
        cell.load(video: video)
        //dont show in library icon when displaying items from the library via search
        cell.imgIsInLibrary.isHidden = !self.mode.isYouTube || !VideoLibrary.contains(id: video.id)
        
        //todo: asynch fetch with cache
        cell.imgVideo.image = nil
        if let url = URL(string: video.artworkUrl) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if error == nil {
                    DispatchQueue.main.async {
                        cell.imgVideo.image = UIImage(data: data!)
                    }
                }
            }
            task.resume()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! YouTubeCell
        cell.play()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
