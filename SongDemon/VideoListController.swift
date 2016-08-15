//
//  VideosController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/31/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

class VideoListController : UITableViewController {
    
    @IBOutlet var lblHeader: UILabel!
    
    var data = [Video]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.black
        //empty cells wont create lines
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = UIColor.white
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: #selector(VideoListController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        self.tableView.addGestureRecognizer(longPress)
        
        if Utils.inSimulator {
            data = VideoLibrary.getVideos()
        }
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: p) else { return }
        if gestureRecognizer.state == .ended {
            let video = data[indexPath.row]
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
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            sheet.addAction(cancel)
            self.present(sheet, animated: true) { }
        }
    }
    
    func queueVideo(_ video: Video) {
        
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        redrawList()
    }
    
    //todo: refetch videos based just on artist name
    func refresh(_ sender:AnyObject) {
        self.refreshControl?.endRefreshing()
    }
    
    func redrawList(forceRefresh: Bool = false) {
        lblHeader.text = ""
        tableView.reloadData()
        if (gVideos.needsRefresh || forceRefresh) && gVideos.state == .available {
            self.data = gVideos.videos
            gVideos.needsRefresh = false
            if let song = MusicPlayer.currentSong {
                lblHeader.text = "\(song.safeArtist) - \(song.safeTitle)"
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let video = self.data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "YouTubeCell", for: indexPath) as! YouTubeCell
        //the load method will paint the cell as needed
        cell.load(video: video)

//        //this runs but is laggy
//        if let url = URL(string: video.artworkUrl),
//            let data = NSData(contentsOf: url) {
//            cell.imgVideo.image = UIImage(data: data as Data)
//        }
        
        /* async fetch needs to cache the images so not refetching when it rolls back
        cell.imgVideo.image = nil
        if let url = URL(string: video.artworkUrl) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if error == nil {
                    cell.imgVideo.image = UIImage(data: data!)
                }
            }
            task.resume()
        }
        */
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! YouTubeCell
        cell.onPlay()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = self.data[indexPath.row]
        let vc = RootController.getPlayVideoController()
        vc.load(video)
        RootController.switchToPlayVideoController()
    }
    */
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
