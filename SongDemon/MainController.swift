//
//  MainController.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 6/18/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation


class MainController: UIViewController, LibraryScanListener {

    //MARK: outlets and actions
    @IBOutlet var viewMain: UIView!
    @IBOutlet var viewArtwork: UIView!
    @IBOutlet var imgSong: UIImageView!
    @IBOutlet var lblStatus: UILabel!

    @IBOutlet var viewPlayOverlay: UIView!
    @IBOutlet var btnPrev: UIButton!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnNext: UIButton!
   
    @IBAction func prevTapped(_: AnyObject) { handlePrevTapped() }
    @IBAction func playTapped(_: AnyObject) { handlePlayTapped() }
    @IBAction func nextTapped(_: AnyObject) { handleNextTapped() }
   
    
    @IBOutlet var viewScrubber: UIView!
    @IBOutlet var scrubber: UISlider!
    @IBAction func scrubberChanged(_ sender: AnyObject) { handleScrubberChanged() }
    
    @IBOutlet var viewSongInfo: UIView!
    @IBOutlet var lblArtist: UILabel!
    @IBOutlet var lblSong: UILabel!
    
    @IBOutlet var viewOtherButtons: UIView!
    @IBOutlet var btnPlaylist: UIButton!
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var btnLike: UIButton!
    @IBOutlet var btnDislike: UIButton!
    @IBOutlet var btnShare: UIButton!
    @IBOutlet var btnAddToQueue: UIButton!

    @IBAction func playlistTapped(_: AnyObject) { handlePlaylistTapped() }
    @IBAction func searchTapped(_ sender: AnyObject) { handleSearchTapped() }
    @IBAction func likeTapped(_ sender: AnyObject) { handleLikeTapped()}
    @IBAction func dislikeTapped(_ sender: AnyObject) { handleDislikeTapped() }
    @IBAction func shareTapped(_ sender: AnyObject) { handleShareTapped() }
    @IBAction func addToQueueTapped(_ sender: AnyObject) { handleAddToQueueTapped() }
   
    //MARK: instance variables
    var playButtonsVisible = false
    //this is used so the event handlers can decide if they need to do something because song changed
    var lastSongHandledByViewController : MPMediaItem?


    //MARK: controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupGestures()
        setupNotifications()
        self.setNeedsStatusBarAppearanceUpdate()
        if Utils.inSimulator {
            //do anything specific to get simulator working
        }
        //search is gray until the library scan is complete
        btnSearch.tintColor = UIColor.gray
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    //MARK: setup
    func setupAppearance() {
        lblStatus.text = ""
        //these allow the large system images to scale
        btnPlay.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill
        btnPlay.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
    }
    
    func setupGestures() {
        //tapping on the artwork pauses/plays
        viewArtwork.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.handleImageTapped)))
        
        //swiping up brings up playlist picker
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(MainController.handlePlaylistTapped))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        //swiping down brings up search
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(MainController.handleSearchTapped))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    func setupSimulator() {
        updateLyricState()
        updateVideoState()
    }
    
  
    //MARK: Action handlers
    func handleImageTapped() {
        //println("image tapped")
        if playButtonsVisible {
            fadePlayButtonsOut()
        }
        else {
            fadePlayButtonsIn()
        }
        /* this code can dissolve between two images
            //let toImage = flip ? UIImage(named:"sample-album-art.jpg") : UIImage(named:"sample-album-art2.jpg")
            //UIView.transitionWithView(imgSong, duration: 1, options: .TransitionCrossDissolve, animations: { self.imgSong.image = toImage }, completion: nil)
        */
    }
    
    func handlePrevTapped() {
        MusicPlayer.reverse()
    }
    
    func handlePlayTapped() {
        MusicPlayer.playPressed()
        updatePlayButton()
    }
    
    func handleNextTapped() {
        MusicPlayer.forward()
    }
    
    func handleShareTapped() {
//        if  let song = MusicPlayer.currentSong {
//            let predicate = MPMediaPropertyPredicate(value: song.hashKey, forProperty: MPMediaItemPropertyPersistentID)
//            let query = MPMediaQuery(filterPredicates: Set(arrayLiteral: predicate))
//            for x in query.items! {
//                print (x)
//            }
//        }
        
        
//        if Utils.inSimulator {
//            
//            let artworkUrl = "http://ecx.images-amazon.com/images/I/511pkBGfKcL._SL500_AA280_PJStripe-Robin,TopLeft,0,0_.jpg"
//            
//            let videoUrl = "https://www.youtube.com/watch?v=j3G0bRUDR6I"
//            FacebookUtils.post("Goatwhore", title: "In Deathless Tradition", artworkUrl:artworkUrl, videoUrl: videoUrl, callback: { status in
//                    self.lblStatus.text = status
//                })
//            return
//        }
//        if let currentItem = MusicPlayer.currentSong {
//            
//            let videoUrl = RootController.getPlayVideoController().currentVideoUrl
//            let artworkUrl = RootController.getPlayVideoController().currentArtworkUrl
//            
//            FacebookUtils.post(currentItem.artist! ,title: currentItem.title!, artworkUrl:artworkUrl, videoUrl: videoUrl, callback: { status in
//                //set a status
//            })
//        }
    }
   
    func handleSearchTapped() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SearchController") as! SearchController
        //if something is in the player, use this to pre-select the artist in the searchController
        vc.currentlyPlayingArtist = MusicPlayer.currentSong?.albumArtist
        present(vc, animated: false, completion: nil)
    }
    
    func handleAddToQueueTapped() {
        
        let alert = UIAlertController(title: "Choose what to put in your personal queue to listen to later", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

        if let currentSong = MusicPlayer.currentSong {

            alert.addAction(UIAlertAction(title: "This song", style: .default, handler: { action in
                LibraryManager.addToQueued(currentSong)
                self.displayFadingStatus ("Song added to Play later queue")
            }))
            
            alert.addAction(UIAlertAction(title: "Remove this song", style: .destructive, handler: { action in
                LibraryManager.removeFromQueued(currentSong)
                self.displayFadingStatus ("Song removed from queue")
            }))

            alert.addAction(UIAlertAction(title: "Songs from this album", style: .default, handler: { action in
                let songs = LibraryManager.getAlbumSongsWithoutSettingPlaylist(currentSong);
                LibraryManager.addToQueued(songs)
                self.displayFadingStatus ("Album added to Play Later queue")
            }))
       
            
            alert.addAction(UIAlertAction(title: "Remove this album", style: .destructive, handler: { action in
                let songs = LibraryManager.getAlbumSongsWithoutSettingPlaylist(currentSong);
                LibraryManager.removeFromQueued(songs)
                self.displayFadingStatus ("Album removed from queue")
            }))
        }
            
        alert.addAction(UIAlertAction(title: "Clear my queue", style: .destructive, handler: { action in
                LibraryManager.clearQueued()
                self.displayFadingStatus ("Play later queue was cleared")
        }))
           
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        }))
            
        self.present(alert, animated: true, completion: {})
    }
    
    
    func handlePlaylistTapped() {
        let alert = UIAlertController(title: "Choose songs to play", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Recently added", style: .default, handler: { action in
            let songs = LibraryManager.getRecentlyAdded()
            self.postPlaylistSelection(songs)
        }))
        
        alert.addAction(UIAlertAction(title: "My queue", style: .default, handler: { action in
            let songs = LibraryManager.getQueuedSongs()
            self.postPlaylistSelection(songs)
        }))
        
        alert.addAction(UIAlertAction(title: "Random mix", style: .default, handler: { action in
            let songs = LibraryManager.getMixOfSongs()
            self.postPlaylistSelection(songs)
        }))
        
        alert.addAction(UIAlertAction(title: "Liked", style: .default, handler: {action in
            let songs = LibraryManager.getLikedSongs()
            self.postPlaylistSelection(songs)
        }))
        
        alert.addAction(UIAlertAction(title: "New", style: .default, handler: { action in
            let songs = LibraryManager.getNewSongs()
            self.postPlaylistSelection(songs)
        }))
        
        if let currentSong = MusicPlayer.currentSong {
            var message = "Songs from this artist"
            alert.addAction(UIAlertAction(title: message, style: .default, handler: { action in
                let songs = LibraryManager.getArtistSongs(currentSong);
                self.postPlaylistSelection(songs, message: "Songs from \(currentSong.albumArtist) are queued", queue:true)
            }))
            
            message = "Songs from this album"
            alert.addAction(UIAlertAction(title: message, style: .default, handler: { action in
                let songs = LibraryManager.getAlbumSongs(currentSong);
                self.postPlaylistSelection(songs, message:"Songs from \(currentSong.albumTitle) are queued", queue:true)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.unhideImageAndBlankStatus()
        }))
        //no matter what option is chosen switch the window back to main
        self.present(alert, animated: true, completion: {
            self.displayFadingStatus("Generating playlist")
            //self.waiting()
        })
    }
    
    // if the current song is among the songs in the upcoming playlist
    // add the songs to the queue without starting a playlist
    func postPlaylistSelection(_ songs: [MPMediaItem]=[MPMediaItem](), message : String? = nil, queue: Bool = false) {
        if songs.count > 0 {
            if queue {
                //todo: this is probably going to bomb
                let indexOfCurrentSong = songs.index(of: MusicPlayer.currentSong!)!
                var nextSong : MPMediaItem?
                //this keeps the position of the song immediately following current song
                //so the next itemplayingdidchange notification will trigger the queue to
                //start and use the correct position
                if indexOfCurrentSong + 1 < songs.count {
                    nextSong = songs[indexOfCurrentSong + 1]
                }
                MusicPlayer.queuePlaylist(songs, songToStart: nextSong)
            }
            else {
                MusicPlayer.play(songs)
            }
        }
        else {
            UIHelpers.messageBox(message:"There are no songs in the playlist")
        }
        if message != nil {
            displayFadingStatus(message!)
        }
        unhideImageAndBlankStatus()
    }
    
    func handleLikeTapped() {
        //if its already liked this will reset it and unset the selected image
        if let currentSong = MusicPlayer.currentSong {
            if LibraryManager.isLiked(currentSong) {
                LibraryManager.removeFromLiked(currentSong)
                changeLikeState(.none)
            }
            else {
                LibraryManager.addToLiked(currentSong)
                changeLikeState(.liked)
            }
        }
    }
    
    func handleDislikeTapped() {
        if let currentSong = MusicPlayer.currentSong {
            LibraryManager.addToDisliked(currentSong)
            MusicPlayer.forward()
            //reset the liked state
            changeLikeState(.disliked)
        }
    }

    
    //mark helpers
    func changeLikeState(_ state : LikeState) {
        var image : String
        switch state {
        case (.liked) :
            image = "777-thumbs-up-selected.png"
        case (.disliked) :
            image = "777-thumbs-up.png"
        case (.none) :
            image = "777-thumbs-up.png"
        }
        if !image.isEmpty {
            btnLike.setImage(UIImage(named: image), for: UIControlState())
        }
    }
    
    /* we will animate the transition of the background image when buttons fade in and out */
    func fadePlayButtonsIn() {
        Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(MainController.fadeOutImage), userInfo:nil, repeats:false);
        viewPlayOverlay.alpha = 0.7
        playButtonsVisible = true
    }
    
    func fadePlayButtonsOut() {
        Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(MainController.fadeInImage), userInfo:nil, repeats:false);
        viewPlayOverlay.alpha = 0.2  //alpha = 0.0 dont receive touch events
        playButtonsVisible = false
    }
    
    func fadeOutImage() {
        UIView.animate(withDuration: 0.25, animations: { self.imgSong.alpha = 0.2 })
    }
    
    func fadeInImage() {
        UIView.animate(withDuration: 0.25, animations: { self.imgSong.alpha = 1.0 })
    }
    
    
    func displayFadingStatus(_ message : String) {
        self.lblStatus.text = message
    }
    
    func hideImage() {
        self.imgSong.isHidden = true
    }
    
    func unhideImageAndBlankStatus() {
        imgSong.isHidden = false
        lblStatus.text = ""
    }
    
    func transitionSongImage(_ toImage : UIImage?) {
        if toImage != nil {
            UIView.transition(with: imgSong, duration: 1, options: .transitionCrossDissolve, animations: { self.imgSong.image = toImage }, completion: nil)
        } else {
            self.imgSong.image = nil
        }
    }


 
    //MARK: notifications
    func setupNotifications() {
        let center = NotificationCenter.default;
        
        center.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil, queue: nil, using: { _ in
                print("UIApplicationDidBecomeActive")
                self.updateSongInfo()
                self.updatePlayState()
        })
       
        center.addObserver(forName: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,
            object: nil, queue:nil) { _ in
                if let currentSong = MusicPlayer.currentSong {
                    print("Song changed to \(currentSong.songInfo)")
                }
                MusicPlayer.playSongsInQueue()
                self.updateSongInfo()
                self.updatePlayState()
                self.updateLyricState()
                self.updateVideoState()
                self.lastSongHandledByViewController = MusicPlayer.currentSong
        }
        
        center.addObserver(forName: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange,
            object: nil, queue:nil) { _ in
                print ("PlaybackStateDidChange")
                self.updatePlayState()
        }
    }
    
    //MARK: notification handlers
    func updateSongInfo() {
        lblStatus.text = ""
        
        if Utils.inSimulator {
            return
        }
        
        if let item = MusicPlayer.currentSong {
            if item == self.lastSongHandledByViewController {
                print("updateSongInfo called but song has not changed")
                return
            }
            
            lblArtist.text = "\(item.albumArtist ?? item.artist ?? "") - \(item.albumTitle ?? "")"
            lblSong.text = item.title!
            //if it was a liked item, change the state
            let state = LibraryManager.isLiked(item) ?
                LikeState.liked : LikeState.none
            changeLikeState(state)
    
            let newImage = (item.artwork != nil) ?
                item.artwork!.image(at: imgSong.frame.size) : nil
            transitionSongImage(newImage)
            
            LibraryManager.changePlaylistIndex(item)
            //set the scrubber initial values
            scrubber.minimumValue = 0
            scrubber.maximumValue = Float(item.playTime.totalSeconds)
            scrubber.value = 0
            startPlaybackTimer()
        }
        //if we got here there was no song
        else {
            imgSong.image = nil
            lblArtist.text = "[No playlist selected]"
            lblSong.text = ""
            self.timer.invalidate()
        }
        fadePlayButtonsOut()
    }

    
    func updatePlayState() {
        if MusicPlayer.currentSong == self.lastSongHandledByViewController {
            return
        }
        updatePlayButton()
    }
    
    func updatePlayButton() {
        var image: UIImage;
        if MusicPlayer.isPlaying {
            image = UIImage(named:"pause.png")!;
            fadePlayButtonsOut()
            lblStatus.text = ""
        }
        else {
            image = UIImage(named:"play-75.png")!;
            fadePlayButtonsIn()
            lblStatus.text = "Paused"
        }
        btnPlay.setImage(image, for: UIControlState())
    }
    
    func updateLyricState() {
        if MusicPlayer.currentSong == self.lastSongHandledByViewController {
            return
        }
        Async.background {
            Lyrics.fetchUrlFor(MusicPlayer.currentSong)
        }
    }
    
    func updateVideoState() {
        if MusicPlayer.currentSong == self.lastSongHandledByViewController {
            return
        }
        Async.background {
            Videos.fetchVideos(for: MusicPlayer.currentSong)
        }
    }
    
    //MARK: Song scrubber
    var timer = Timer()
    
    func handleScrubberChanged() {
        if let currentSong = MusicPlayer.currentSong {
            if scrubber.timeValue.totalSeconds < currentSong.playTime.totalSeconds {
                //println("scrubber changed: \(scrubber.value)")
                MusicPlayer.playbackTime = scrubber.timeValue.totalSeconds
                startPlaybackTimer()
            } else {
            }
        }
    }
    
    func startPlaybackTimer() {
        //println("scrubber timer started")
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(MainController.updateScrubber), userInfo:nil, repeats:true)
    }
    
    func updateScrubber() {
        let cur : Int = MusicPlayer.playbackTime;
        scrubber.value = Float(cur)
    }

    //MARK: LibraryScanListener
    func libraryScanComplete() {
        Async.main {
            self.btnSearch.tintColor = UIColor.white
            self.displayFadingStatus("\(LibraryManager.songCount) songs in library")
        }
    }
}
