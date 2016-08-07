//
//  JsonResultsProtocol.swift
//  SongDemon
//
//  Created by Tommy Fannon on 12/9/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import Foundation

protocol JsonResultsDelegate {
    func didReceiveResults(results : NSDictionary)
}
