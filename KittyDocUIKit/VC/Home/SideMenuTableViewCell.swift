//
//  SideMenuTableViewCell.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/05/03.
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var userimageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
