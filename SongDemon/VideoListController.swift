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
    
    var data : [JSON] = [JSON]()
    //var nextToken : String = ""

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
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        redrawList()
    }
    
    func refresh(_ sender:AnyObject) {
        //redrawList()
        //TODO: change this to go fetch the next
        self.refreshControl?.endRefreshing()
    }
    
    func redrawList(_ forceRefresh : Bool = false) {
        lblHeader.text = ""
        tableView.reloadData()
        if (gVideos.NeedsRefresh || forceRefresh) && gVideos.State == VideoState.available {
            if let json = gVideos.jsonVideos {
                //println(self.nextToken)
                self.data = json["items"].array!
                //let n  = json["nextPageToken"]
                //println(data!.count)
                gVideos.NeedsRefresh = false
                if let song = MusicPlayer.currentSong {
                    lblHeader.text = "\(song.albumArtist) - \(song.title)"
                }
            }
        }
        if Utils.inSimulator {
            lblHeader.text = "Goatwhore - In Deathless Tradition"
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let x = self.data[(indexPath as NSIndexPath).row]
        //let snippet = x["snippet"].object!
        //let title = x["snippet"]["title"].string!
        let description = x["snippet"]["description"].string!
        let thumb = x["snippet"]["thumbnails"]["default"]["url"].string!
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        cell.lblDescription.text = description
        //clear the image before the async fetch
        if !Utils.inSimulator {
            cell.imageView!.image = nil
        }
        //go fetch the image form the thumb
        let imgURL = URL(string: thumb)!
        let session = URLSession()
        session.dataTask(with: imgURL) { data, response, error in
            if error == nil {
                cell.imgVideo.image = UIImage(data: data!)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let x = self.data[(indexPath as NSIndexPath).row]
        let id = x["id"]["videoId"].string!
        
        let vc = RootController.getPlayVideoController()
        let videoUrl = "https://www.youtube.com/watch?v=\(id)"
        let artworkUrl = x["snippet"]["thumbnails"]["default"]["url"].string!

        vc.loadVideo(videoUrl, artworkUrl: artworkUrl)
        RootController.switchToPlayVideoController()
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
