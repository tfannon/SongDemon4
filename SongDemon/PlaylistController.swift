//
//  PlaylistController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/4/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import MediaPlayer

protocol ICellIsPlaying {
    var imgStatus : UIImageView! { get }
}

class PlaylistController: UITableViewController {

    var sampleArtists = ["Goatwhore", "Goatwhore"]
    var sampleAlbums = ["Blood For The Master", "Constricting Rage of the Merciless"]
    var sampleSongs = ["In Deathless Tradition", "FBS"]
    var sampleImages = ["sample-album-art.jpg", "sample-album-art2.jpg"]
    
    @IBOutlet var lblHeaderTitle: UILabel!
    @IBOutlet var viewHeader: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //if no image exists dont screw up image
        //playingSongImage = playingSongImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.tableView.backgroundColor = UIColor.black
        //empty cells wont create lines
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
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
    
    
    func redrawList() {
        tableView.reloadData()
        if LibraryManager.currentPlaylist.count == 0 {
            lblHeaderTitle.text = "No playlist selected"
        }
        else {
            lblHeaderTitle.text = ""
            tableView.scrollToRow(at: getIndexPath(), at: UITableViewScrollPosition.middle, animated: false)
        }
    }
    
    func getIndexPath() -> IndexPath {
        let index = LibraryManager.currentPlaylistIndex
        var indexPath : IndexPath
        if index == 0 {
            indexPath = IndexPath(row: 0, section: 0)
        } else {
            var idx : Int = 0
            var row = 0
            var section = 0
            while (idx < index) {
                let songsInSection = LibraryManager.groupedPlaylist[section].count
                if idx + songsInSection > index {
                    row = index - idx
                } else {
                    section += 1
                }
                idx += songsInSection
            }
            //println("Index:\(index)  Idx:\(idx)  Section:\(section)  Row:\(row)")
            indexPath = IndexPath(row: row, section: section)
        }
        return indexPath
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //println("Sections: \(LibraryManager.groupedPlaylist.count)")
        return LibraryManager.groupedPlaylist.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Utils.inSimulator {
            return sampleSongs.count
        }
        return LibraryManager.groupedPlaylist[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mode = LibraryManager.currentPlayMode
        var identifier : String
        switch (mode) {
            case (.artist), (.album)  : identifier = "PlaylistAlbumSongCell"
            default: identifier = "PlaylistCell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) 
        
        if Utils.inSimulator {
            let cell2 = cell as! PlaylistCell
            cell2.lblTitle.text = sampleSongs[(indexPath as NSIndexPath).row]
            cell2.lblArtistAlbum.text = "\(sampleArtists[(indexPath as NSIndexPath).row]) - \(sampleAlbums[(indexPath as NSIndexPath).row])"
            cell2.imgArtwork.image = UIImage(named: sampleImages[(indexPath as NSIndexPath).row])
            cell2.imgStatus.tintColor = UIColor.lightGray
            return cell2
        }
        
        var song : MPMediaItem;
        var isCurrentSong : Bool
        switch (mode) {
        
        case (.artist), (.album):
            song = LibraryManager.groupedPlaylist[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
            isCurrentSong = getIndexPath() == indexPath
            let cell2 = cell as! PlaylistAlbumSongCell
            cell2.lblTrack.text = "\(song.albumTrackNumber)"
            cell2.lblTitle.text = song.title
            setIsPlayingImage(cell2, cellIsSelectedSong: isCurrentSong)
           
        default:
            let cell2 = cell as! PlaylistCell
            song = LibraryManager.groupedPlaylist[0][(indexPath as NSIndexPath).row]
            isCurrentSong = LibraryManager.currentPlaylistIndex == (indexPath as NSIndexPath).row
            cell2.lblTitle.text = song.title
            cell2.lblArtistAlbum.text =  "\(song.albumArtist!) - \(song.albumTitle!)"
            setIsPlayingImage(cell2, cellIsSelectedSong: isCurrentSong)
            cell2.imgArtwork.image = song.getArtworkWithSize(cell2.imgArtwork.frame.size)
        }
        
        return cell
    }
    
    func setIsPlayingImage(_ cell : ICellIsPlaying, cellIsSelectedSong : Bool) {
        if cellIsSelectedSong {
            //cell.imgStatus.setAnimatableImage(named: "animated_music_bars.gif")
            cell.imgStatus.image = UIImage(named: "black-red-note-120.png")
            if MusicPlayer.isPlaying {
                //cell.imgStatus.startAnimatingGIF()
            }
            cell.imgStatus.isHidden = false
        }
        else {
            //cell.imgStatus.stopAnimatingGIF()
            cell.imgStatus.isHidden = true
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mode = LibraryManager.currentPlayMode
        switch (mode) {
            case (.artist), (.album) : return 35.0
            default: return 50.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = LibraryManager.groupedPlaylist[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        //println(song.songInfo)
        MusicPlayer.playSongInPlaylist(song)
        RootController.switchToMainView()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        switch (LibraryManager.currentPlayMode) {
            case (.artist), (.album) :
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistAlbumTitleCell") as! PlaylistAlbumTitleCell
                let song = LibraryManager.groupedPlaylist[section][0]
                cell.lblAlbum.text = song.albumTitle
                cell.lblYear.text = song.year
                cell.lblArtist.text = song.albumArtist
                cell.imgArtwork.image = song.getArtworkWithSize(cell.imgArtwork.frame.size)
                //cell.contentView.backgroundColor = UIColor.darkGrayColor()
                cell.contentView.backgroundColor = UIColor.black
            return cell.contentView
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistAlbumTitleCell") as! PlaylistAlbumTitleCell
                cell.contentView.backgroundColor = UIColor.black
                return cell.contentView
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch (LibraryManager.currentPlayMode) {
            case (.artist), (.album) : return 115
            default: return 25
        }
    }
}
