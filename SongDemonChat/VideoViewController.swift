//
//  VideoViewController.swift
//  SongDemon
//
//  Created by Adam Rothberg on 8/13/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import UIKit
import YouTubePlayer

class VideoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Fields 
    var demonVideos : [DemonVideo] = []
    let VideoCellIdentifier : String = "VideoCell"
    
    // MARK: - Outlets & Actions
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection
        section: Int) -> Int {
        return demonVideos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:
        IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VideoCellIdentifier,
                                                 for: indexPath) as! VideoCell
        
        let video = demonVideos[indexPath.row]
        let player : YouTubePlayerView = YouTubePlayerView()
        player.translatesAutoresizingMaskIntoConstraints = false;
        player.backgroundColor = UIColor.blue
        cell.playerView.addSubview(player)
//        let viewsDictionary = ["subView": player]
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|", options: NSLayoutFormatOptions.alignAllTop, metrics: nil, views: viewsDictionary))
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|", options: NSLayoutFormatOptions.alignAllLeft, metrics: nil, views: viewsDictionary))
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) {
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
