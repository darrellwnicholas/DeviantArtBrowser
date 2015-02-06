//
//  BasicCell.swift
//  DeviantArtBrowser
//
//  Created by Darrell Nicholas on 2/5/15.
//  Copyright (c) 2015 Razeware, LLC. All rights reserved.
//

import UIKit

class BasicCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
