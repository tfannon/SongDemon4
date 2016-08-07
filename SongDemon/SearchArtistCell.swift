//
//  SearchArtistCell.swift
//  SongDemon
//
//  Created by Tommy Fannon on 11/15/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

class SearchArtistCell: UITableViewCell {

    @IBOutlet weak var imgArtist: UIImageView!
    
    @IBOutlet weak var lblArtist: UILabel!
    @IBOutlet weak var lblInformation: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
