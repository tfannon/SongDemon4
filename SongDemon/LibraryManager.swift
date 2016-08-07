
import MediaPlayer

let RECENTLY_ADDED_LIST = "RecentlyAdded"
let DISLIKED_LIST = "Disliked"
let QUEUED_LIST = "Queued"
let CURRENT_LIST = "Current"
let LIKED_LIST = "Liked"


private let LM = LibraryManager()


enum LikeState {
    case liked
    case disliked
    case none
}

enum PlayMode {
    case album
    case artist
    case mix
    case liked
    case new
    case none
    case custom
    case queued
}

class ArtistInfo {
    //var artwork : MPMediaItemArtwork?
    var itunesId: String!
    var songs: Int = 0
    var likedSongs: Int = 0
    var unplayedSongs: Int = 0
    var songIds = [String]()
}

protocol LibraryScanListener {
    func libraryScanComplete() -> Void
}

class LibraryManager {
    //the finals are to get around a performance bug where adding items to a dictionary is very slow
    private final var LikedSongs = Dictionary<String,String>()
    private final var DislikedSongs = Dictionary<String,String>()
    private final var QueuedSongs = Dictionary<String,String>()
    private final var ArtistInfos = Dictionary<String,ArtistInfo>()
    private var songCount = 0
    //computed at load
    private final var RatedSongs = Array<String>()
    private final var LowRatedSongs = Array<String>()
    private final var NotPlayedSongs = Array<String>()
    private final var OtherSongs = Array<String>()
    private var scanned = false
    //playlist 
    private var Playlist = [MPMediaItem]()
    private var GroupedPlaylist = [[MPMediaItem]]()
    private var PlaylistIndex = -1
    private var PlaylistMode = PlayMode.none

    private var LibraryScanListeners = [LibraryScanListener]()


    init() {
        let stopwatch = Stopwatch.start("LibraryManager.init")
        let userDefaults = Utils.AppGroupDefaults;
        if let result = userDefaults.object(forKey: LIKED_LIST) as? Dictionary<String,String> {
            print("\(result.count) liked songs")
            LikedSongs = result
            //result.map { println($0) }
        }
        if let result = userDefaults.object(forKey: DISLIKED_LIST) as? Dictionary<String,String> {
            print("\(result.count) disliked songs")
            DislikedSongs = result
        }
        if let result = userDefaults.object(forKey: QUEUED_LIST) as? Dictionary<String,String> {
            print("\(result.count) queued songs")
            QueuedSongs = result
        }
        stopwatch.stop("")
    }
    
        
    //MARK: computed class properties
    
    class var songCount : Int {
        return LM.songCount
    }
    
    class var currentPlaylist : [MPMediaItem] {
        return LM.Playlist
    }
    
    class var artistInfo : Dictionary<String,ArtistInfo> {
        return LM.ArtistInfos
    }
    
    static func hasArtist(_ name: String) -> Bool {
        return LM.ArtistInfos[name] != nil
    }
    
    
    class var groupedPlaylist : [[MPMediaItem]] {
        return LM.GroupedPlaylist
    }
    
    class var currentPlaylistIndex : Int {
        return LM.PlaylistIndex
    }
    
    class var currentPlayMode : PlayMode {
        return LM.PlaylistMode
    }
    
    //MARK: library scanning
    
    class func addListener(_ listener : LibraryScanListener) {
        LM.LibraryScanListeners.append(listener)
    }
    
    class func scanLibrary() {
        //this is called on a background thread at app start.  make sure that if the user
        //quickly triggers an action which starts another scan, it does not get into this code
        //when it does, the other scan should have flipped the flag so it wont be re-scanned
        if LM.scanned {
            print("lib already scanned")
            return
        }
        var unplayed = 0;

        objc_sync_enter(LM.LikedSongs)
        cleanPlaylists()
        let stopwatch = Stopwatch.start("scanLibrary")
        
        if let allSongs = ITunesUtils.getAllSongs() {
            LM.songCount = allSongs.count
            for song in allSongs {
                if let artist = song.albumArtist {
                    var artistInfo : ArtistInfo? = LM.ArtistInfos[artist]
                    //grab some artwork
                    if artistInfo == nil {
                        artistInfo = ArtistInfo()
                        artistInfo?.itunesId = song.artistHashKey
                        LM.ArtistInfos[artist] = artistInfo
                    }
//                    if artistInfo!.artwork == nil {
//                        artistInfo!.artwork = song.artwork
//                    }
                    //increment number of songs in library
                    artistInfo!.songs += 1

                    //an album must have an album artist and title and a rating to make the cut
                    if song.albumArtist != nil && song.title != nil {
                        var disliked = LM.DislikedSongs[song.hashKey] != nil

                        if song.rating >= 1 {
                            switch (song.rating) {
                            case 0:""
                            //we take 1 star to mean disliked in itunes
                            case 1:
                                disliked = true
                                LM.LowRatedSongs.append(song.hashKey)
                            //any rating > 1 qualifies
                            default:
                                LM.RatedSongs.append(song.hashKey)
                                artistInfo!.likedSongs += 1

                            }
                        }
                        else if song.playCount >= 0 && song.playCount <= 2 {
                            LM.NotPlayedSongs.append(song.hashKey)
                            unplayed += 1
                            artistInfo!.unplayedSongs += 1
                        }
                        else {
                            LM.OtherSongs.append(song.hashKey)
                        }
                        if !disliked {
                            artistInfo!.songIds.append(song.hashKey)
                        }
                    }
                }
            }
            stopwatch.stop("Scanned \(allSongs.count) songs\n  \(LM.RatedSongs.count) songs with >1 rating \n  \(LM.LowRatedSongs.count) songs with =1 rating \n  \(unplayed) songs with playcount <2 \n  \(LM.OtherSongs.count) others songs\n")
        }
        LM.scanned = true;
        objc_sync_exit(LM.LikedSongs)
        for x in LM.LibraryScanListeners {
            x.libraryScanComplete()
        }
    }
    
    //MARK: functions for adding to lists

    class func addToLiked(_ item:MPMediaItem) {
        addToList(LIKED_LIST, list: &LM.LikedSongs, item: item)
    }
    
    class func removeFromLiked(_ item:MPMediaItem) {
        removeFromList(LIKED_LIST, list: &LM.LikedSongs, item: item)
    }
    
    class func addToDisliked(_ item:MPMediaItem) {
        addToList(DISLIKED_LIST, list: &LM.DislikedSongs, item: item)
        //adding it to disliked will remove it from liked
        removeFromLiked(item)
    }

    class func addToQueued(_ item: MPMediaItem) {
        addToList(QUEUED_LIST, list: &LM.QueuedSongs, item: item)
    }

    class func addToQueued(_ items: [MPMediaItem]) {
        addToList(QUEUED_LIST, list: &LM.QueuedSongs, items: items)
    }
    
    class func removeFromQueued(_ item: MPMediaItem) {
        removeFromList(QUEUED_LIST, list: &LM.QueuedSongs, item: item)
    }
    
    class func removeFromQueued(_ items: [MPMediaItem]) {
        removeFromList(QUEUED_LIST, list: &LM.QueuedSongs, items: items)
    }
    
    class func clearQueued() {
        LM.QueuedSongs.removeAll(keepingCapacity: false)
        let userDefaults = Utils.AppGroupDefaults
        userDefaults.set(LM.QueuedSongs as Dictionary<NSObject,AnyObject>, forKey: QUEUED_LIST)
    }
    
    class func isLiked(_ item:MPMediaItem?) -> Bool {
        return item != nil && LM.LikedSongs[item!.hashKey] != nil
    }
    
    class func isDisliked(_ item:MPMediaItem?) -> Bool {
        return item != nil && LM.DislikedSongs[item!.hashKey] != nil
    }
    
    
    //MARK: private list helpers
    
    //key is PersistentId but since persistent id can change we will store the other parts so we can 
    //do a reverse lookup in the event we need to rebuild the lists
    private class func addToList(_ listName:String, list:inout Dictionary<String,String>, item:MPMediaItem?) {
        if let song = item {
            let val = "\(song.albumArtist):\(song.albumTitle):\(song.title)"
            list[song.hashKey] = val
            let userDefaults = Utils.AppGroupDefaults
            userDefaults.set(list as Dictionary<NSObject,AnyObject>, forKey: listName)
        }
    }
    
    private class func addToList(_ listName:String, list: inout Dictionary<String,String>, items:[MPMediaItem]) {
        for item in items {
            list[item.hashKey] = item.title
        }
        let userDefaults = Utils.AppGroupDefaults
        userDefaults.set(list as Dictionary<NSObject,AnyObject>, forKey: listName)
    }
   
    private class func removeFromList(_ listName:String, list:inout Dictionary<String,String>, item:MPMediaItem?) {
        if (item != nil) {
            list.removeValue(forKey: item!.hashKey);
            let userDefaults = Utils.AppGroupDefaults
            userDefaults.set(list as Dictionary<NSObject,AnyObject>, forKey: listName)
        }
    }
    
    private class func removeFromList(_ listName:String, list: inout Dictionary<String,String>, items:[MPMediaItem]) {
        for item in items {
            list.removeValue(forKey: item.hashKey)
        }
        let userDefaults = Utils.AppGroupDefaults
        userDefaults.set(list as Dictionary<NSObject,AnyObject>, forKey: listName)
    }
    
    
    //MARK: functions for getting playlists
    
     /* run a query to see all items > 1 star in itunes and merge this with current liked */
    class func getLikedSongs(_ count : Int = 50, dumpSongs : Bool = false) -> [MPMediaItem] {
        scanLibrary()
         let sw = Stopwatch.start()
        //take all the SongDemon liked songs
        var allLiked : [String] = LM.LikedSongs.keys.map { $0 }
        //add all the iTunes-rated songs
        allLiked.append(contentsOf: LM.RatedSongs)
        //grab n randomly
        let randomLiked = getRandomSongs(count, sourceSongs: allLiked)
        sw.stop("Built liked list with \(randomLiked.count) songs")
        if dumpSongs {
            outputSongs(randomLiked)
        }
        LM.Playlist = randomLiked
        LM.GroupedPlaylist = [[MPMediaItem]](arrayLiteral: randomLiked)
        LM.PlaylistIndex = 0
        LM.PlaylistMode = .liked
        return randomLiked
    }
    
    class func getNewSongs(_ count : Int = 50, dumpSongs : Bool = false) -> [MPMediaItem] {
        scanLibrary()
        let start = Date()
        LM.GroupedPlaylist = [[MPMediaItem]]()
        let newSongs = getRandomSongs(count, sourceSongs: LM.NotPlayedSongs)
        let time = Date().timeIntervalSince(start) * 1000
        if dumpSongs {
            print("Built new song list with \(newSongs.count) songs in \(time)ms")
            outputSongs(newSongs)
        }
        LM.Playlist = newSongs
        LM.GroupedPlaylist.append(newSongs)
        LM.PlaylistIndex = 0
        LM.PlaylistMode = .new
        return newSongs
    }
    
    class func getMixOfSongs(_ count : Int = 50, dumpSongs : Bool = false) -> [MPMediaItem] {
        scanLibrary()
        let sw = Stopwatch.start()
        let allSongs = LM.RatedSongs + LM.NotPlayedSongs + LM.OtherSongs
        let randomSongs = getRandomSongs(count, sourceSongs: allSongs)
        sw.stop("Built mix list with \(randomSongs.count) songs")

        if dumpSongs {
            outputSongs(randomSongs)
        }
        LM.GroupedPlaylist = [[MPMediaItem]](arrayLiteral: randomSongs)
        LM.Playlist = randomSongs
        LM.PlaylistIndex = 0
        LM.PlaylistMode = .mix
        return randomSongs;
    }
    
    class func getRecentlyAdded() -> [MPMediaItem] {
        scanLibrary()
        let start = Date()
        var songs = [MPMediaItem]()
        let itunesPlaylists = ITunesUtils.getPlaylists([RECENTLY_ADDED_LIST])
        if let recent = itunesPlaylists[RECENTLY_ADDED_LIST] {
            for x in recent {
                if let song = ITunesUtils.getSongFrom(x) {
                    songs.append(song)
                }
            }
        }
        let time = Date().timeIntervalSince(start) * 1000
        print("Built recently added song list with \(songs.count) songs in \(time)ms")
        //makePlaylistFromSongs(songs, c nil)
        return songs
    }

    
    //grab a bunch of songs by current artist
    class func getArtistSongs(_ currentSong : MPMediaItem?) -> [MPMediaItem] {
        //album->*song
        let stopwatch = Stopwatch()
        LM.Playlist = [MPMediaItem]()
        LM.GroupedPlaylist = [[MPMediaItem]]()
        if currentSong != nil {
            (LM.GroupedPlaylist, LM.Playlist) = getArtistSongsWithoutSettingPlaylist(currentSong)
        }
        let time = stopwatch.stop()
        print("Built artist songlist with \(LM.GroupedPlaylist.count) albums and \(LM.Playlist.count) songs in \(time)ms")
        LM.PlaylistIndex = LM.Playlist.index(of: currentSong!)!
        LM.PlaylistMode = .artist
        return LM.Playlist
    }
    
    //this services the search functionality which has selected a song via the artist/album picker
    class func setPlaylistFromSearch(_ songsForPlaylist : [[MPMediaItem]], songsForQueue : [MPMediaItem], songToStart : MPMediaItem) {
        LM.PlaylistMode = .artist
        LM.Playlist = songsForQueue
        LM.GroupedPlaylist = songsForPlaylist
        LM.PlaylistIndex = LM.Playlist.index(of: songToStart)!
        MusicPlayer.queuePlaylist(songsForQueue, songToStart: songToStart, startNow: true)
    }
    
    class func getAlbumSongs(_ currentSong : MPMediaItem?) -> [MPMediaItem] {
        let stopwatch = Stopwatch()
        LM.Playlist = [MPMediaItem]()
        LM.GroupedPlaylist = [[MPMediaItem]]()
        if currentSong != nil {
            LM.Playlist  = getAlbumSongsWithoutSettingPlaylist(currentSong)
            LM.GroupedPlaylist.append(LM.Playlist)
        }
        let time = stopwatch.stop()
        print("Built album songlist with \(LM.GroupedPlaylist.count) albums and \(LM.Playlist.count) songs in \(time)ms")
        LM.PlaylistIndex = LM.Playlist.index(of: currentSong!)!
        LM.PlaylistMode = .album
        return LM.Playlist
    }
    
    class func getQueuedSongs() -> [MPMediaItem] {
        LM.GroupedPlaylist = [[MPMediaItem]]()
//        var songs = [MPMediaItem]()
        let songs: [MPMediaItem] = LM.QueuedSongs.map { ITunesUtils.getSongFrom($0.0)! }
//        for (x,_) in LM.QueuedSongs {
//            if let item = ITunesUtils.getSongFrom(x) {
//                songs.append(item)
//            }
//        }
        LM.Playlist = songs
        LM.GroupedPlaylist.append(songs)
        LM.PlaylistIndex = 0
        LM.PlaylistMode = PlayMode.queued
        return songs
    }
    

    class func makePlaylistFromSongs(_ songs: [MPMediaItem]) {
        LM.GroupedPlaylist = [[MPMediaItem]]()
        LM.Playlist = songs
        LM.GroupedPlaylist.append(songs)
        LM.PlaylistIndex = 0
        LM.PlaylistMode = .custom
    }
    
    class func getAlbumSongsWithoutSettingPlaylist(_ currentSong : MPMediaItem?) -> [MPMediaItem] {
        var songs = [MPMediaItem]()
        if currentSong != nil {
            let query = MPMediaQuery.songs()
            let pred = MPMediaPropertyPredicate(value: currentSong!.albumTitle, forProperty: MPMediaItemPropertyAlbumTitle)
            query.addFilterPredicate(pred)
            let albumSongs = query.items as [MPMediaItem]!
            songs = (albumSongs?.sorted { $0.albumTrackNumber < $1.albumTrackNumber })!
            outputSongs(songs)
        }
        return songs
    }
    
    
    class func getArtistSongsWithoutSettingPlaylist(_ currentSong : MPMediaItem?) -> ([[MPMediaItem]], [MPMediaItem]) {
        if currentSong != nil {
            return getArtistSongsWithoutSettingPlaylist(currentSong!.albumArtist!)
        }
        return ([[MPMediaItem]](),[MPMediaItem]())
    }
    
    //return tuple of grouped songs and songs
    class func getArtistSongsWithoutSettingPlaylist(_ artist : String) -> ([[MPMediaItem]], [MPMediaItem]) {
        print("getArtistSongs")
        //album->*song
        var songs = [MPMediaItem]()
        var groupedSongs = [[MPMediaItem]]()
        
        let query = MPMediaQuery.songs()
        let pred = MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyAlbumArtist)
        query.addFilterPredicate(pred)
        let artistSongs = query.items as [MPMediaItem]!
        var albumDic = [String:[MPMediaItem]](minimumCapacity: (artistSongs?.count)!)
        //fill up the dictionary with songs
        for x in artistSongs! {
            if let albumTitle = x.albumTitle {
                if albumDic.index(forKey: albumTitle) == nil {
                    albumDic[albumTitle] = [MPMediaItem]()
                }
                albumDic[albumTitle]!.append(x)
                //print ("adding \(x.songInfo)")
            }
            else {
                print ("skipping \(x.songInfo) because album title was blank")
            }
        }
        
        //get them back out by album and insert into array of arrays
        for (_,y) in albumDic {
            let sorted = y.sorted { $0.albumTrackNumber < $1.albumTrackNumber }
            groupedSongs.append(sorted)
        }
        //now sort the grouped playlist by year
        groupedSongs.sort { $0[0].year > $1[0].year }
        //now add all the groupplaylist into one big playlist for the media player
        for album in groupedSongs {
            songs.append(contentsOf: album)
        }
        //outputSongs(songs)
        return (groupedSongs, songs)
    }
    
    class func changePlaylistIndex(_ currentSong : MPMediaItem) {
        let index = LM.Playlist.index(of: currentSong)
        if index != nil {
            LM.PlaylistIndex = index!
            print("Setting playlist index to: \(currentSong.songInfo))")
        }
    }
    
    
    /*
    Artist mode -> pull to refresh will shuffle
    Album mode -> pull to refresh will shuffle
    Mix mode -> pull to refresh will fetch different songs
    */
    
    //MARK: private helper functions

    private class func getRandomSongs(_ count : Int, sourceSongs : [String]) -> [MPMediaItem] {
        var randomSongs = [MPMediaItem]()
        var songsPicked = 0
        var i = 0
        while i < sourceSongs.count && songsPicked < count {
            let idx = Utils.random(sourceSongs.count)
            if let item = ITunesUtils.getSongFrom(sourceSongs[idx]) {
                //if it hasnt been disliked or already added
                if !isDisliked(item) && randomSongs.index(of: item) == nil {
                    randomSongs.append(item)
                    songsPicked += 1
                }
            }
            else {
                print("Cannot find \(sourceSongs[idx]) in iTunes")
            }
            i += 1
        }
        return randomSongs
    }
    
    internal class func outputSongs(_ songs: [MPMediaItem]) {
        var i = 0
        for s in songs {
             print ("\(i)  \(s.songInfo)")
            i += 1
        }
        print("")
    }
    

    private class func dumpNSUserDefaults(_ forList:String) -> Void {
        let userDefaults = Utils.AppGroupDefaults
        if let songsFromDefaults = userDefaults.object(forKey: forList) as? Dictionary<String,String> {
            print("Current defaults: \(songsFromDefaults)")
        } else {
            print("No userDefaults")
        }
    }
    
  
    
    //MARK: functions for generating playlists for watch
    class func serializePlaylist(_ serializeKey: String, songs : [MPMediaItem]) {
        let ids : [String] = songs.map { song in
            song.hashKey
        }
        if ids.count > 0 {
            let userDefaults = Utils.AppGroupDefaults;
            userDefaults.set(ids, forKey: serializeKey)
        }
    }

    class func trimList(_ listName : String, list : inout [String:String]) {
        let defaults = Utils.AppGroupDefaults
        let trimmed = list.filter { ITunesUtils.getSongFrom($0.0) != nil }
        defaults.set(trimmed, forKey: listName)
    }
    
    class func cleanPlaylists() {
        let sw = Stopwatch.start("cleanPlaylists")
        trimList(LIKED_LIST, list: &LM.LikedSongs)
        trimList(DISLIKED_LIST, list: &LM.DislikedSongs)
        trimList(QUEUED_LIST, list: &LM.QueuedSongs)
        sw.stop()
    }
}
