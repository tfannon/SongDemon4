//
//  SearchAlbumController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 11/23/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import MediaPlayer

class SearchAlbumController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblArtist: UILabel!

    var previousArtist : String! = nil
    var songsByAlbum : [[MPMediaItem]] = []
    var songsForPlaylist : [MPMediaItem] = []
    var selectedArtist : String! = nil
    var artistSelectedWithPicker : Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        //if no image exists dont screw up image
        //playingSongImage = playingSongImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.tableView.backgroundColor = UIColor.black
        //empty cells wont create lines
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //if the artist changed, reload the table
        artistCheck()
        //if there is a song being played and we came in from search button, scroll to playing song
        if !artistSelectedWithPicker && MusicPlayer.currentSong != nil {
            let indexPath = getIndexPathForCurrentSong()
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: false)
        }
    }
    
    //MARK: helpers for getting song/artist
    func getIndexPathForCurrentSong() -> IndexPath {
        //grab the album title from the first song of the album
        let albums : [String] = songsByAlbum.map { $0[0].albumTitle! }
        let section = albums.find { $0 == MusicPlayer.currentSong!.albumTitle }!
        let row = songsByAlbum[section].find {  $0.title == MusicPlayer.currentSong!.title }!
        let indexPath = IndexPath(row: row, section: section)
        return indexPath
    }
    
    //returns true if artist changed
    func artistCheck() {
        if previousArtist == nil || selectedArtist != previousArtist {
            print ("switching artist to \(selectedArtist)")
            self.lblArtist.text = selectedArtist
            //this call returns a tuple,  the first value are the songs grouped by album. 
            //the second is a straight list of songs that can be sent to media player
            (self.songsByAlbum, self.songsForPlaylist) = LibraryManager.getArtistSongsWithoutSettingPlaylist(selectedArtist)
            self.tableView.reloadData()
            self.previousArtist = selectedArtist
        }
    }
    
    //MARK:  UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return songsByAlbum.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsByAlbum[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchAlbumTrackCell") as! SearchAlbumTrackCell
        let song = songsByAlbum[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        cell.lblTitle.text = song.title
        cell.lblTrackNumber.text = "\(song.albumTrackNumber)."
        if !artistSelectedWithPicker && indexPath == getIndexPathForCurrentSong() {
            cell.imgPlaying.image = UIImage(named: "black-red-note-120.png")
            //cell.imgPlaying.setAnimatableImage(named: "animated_music_bars.gif")
            if MusicPlayer.isPlaying {
                //cell.imgPlaying.startAnimatingGIF()
            }
            cell.imgPlaying.isHidden = false
        } else {
            //cell.imgPlaying.stopAnimatingGIF()
            cell.imgPlaying.isHidden = true
        }
        return cell
    }
    
    //header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchAlbumTitleCell") as! SearchAlbumTitleCell
        let album = songsByAlbum[section]
        cell.lblTitle.text = album[0].albumTitle
        cell.imgAlbum.image = album[0].getArtworkWithSize(cell.imgAlbum.frame.size)
        cell.lblInfo.text = album[0].year
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70.0
    }
    
    //MARK: UITableViewDelegate
    //selection should put the all the artists songs in playlist, select that song, then return to title screen
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = songsByAlbum[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        LibraryManager.setPlaylistFromSearch(self.songsByAlbum, songsForQueue: self.songsForPlaylist, songToStart: song)
        self.dismiss(animated: false, completion: nil)
    }
}
