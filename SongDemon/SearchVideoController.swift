//
//  SearchVideoController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/14/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import UIKit

class SearchVideoController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
