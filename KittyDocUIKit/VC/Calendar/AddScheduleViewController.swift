//
//  AddScheduleViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/02/24.
//

import UIKit
import RealmSwift

class AddScheduleViewController: UIViewController {

    let realm = try! Realm()
    var tempDaySchedule: daySchedule?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextSetting()
        addSubViews()
        addConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        typeMASegment.selectedSegmentIndex = 0
    }
    
    private func addSubViews() {
        view.addSubview(dateLabel)
        view.addSubview(titleLabel)
        view.addSubview(typeMASegment)
        view.addSubview(textBackgroundView)
        textBackgroundView.addSubview(textInput)
        textBackgroundView.addSubview(doneBtn)
        textBackgroundView.addSubview(cancelBtn)
    }
    
    private func addConstraints() {
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        
        ])
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            typeMASegment.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 50),
            typeMASegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            typeMASegment.heightAnchor.constraint(equalToConstant: 60),
            typeMASegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            typeMASegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            textBackgroundView.topAnchor.constraint(equalTo: typeMASegment.bottomAnchor, constant: 50),
            textBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            textBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            textBackgroundView.heightAnchor.constraint(equalToConstant: 300),
            
        ])
        
        NSLayoutConstraint.activate([
            textInput.centerXAnchor.constraint(equalTo: textBackgroundView.centerXAnchor),
            textInput.centerYAnchor.constraint(equalTo: textBackgroundView.centerYAnchor)
        ])
  
        NSLayoutConstraint.activate([
            doneBtn.bottomAnchor.constraint(equalTo: textBackgroundView.bottomAnchor, constant: -20),
            doneBtn.centerXAnchor.constraint(equalTo: textBackgroundView.centerXAnchor, constant: 50),
            doneBtn.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            cancelBtn.bottomAnchor.constraint(equalTo: textBackgroundView.bottomAnchor, constant: -20),
            cancelBtn.centerXAnchor.constraint(equalTo: textBackgroundView.centerXAnchor, constant: -50),
            cancelBtn.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 35, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "일정 추가"
        return label
    }()
    
    private let typeMASegment: MASegmentedControl = {
        
        
        let timeSegmentControl = MASegmentedControl(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        timeSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        timeSegmentControl.selectedSegmentIndex = 0

        timeSegmentControl.itemsWithText = true
        timeSegmentControl.fillEqually = true
        timeSegmentControl.roundedControl = true
        timeSegmentControl.setSegmentedWith(items: ["병원", "사료구매", "예방접종", "구충제"])
        
        timeSegmentControl.padding = 2
        timeSegmentControl.textColor = .black
        timeSegmentControl.selectedTextColor = .white
        timeSegmentControl.thumbViewColor = #colorLiteral(red: 0.3098039216, green: 0.5803921569, blue: 0.831372549, alpha: 1)
        timeSegmentControl.titlesFont = UIFont.systemFont(ofSize: 18, weight: .medium)
    
        return timeSegmentControl
    }()
    
    private let textBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.addColor(color: #colorLiteral(red: 0.7803921569, green: 0.8039215686, blue: 0.8039215686, alpha: 0.6223973154))
        return view
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
        button.backgroundColor = #colorLiteral(red: 0.3098039216, green: 0.5803921569, blue: 0.831372549, alpha: 1)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(didTapDoneBtn), for: .touchUpInside)
        return button
    }()
    
    
    private let cancelBtn: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("취소", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.3098039216, green: 0.5803921569, blue: 0.831372549, alpha: 1)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(didTapCancelBtn), for: .touchUpInside)
        return button
    }()
    
    
    
    
    func titleTextSetting() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let date = dateFormatter.date(from: tempDaySchedule!.day)
        print(tempDaySchedule!.day)
        
        let printDateFormatter = DateFormatter()
        printDateFormatter.dateFormat = "yyyy년 MM월 dd일"
    
        dateLabel.text = printDateFormatter.string(from: date!)
    }
    
    func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            return documentsDirectory
    }
    
    func addScheduleRealm() {
        let tempType = tempDaySchedule?.caretype
        let tempTitle = textInput.text
        let tempDay = tempDaySchedule!.day
        
        let tempRealmSchedule = daySchedule()
        tempRealmSchedule.day = tempDay
        tempRealmSchedule.title = tempTitle!
        tempRealmSchedule.caretype = tempType!
        
        do{
            try realm.write{
                realm.add(tempRealmSchedule)
                print("스케줄 Realm에 넣기 성공")
            }
        } catch {
                print("Error Add \(error)")
        }
    }

    @objc func didTapDoneBtn() {
        if textInput.text?.isEmpty == false {
            tempDaySchedule?.title = textInput.text!
        } else {
            print("값 입력 안함")
            return
        }
        
        switch typeMASegment.selectedSegmentIndex {
        case 0:
            tempDaySchedule?.caretype = .hospital
        case 1:
            tempDaySchedule?.caretype = .bob
        case 2:
            tempDaySchedule?.caretype = .med
        case 3:
            tempDaySchedule?.caretype = .pill
        default:
            tempDaySchedule?.caretype = .none
        }

        addScheduleRealm()
        
        guard let preVC = self.navigationController?.viewControllers[0] as? CalendarViewController else {
                return
            }
        preVC.daysArr.append(tempDaySchedule!)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func didTapCancelBtn() {
        self.navigationController?.popViewController(animated: true)
    }
    


}
