//
//  CalendarCollectionViewCell.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/02/24.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CalendarCollectionViewCell"
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let scheduleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 10)
        return label
    }()
    
    let secondScheduleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 10)
        return label
    }()
    
    let thirdScheduleLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 10)
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(scheduleLabel)
        contentView.addSubview(secondScheduleLabel)
        contentView.addSubview(thirdScheduleLabel)
        
        addContraints()

    }
    
    private func addContraints() {
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            scheduleLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 10),
            scheduleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            scheduleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            secondScheduleLabel.topAnchor.constraint(equalTo: scheduleLabel.bottomAnchor, constant: 3),
            secondScheduleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            secondScheduleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        
        ])
        
        NSLayoutConstraint.activate([
            thirdScheduleLabel.topAnchor.constraint(equalTo: secondScheduleLabel.bottomAnchor, constant: 3),
            thirdScheduleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            thirdScheduleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        
        ])
    }
}
