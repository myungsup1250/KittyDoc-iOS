//
//  AddScheduleViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/02/24.
//

import UIKit

class AddScheduleViewController: UIViewController {

    var tempDaySchedule: daySchedule?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextSetting()
        addSubViews()
        addConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        typeSegment.selectedSegmentIndex = 0
    }
    
    private func addSubViews() {
        view.addSubview(titleLabel)
        view.addSubview(typeSegment)
        view.addSubview(textInput)
        view.addSubview(doneBtn)
    }
    
    private func addConstraints() {
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            typeSegment.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            typeSegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            typeSegment.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            textInput.topAnchor.constraint(equalTo: typeSegment.bottomAnchor, constant: 50),
            textInput.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            doneBtn.topAnchor.constraint(equalTo: textInput.bottomAnchor, constant: 50),
            doneBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeSegment: UISegmentedControl = {
       let segment = UISegmentedControl()
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.insertSegment(withTitle: "병원", at: 0, animated: true)
        segment.insertSegment(withTitle: "사료구매", at: 1, animated: true)
        segment.insertSegment(withTitle: "예방접종", at: 2, animated: true)
        segment.insertSegment(withTitle: "구충제", at: 3, animated: true)
        return segment
    }()
    
    private let textInput: UITextField = {
       let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.placeholder = "내용을 입력하세요"
        return text
    }()
    
    private let doneBtn: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("완료", for: .normal)
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(didTapDoneBtn), for: .touchUpInside)
        return button
    }()
    
    
    
    func titleTextSetting() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let date = dateFormatter.date(from: tempDaySchedule!.day)
        print(tempDaySchedule!.day)
        
        let printDateFormatter = DateFormatter()
        printDateFormatter.dateFormat = "yyyy년 MM월 dd일"
    
        titleLabel.text = printDateFormatter.string(from: date!)
    }
    

    @objc func didTapDoneBtn() {
        if let inputText = textInput.text {
            tempDaySchedule?.title = inputText
        } else {
            print("값 입력 안함")
        }
        
        switch typeSegment.selectedSegmentIndex {
        case 0:
            tempDaySchedule?.type = .hospital
        case 1:
            tempDaySchedule?.type = .bob
        case 2:
            tempDaySchedule?.type = .med
        case 3:
            tempDaySchedule?.type = .snack
        default:
            tempDaySchedule?.type = .none
        }
        
        print("ㅇㅇㅇ")
        
        guard let preVC = self.navigationController?.viewControllers[0] as? CalendarViewController else {
            return
        }

        preVC.daysArr.append(tempDaySchedule!)
        self.navigationController?.popViewController(animated: true)
        
    }
    

}
