//
//  PetDeviceTableViewCell.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/05/07.
//

import UIKit

class PetDeviceTableViewCell: UITableViewCell {
    var petImg: UIImageView!
    var petNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initUIViews()
        addSubviews()
        prepareForAutoLayout()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initUIViews() {
        initPetImg()//petImg = UIImageView()
        initPetNameLabel()//petName = UILabel()
    }

    fileprivate func addSubviews() {
        contentView.addSubview(petImg)
        contentView.addSubview(petNameLabel)
    }
    
    func initPetImg() {
        petImg = UIImageView()
        petImg.image = UIImage(imageLiteralResourceName: "PuppyDocImage")
        petImg.clipsToBounds = true
        petImg.contentMode = .scaleAspectFit
//        deviceImg.backgroundColor = .systemBlue
//        deviceImg.layer.cornerRadius = 8

//        return petImg
    }

    func initPetNameLabel() {
        petNameLabel = UILabel()
        petNameLabel.text = "deviceName"
        petNameLabel.font = UIFont.systemFont(ofSize: 30)
//        petNameLabel.textColor = .black
//        petNameLabel.backgroundColor = .white
//        return deviceName
    }
    
    fileprivate func prepareForAutoLayout() {
        petImg.translatesAutoresizingMaskIntoConstraints = false
        petNameLabel.translatesAutoresizingMaskIntoConstraints = false
    }
        
    fileprivate func setConstraints() {
        petImg.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5)
            .isActive = true
        petImg.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5)
            .isActive = true
        petImg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
            .isActive = true
        petImg.centerXAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30)
            .isActive = true
        petImg.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            .isActive = true
        
        petNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            .isActive = true
        petNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
            .isActive = true
//        petNameLabel.heightAnchor.constraint(equalToConstant: 20)
//            .isActive = true
//        petNameLabel.widthAnchor.constraint(equalToConstant: 20)
//            .isActive = true
    }
    
    func setTableViewCell(petType: String = "CAT", petName: String) { // petType: CAT or DOG... etc.
        if petType == "CAT" {
            self.petImg.image = UIImage(imageLiteralResourceName: "PuppyDocImage")
        } else if petType == "DOG" {
            self.petImg.image = UIImage(imageLiteralResourceName: "PuppyDocImage")
        } else {
            self.petImg.image = UIImage(imageLiteralResourceName: "SleepDocImage")
        }
        self.petNameLabel.text = petName + "'s Device"
//        self.deviceUUID.text = peripheralData.peripheral!.identifier.uuidString // uuid?
//        self.rssiLabel.text = String(peripheralData.rssi) + "dbm"
    }}
