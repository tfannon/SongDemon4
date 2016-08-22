//
//  ITunesLookupApi.swift
//  ITunesSwift
//
//  Created by Kazuyoshi Tsuchiya on 2014/09/21.
//  Copyright (c) 2014 tsuchikazu. All rights reserved.
//  Modified by Tommy Fannon, 2016
//

import Foundation
import Alamofire
import Async

public class ITunesLookupApi {
    let url = "https://itunes.apple.com/lookup"
    
    var idType: IdType
    var id: Int
    var entity: Entity?
    var limit: Int?
    var sortType: SortType?
    //var filter: String = ""
    

    public init(idType: IdType = .ITunes, id: Int) {
        self.idType = idType
        self.id = id
    }
    
    public func by(entity: Entity) -> ITunesLookupApi {
        self.entity = entity;
        return self;
    }
    
    public func limit(limit: Int) -> ITunesLookupApi {
        self.limit = limit
        return self
    }
    
    public func sort(sortType: SortType) -> ITunesLookupApi {
        self.sortType = sortType
        return self
    }
    
    //dependencies on AlamoFire and SwiftyJSON
    public func request(completionHandler: @escaping (JSON?, NSError?) -> Void) -> Void {
        let url = self.buildUrl()
        print ("Lookup url: \(url)")
        Alamofire.request(url, withMethod: .get)
            .responseString{ response in
                guard response.result.isSuccess
                else {
                    completionHandler(nil, response.result.error)
                    return
                }
                let json = JSON(data: response.data!)
                completionHandler(json, nil)
        }
    }
    
    internal func buildUrl() -> String {
        var params: [String] = []
        if let entity = self.entity {
            params.append("entity=" + entity.rawValue)
        }
        if let limit = self.limit {
            params.append("limit=" + String(limit))
        }
        if let sort = self.sortType {
            params.append("sort=" + sort.rawValue)
        }
        
        var queryString: String = "?" + idType.rawValue + "=" + String(id) + "&"
        for param: String in params {
            queryString += param + "&"
        }
        
        return self.url + queryString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
}
