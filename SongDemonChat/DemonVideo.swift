//
//  DemonVideo.swift
//  SongDemon
//
//  Created by Adam Rothberg on 8/13/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import Foundation

class DemonVideo {
    private var _title : String
    private var _link : String
    private var _artist : String
    var Title : String { return _title }
    var Link : String { return _link }
    var Artist : String { return _artist }
    var Liked : Bool = false
    
    init(title : String, link : String, artist : String) {
        _title = title
        _link = link
        _artist = artist
    }
}

