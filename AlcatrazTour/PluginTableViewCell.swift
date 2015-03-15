//
//  PluginTableViewCell.swift
//  AlcatrazTour
//
//  Created by haranicle on 2015/03/14.
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit

class PluginTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avaterImageView: UIImageView!
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
