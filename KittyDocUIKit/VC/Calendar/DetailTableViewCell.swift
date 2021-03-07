//
//  DetailTableViewCell.swift
//  calendar2
//
//  Created by JEN Lee on 2021/03/06.
//

import UIKit
import RealmSwift

class DetailTableViewCell: UITableViewCell {

    let realm = try! Realm()
    var deleteBtn = UIButton()
    var scheduleLabel = UILabel()
    var typeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(deleteBtn)
        addSubview(scheduleLabel)
        addSubview(typeLabel)
        
        
        configureDeleteBtn()
        configureScheduleLabel()
        configureTypeLabel()
        
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(schedule: daySchedule) {
        scheduleLabel.text = schedule.title
        
        switch schedule.privateType {
        case 0:
            typeLabel.text = "병원"
        case 1:
            typeLabel.text = "사료구매"
        case 2:
            typeLabel.text = "예방접종"
        case 3:
            typeLabel.text = "구충제"
        default:
            typeLabel.text = "선택 사항 없음"
        }
        
    }
    
    func configureDeleteBtn() {
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.backgroundColor = .systemBlue
        deleteBtn.setTitle("삭제", for: .normal)
        deleteBtn.addTarget(self, action: #selector(didTapDeleteBtn), for: .touchUpInside)
    }
    
//    @objc func didTapDeleteBtn() {
//        do{
//            try realm.write{
//                realm.delete()
//            }
//        } catch {
//            print("Error Delete \(error)")
//        }
//
//    }
    
    func configureScheduleLabel() {
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleLabel.numberOfLines = 0
        scheduleLabel.adjustsFontSizeToFitWidth = true
    }
    
    func configureTypeLabel() {
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.textColor = .darkGray
    }
    
    func setConstraint() {
        NSLayoutConstraint.activate([
            scheduleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            scheduleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            deleteBtn.centerYAnchor.constraint(equalTo: centerYAnchor),
            deleteBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            typeLabel.topAnchor.constraint(equalTo: scheduleLabel.bottomAnchor, constant: 8),
            typeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])
    }
}
