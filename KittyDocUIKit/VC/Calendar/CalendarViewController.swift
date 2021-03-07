//
//  CalendarViewController.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/16.
//

import UIKit

class CalendarViewController: UIViewController {
    let now = Date()
    var cal = Calendar.current
    let dateFormatter = DateFormatter()
    var components = DateComponents()
    var weeks: [String] = ["일", "월", "화", "수", "목", "금", "토"]
    var days: [String] = []
    var daysCountInMonth = 0 // 해당 월이 며칠까지 있는지
    var weekdayAdding = 0 // 시작일
    var daysArr: [daySchedule] = []
    
    

    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private let TitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeSegment: UISegmentedControl = {
       let segment = UISegmentedControl()
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.insertSegment(withTitle: "전체", at: 0, animated: true)
        segment.insertSegment(withTitle: "병원", at: 1, animated: true)
        segment.insertSegment(withTitle: "사료구매", at: 2, animated: true)
        segment.insertSegment(withTitle: "예방접종", at: 3, animated: true)
        segment.insertSegment(withTitle: "구충제", at: 4, animated: true)
        segment.addTarget(self, action: #selector(didTapTypeSegment), for:.valueChanged)
        return segment
    }()
    
    
    
    private let preMonthBtn: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("이전 달", for: .normal)
        button.addTarget(self, action: #selector(didTapPreMonthButton), for: .touchUpInside)
        return button
    }()
    
    
    private let nextMonthBtn: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("다음 달", for: .normal)
        button.addTarget(self, action: #selector(didTapNextMonthButton), for: .touchUpInside)
        return button
    }()
    
    
    private let calendar: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let calendar = UICollectionView(frame: .zero, collectionViewLayout: layout)
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.backgroundColor = .clear
        
        return calendar
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        addSubViews()
        addConstraints()
        initCollection()
        initgesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.calendar.reloadData()
        typeSegment.selectedSegmentIndex = 0
    }
    
    private func addSubViews() {
        view.addSubview(headerView)
        headerView.addSubview(TitleLabel)
        headerView.addSubview(typeSegment)
        headerView.addSubview(preMonthBtn)
        headerView.addSubview(nextMonthBtn)
        view.addSubview(calendar)
    }
    
    private func addConstraints() {
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130)
        ])
        
        
        NSLayoutConstraint.activate([
            TitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            TitleLabel.bottomAnchor.constraint(equalTo: typeSegment.topAnchor, constant: -20)
        ])
        
        
        NSLayoutConstraint.activate([
            typeSegment.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            typeSegment.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            preMonthBtn.bottomAnchor.constraint(equalTo: TitleLabel.bottomAnchor),
            preMonthBtn.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 30)
        ])
        
        NSLayoutConstraint.activate([
            nextMonthBtn.bottomAnchor.constraint(equalTo: TitleLabel.bottomAnchor),
            nextMonthBtn.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -30)
        ])
        
        
        
        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 15),
            calendar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            calendar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            calendar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])

        
    }
    
    private func initCollection() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: "CalendarCollectionViewCell")
        
        dateFormatter.dateFormat = "yyyy년 M월"
        components.year = cal.component(.year, from: now)
        components.month = cal.component(.month, from: now)
        components.day = 1
        self.calculation()
    }
    
    private func initgesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        self.calendar.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.calendar)
        let indexPath = self.calendar.indexPathForItem(at: p)
        
        if indexPath != nil {
            if longPressGesture.state == UIGestureRecognizer.State.began {
                let storyboard = UIStoryboard(name: "CalendarStoryboard", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "AddSchedule") as! AddScheduleViewController
                
                controller.tempDaySchedule = daySchedule()
                
                let cell = self.calendar.cellForItem(at: indexPath!) as! CalendarCollectionViewCell
                
                guard let day = cell.dayLabel.text else {
                    return
                }
                
                guard let intDay = Int(day) else {
                    return
                }
                
                let selectedDay = formatterDateFunc() +  formatterDayFunc(input: intDay)//yyyyMMdd
                controller.tempDaySchedule?.day = selectedDay
                
                self.navigationController?.pushViewController(controller
                                                              , animated: true)
            }
        }
    }
    
    @objc func didTapTypeSegment() {
        self.calendar.reloadData()
    }
    
    @objc func didTapPreMonthButton() {
        components.month = components.month! - 1
        self.calculation()
        self.calendar.reloadData()
    }
    
    @objc func didTapNextMonthButton() {
        components.month = components.month! + 1
        self.calculation()
        self.calendar.reloadData()
    }
    

    func calculation() {
        let firstDayOfMonth = cal.date(from: components)
        let firstWeekDay = cal.component(.weekday, from: firstDayOfMonth!)
        daysCountInMonth = cal.range(of: .day, in: .month, for: firstDayOfMonth!)!.count
        
        weekdayAdding = 2 - firstWeekDay
        
        self.TitleLabel.text = dateFormatter.string(from: firstDayOfMonth!)
        self.days.removeAll()
        
        for day in weekdayAdding...daysCountInMonth {
            if day < 1 { // 1보다 작을 경우는 비워줘야 하기 때문에 빈 값을 넣어준다.
                self.days.append("")
            } else {
                self.days.append(String(day))
            }
        }
    }
    
    func formatterDateFunc() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        let currentYM = cal.date(from: components)!
        return formatter.string(from: currentYM)
    }
    
    func formatterDayFunc(input: Int) -> String {
        if input < 10 {
            return String(0) + String(input)
        }
        return String(input)
    }
    
    func showTypeSchedule(type: Int, index: Int, cell: UICollectionViewCell) {
        switch type {
        case 0:
            showSchedule(type: .none, index: index, cell: cell, color: .systemYellow)
        case 1:
            showSchedule(type: .hospital, index: index, cell: cell, color: .orange)
        case 2:
            showSchedule(type: .bob, index: index, cell: cell, color: .magenta)
        case 3:
            showSchedule(type: .med, index: index, cell: cell, color: .systemPink)
        default:
            showSchedule(type: .snack, index: index, cell: cell, color: .green)
        }
    }
    
    
    //보여주는 함수
    func showSchedule(type: careType, index: Int, cell: UICollectionViewCell, color: UIColor) {
        for dayData in daysArr {
            let date = dayData.day
            let endIdx: String.Index = date.index(date.startIndex, offsetBy: 5)
            let startIdx: String.Index = date.index(date.startIndex, offsetBy: 6)
            
            let ym = String(date[...endIdx]) //202102
            let d = String(date[startIdx...]) //12
            
            if formatterDateFunc() == ym {
                if Int(d) == Int(days[index]) {
                    if type == .none {
                        cell.backgroundColor = color
                    }
                    else if type == dayData.type {
                        cell.backgroundColor = color
                    }
                    
                }
                
            }
            
        }
    }
    
    func showTitleSchedule(index: Int, cell: CalendarCollectionViewCell) {
        for dayData in daysArr {
            let date = dayData.day
            let endIdx: String.Index = date.index(date.startIndex, offsetBy: 5)
            let startIdx: String.Index = date.index(date.startIndex, offsetBy: 6)

            let ym = String(date[...endIdx]) //202102
            let d = String(date[startIdx...]) //12

            if formatterDateFunc() == ym {
                if Int(d) == Int(days[index]) {
                    cell.scheduleLabel.text = dayData.title

                }

            }

        }
    }

}




extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 7
        default:
            return self.days.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calendar.dequeueReusableCell(withReuseIdentifier: CalendarCollectionViewCell.identifier, for: indexPath) as! CalendarCollectionViewCell
        
        switch indexPath.section {
        case 0:
            cell.dayLabel.text = weeks[indexPath.row]
        default:
            cell.dayLabel.text = days[indexPath.row]
        }
        
        if indexPath.row % 7 == 0 {
            cell.dayLabel.textColor = .red
        } else if indexPath.row % 7 == 6 {
            cell.dayLabel.textColor = .blue
        } else {
            cell.dayLabel.textColor = .black
        }
        
        cell.backgroundColor = .systemBackground
        cell.scheduleLabel.text = ""
        
    
        switch indexPath.section {
        case 0:
            break
        default:
            showTypeSchedule(type: typeSegment.selectedSegmentIndex, index: indexPath.row, cell: cell)
            showTitleSchedule(index: indexPath.row, cell: cell)
        }
        
        
        return cell
    }
    
    
}

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let myBoundSize: CGFloat = UIScreen.main.bounds.size.width
        let cellSize = myBoundSize / 9

        switch indexPath.section {
        case 0:
            return CGSize(width: cellSize, height: 40)
        default:
            return CGSize(width: cellSize, height: 80)
        }
    }
    

}

