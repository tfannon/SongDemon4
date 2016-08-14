//
//  SelectorViewController.swift
//  SongDemon
//
//  Created by Adam Rothberg on 8/14/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import UIKit

protocol SelectorViewControllerDelegate {
    func shareVideo (video : Video)
}

class SelectorViewController: UITableViewController {

    private let VideoCellIdentifier : String = "VideoCell"
    var delegate : SelectorViewControllerDelegate?
    var videos : [Video] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return videos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VideoCellIdentifier, for: indexPath)

        // Configure the cell...
        let video = videos[indexPath.row]
        cell.textLabel?.text = video.artist
        cell.detailTextLabel?.text = video.title

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = videos[indexPath.row]
        delegate?.shareVideo(video: video)
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
