//
//  ITunesApi.swift
//  ITunesSwift
//
//  Created by Kazuyoshi Tsuchiya on 2014/09/23.
//  Copyright (c) 2014 tsuchikazu. All rights reserved.
//  Modiifed By Tommy Fannon 2016
//

public class ITunesApi {
    class public func findAll() -> ITunesSearchApi {
        return ITunesSearchApi(media: Media.All)
    }
    class public func find(media: Media) -> ITunesSearchApi {
        return ITunesSearchApi(media: media)
    }
    class public func find(entity: Entity) -> ITunesSearchApi {
        return ITunesSearchApi(entity: entity)
    }
    class public func lookup(id: Int) -> ITunesLookupApi {
        return ITunesLookupApi(idType: .ITunes, id: id)
    }
    class public func lookup(idType: IdType, id: Int) -> ITunesLookupApi {
        return ITunesLookupApi(idType: idType, id: id)
    }
}

//public typealias iTunesApi = ITunesApi
