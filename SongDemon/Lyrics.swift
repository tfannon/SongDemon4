import MediaPlayer

let gLyrics = Lyrics()

enum LyricState {
    case available
    case displayed
    case notAvailable
    case fetching
}

class Lyrics {
    
    var State = LyricState.fetching
    var CurrentUrl = ""

    class func fetchUrlFor(_ item: MPMediaItem?) {
        if !Utils.inSimulator && item == nil { return }
        
        gLyrics.State = .fetching

        var query = "";
        if Utils.inSimulator {
            query = "goatwhore/carvingouttheeyesofgod.html#7"
        }
        else if let song = item {
            var artist = song.albumArtist ?? song.artist;
            //cant fetch lyrics without album artist and a title
            if artist != nil && song.albumTitle != nil && song.title != nil {
                artist = artist!.lowercased().trimmingCharacters(in: CharacterSet.whitespaces).replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
                let album = item!.albumTitle!.lowercased().trimmingCharacters(in: CharacterSet.whitespaces).replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
                let track = String(item!.albumTrackNumber)
                query = "\(artist!)/\(album).html#\(track)"
            }
            else {
                print("Not enough info available for lyric fetch")
                gLyrics.State = .notAvailable
                return
            }
        }
    
        let urlStr = "http://www.darklyrics.com/lyrics/\(query)"
        if gLyrics.CurrentUrl.isEmpty || gLyrics.CurrentUrl != urlStr {
            //println("Loading lyrics for: \(item!.songInfo)")
            gLyrics.State = .available
            gLyrics.CurrentUrl = urlStr
            let vc = RootController.getLyricsController()
            vc.loadLyrics(urlStr)
        }
        else {
            print("using cached lyrics")
        }
    }
}
