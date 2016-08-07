//
//  SongInfo.swift
//  SongDemon
//
//  Created by Tommy Fannon on 7/28/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//


struct SongInfo {
    let Id : String
    let playCount : Int
    let rating : Int

    init (id : String, rating : Int, playCount : Int) {
        self.Id = id;
        self.rating = rating;
        self.playCount = playCount
    }
}
