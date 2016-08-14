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
    
    var data = [YouTubeVideo]()

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
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        redrawList()
    }
    
    func refresh(_ sender:AnyObject) {
        //TODO: change this to go fetch the next
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
        print ("Title:\(video.title)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        cell.lblDescription.text = video.title
        //blank the existing image before fetching image
        cell.imageView!.image = nil
        let imgURL = URL(string: video.artworkUrl)!
        let task = URLSession.shared.dataTask(with: imgURL) { data, response, error in
            if error == nil {
                cell.imgVideo.image = UIImage(data: data!)
            }
        }
        task.resume()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = self.data[indexPath.row]
        let vc = RootController.getPlayVideoController()
        vc.load(video)
        RootController.switchToPlayVideoController()
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
