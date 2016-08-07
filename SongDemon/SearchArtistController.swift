//
//  SongSearchController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 11/15/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import MediaPlayer

class SearchArtistController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
   
    var imageCache = [String : UIImage]()
    var previousArtist : String! = nil
    let names = Utils.inSimulator ? ["Goatwhore", "Sleep"] : ITunesUtils.getArtists()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.black
        //UITableView.appearance().sectionIndexTrackingBackgroundColor = UIColor.blackColor()
        UITableView.appearance().sectionIndexBackgroundColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if MusicPlayer.currentSong != nil {
            let indexPath = getIndexPathForCurrentSong()
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: false)
        }
    }
    
    func getIndexPathForCurrentSong() -> IndexPath {
        if let currentSong = MusicPlayer.currentSong {
            let name = currentSong.albumArtist!
            let section = self.collation.section(for: Artist(name: name), collationStringSelector: #selector(getter: Artist.name))
            let x = sections[section]
            let names: [String] = x.artists.map { $0.name }
            if let row = names.index(of: name) {
                return  IndexPath(row: row, section: section)
            }
        }
        return IndexPath(row: 0, section: 0)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].artists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let artist = self.sections[(indexPath as NSIndexPath).section].artists[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchArtistCell", for: indexPath)
            as! SearchArtistCell
        if Utils.inSimulator {
            return cell
        }
        cell.lblArtist.text = artist.name
        cell.imgArtist.image = UIImage(named: "jakegiz")
        let artistInfo = LibraryManager.artistInfo[artist.name]!
//        if let artwork = artistInfo.artwork {
//            cell.imgArtist.image = artwork.imageWithSize(cell.imgArtist.frame.size)
//        }
        let information = "\(artistInfo.songs) songs  \(artistInfo.likedSongs) liked  \(artistInfo.unplayedSongs) unplayed"
        cell.lblInformation.text = information
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !self.sections[section].artists.isEmpty {
            return (self.collation.sectionTitles[section] )
        }
        return ""
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.collation.sectionIndexTitles
    }
    
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.collation.section(forSectionIndexTitle: index)
    }
    
    
    
    //MARK:  helpers to deal with indexing section
    class Artist : NSObject {
        let name: String
        var section: Int?
        
        init(name: String) {
            self.name = name
        }
    }
    
    class Section {
        var artists : [Artist] = []
        
        func addArtist(_ artist : Artist) {
            self.artists.append(artist)
        }
    }
    
    let collation = UILocalizedIndexedCollation.current() 
    
    var _sections: [Section]?
    var sections: [Section] {
        if self._sections != nil {
            return self._sections!;
        }
        
        //create artists from itunes list
        let artists: [Artist] = names.map { name in
            let artist = Artist(name: name)
            artist.section = self.collation.section(for: artist, collationStringSelector: #selector(getter: Artist.name))
            return artist
        }
        
        //create empty sections
        var sections = [Section]()
        for _ in 0..<self.collation.sectionIndexTitles.count {
            sections.append(Section())
        }
        
        //put each artist in a section
        for artist in artists {
            sections[artist.section!].addArtist(artist)
        }
        
        //sort each section
        for section in sections {
            section.artists = self.collation.sortedArray(from: section.artists, collationStringSelector: #selector(getter: Artist.name)) as! [Artist]
        }
        
        self._sections = sections
        return self._sections!
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artist = self.sections[(indexPath as NSIndexPath).section].artists[(indexPath as NSIndexPath).row].name
        let searchAlbumController = self.tabBarController!.viewControllers![1] as! SearchAlbumController
        searchAlbumController.selectedArtist = artist
        searchAlbumController.artistSelectedWithPicker = true
        self.tabBarController!.selectedIndex = 1
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
}
