//
//  CalendarViewController.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/16.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    var calendar = FSCalendar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calendar"
        calendar.delegate = self
        calendar.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendar.frame = CGRect(x: 0,
                                y: 100,
                                width: view.frame.size.width,
                                height: view.frame.size.width)
        view.addSubview(calendar)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let fommater = DateFormatter()
        fommater.dateFormat = "EEEE MM-dd-yyyy"
        let string = fommater.string(from: date)
        print("\(string)")
        calendar.scope = .week
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.scope = .month
    }
}
