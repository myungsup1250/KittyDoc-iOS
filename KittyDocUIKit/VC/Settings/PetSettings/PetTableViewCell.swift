//
//  PetTableViewCell.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/02/01.
//

import UIKit

class PetTableViewCell: UITableViewCell {

   static let identifier = "PetTableViewCell"
    
    let petImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.image = UIImage(systemName: "person")
        imageView.layer.cornerRadius = 48
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    let petNameLabel: UILabel = {
       let petNameLabel = UILabel()
        petNameLabel.font = .boldSystemFont(ofSize: 25)
        return petNameLabel
    }()
    
    let petDetailLabel: UILabel = {
        let petDetailLabel = UILabel()
        
        return petDetailLabel
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(petImageView)
        contentView.addSubview(petNameLabel)
        contentView.addSubview(petDetailLabel)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        petImageView.frame = CGRect(x: 15,
                                    y: 5,
                                    width: contentView.frame.size.height - 10,
                                    height: contentView.frame.size.height - 10)

        petNameLabel.frame = CGRect(x: 130, y: 0, width: contentView.frame.size.width, height: 50)
        petDetailLabel.frame = CGRect(x: 130, y: 40, width: contentView.frame.size.width, height: 50)
    }
}
