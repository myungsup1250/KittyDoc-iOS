//
//  CalendarViewController.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/16.
//

import UIKit
//import FSCalendar
import YMCalendar

class CalendarViewController: UIViewController {
    var userInterfaceStyle: UIUserInterfaceStyle = .unspecified
    var deviceManager = DeviceManager.shared
    var calendarWeekBarView: YMCalendarWeekBarView!
    var calendarView: YMCalendarView!
    var safeArea: UILayoutGuide!

    let symbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    var calendar = Calendar.current

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calendar"
        
        if self.traitCollection.userInterfaceStyle == .light {
            userInterfaceStyle = .light
        } else if self.traitCollection.userInterfaceStyle == .dark {
            userInterfaceStyle = .dark
        } else {
            userInterfaceStyle = .unspecified
        }
        
        print("AnalysisViewController.viewDidLoad()")
        safeArea = view.layoutMarginsGuide
        initUIViews()
        addSubviews()
        prepareForAutoLayout()
        setConstraints()



    }
    
    func initUIViews() {
        initYMCalendar()
        
    }
    func addSubviews() {
        view.addSubview(calendarWeekBarView)
        view.addSubview(calendarView)
        
    }
    func prepareForAutoLayout() {
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarWeekBarView.translatesAutoresizingMaskIntoConstraints = false

    }
    func setConstraints() {
        calendarWeekBarView.topAnchor.constraint(equalTo: safeArea.topAnchor)
            .isActive = true
        calendarWeekBarView.leftAnchor.constraint(equalTo: view.leftAnchor)
            .isActive = true
        calendarWeekBarView.rightAnchor.constraint(equalTo: view.rightAnchor)
            .isActive = true
        calendarWeekBarView.bottomAnchor.constraint(equalTo: safeArea.topAnchor, constant: 25)
            .isActive = true

        calendarView.topAnchor.constraint(equalTo: calendarWeekBarView.bottomAnchor)
            .isActive = true
        calendarView.leftAnchor.constraint(equalTo: view.leftAnchor)
            .isActive = true
        calendarView.rightAnchor.constraint(equalTo: view.rightAnchor)
            .isActive = true
        calendarView.bottomAnchor.constraint(equalTo: calendarView.topAnchor, constant: 300)
            .isActive = true


    }
    func initYMCalendar() {
        calendarWeekBarView = YMCalendarWeekBarView()
        calendarView = YMCalendarView()

        /// WeekBarView
        calendarWeekBarView.appearance = self
        calendarWeekBarView.calendar = calendar
        calendarWeekBarView.backgroundColor = .oceanblue

        /// MonthCalendar

        // Delegates
        calendarView.delegate   = self
        calendarView.dataSource = self
        calendarView.appearance = self

        // Month calendar settings
        calendarView.calendar = calendar
        calendarView.backgroundColor = .white
        calendarView.scrollDirection = .vertical
        calendarView.isPagingEnabled = true

        // Events settings
        calendarView.eventViewHeight  = 14
        calendarView.registerClass(YMEventStandardView.self,
                                   forEventCellReuseIdentifier: "YMEventStandardView")
        calendarView.allowsMultipleSelection = false // User Can't Select Multiple Date Cells
        
    }

    
    // firstWeekday picker

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return symbols[row]
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = symbols[row]
        let attrString = NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        return attrString
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        calendar.firstWeekday = row + 1
        calendarWeekBarView.calendar = calendar
        calendarView.calendar = calendar
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }

}

extension CalendarViewController: YMCalendarWeekBarAppearance {
    func horizontalGridColor(in view: YMCalendarWeekBarView) -> UIColor {
        return .white
    }

    func verticalGridColor(in view: YMCalendarWeekBarView) -> UIColor {
        return .white
    }

    // weekday: Int
    // e.g.) 1: Sunday, 2: Monday,.., 6: Friday, 7: Saturday

    func calendarWeekBarView(_ view: YMCalendarWeekBarView, textAtWeekday weekday: Int) -> String {
        return symbols[weekday - 1]
    }

    func calendarWeekBarView(_ view: YMCalendarWeekBarView, textColorAtWeekday weekday: Int) -> UIColor {
        switch weekday {
        case 1: // Sun
            return .deeppink
        case 7: // Sat
            return .turquoise
        default:
            return .white
        }
    }
}

// MARK: - YMCalendarDelegate
extension CalendarViewController: YMCalendarDelegate {
    func calendarView(_ view: YMCalendarView, didSelectDayCellAtDate date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        navigationItem.title = formatter.string(from: date)
    }

    func calendarView(_ view: YMCalendarView, didMoveMonthOfStartDate date: Date) {
//        // If you want to auto select when displaying month has changed
//        view.selectDayCell(at: date)
    }
}

// MARK: - YMCalendarDataSource
extension CalendarViewController: YMCalendarDataSource {
    func calendarView(_ view: YMCalendarView, dateRangeForEventAtIndex index: Int, date: Date) -> DateRange? {
        if calendar.isDateInToday(date)
            || calendar.isDate(date, inSameDayAs: calendar.endOfMonthForDate(date))
            || calendar.isDate(date, inSameDayAs: calendar.startOfMonthForDate(date)) {
            return DateRange(start: date, end: calendar.endOfDayForDate(date))
        }
        return nil

    }
    
    func calendarView(_ view: YMCalendarView, numberOfEventsAtDate date: Date) -> Int {
        if calendar.isDateInToday(date)
            || calendar.isDate(date, inSameDayAs: calendar.endOfMonthForDate(date))
            || calendar.isDate(date, inSameDayAs: calendar.startOfMonthForDate(date)) {
            return 1
        }
        return 0
    }

    func calendarView(_ view: YMCalendarView, eventViewForEventAtIndex index: Int, date: Date) -> YMEventView {
        guard let view = view.dequeueReusableCellWithIdentifier("YMEventStandardView", forEventAtIndex: index, date: date) as? YMEventStandardView else {
            fatalError()
        }
        if calendar.isDateInToday(date) {
            view.title = "today😃"
        } else if calendar.isDate(date, inSameDayAs: calendar.startOfMonthForDate(date)) {
            view.title = "startOfMonth"
        } else if calendar.isDate(date, inSameDayAs: calendar.endOfMonthForDate(date)) {
            view.title = "endOfMonth"
        }
        view.textColor = .white
        view.backgroundColor = .seagreen
        return view
    }
}

// MARK: - YMCalendarAppearance
extension CalendarViewController: YMCalendarAppearance {
    // grid lines

    func weekBarHorizontalGridColor(in view: YMCalendarView) -> UIColor {
        return .white
    }

    func weekBarVerticalGridColor(in view: YMCalendarView) -> UIColor {
        return .white
    }

    // dayLabel

    func dayLabelAlignment(in view: YMCalendarView) -> YMDayLabelAlignment {
        return .center
    }

    func calendarViewAppearance(_ view: YMCalendarView, dayLabelTextColorAtDate date: Date) -> UIColor {
        let weekday = calendar.component(.weekday, from: date)
        switch weekday {
        case 1: // Sun
            return .deeppink
        case 7: // Sat
            return .turquoise
        default:
            return .white
        }
    }

    // Selected dayLabel Color

    func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectedTextColorAtDate date: Date) -> UIColor {
        return .white
    }

    func calendarViewAppearance(_ view: YMCalendarView, dayLabelSelectedBackgroundColorAtDate date: Date) -> UIColor {
        return .deeppink
    }
}

//class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
//
//    var calendar = FSCalendar()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.title = "Calendar"
//        calendar.delegate = self
//        calendar.dataSource = self
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        calendar.frame = CGRect(x: 0,
//                                y: 100,
//                                width: view.frame.size.width,
//                                height: view.frame.size.width)
//        view.addSubview(calendar)
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
//    }
//
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        let fommater = DateFormatter()
//        fommater.dateFormat = "EEEE MM-dd-yyyy"
//        let string = fommater.string(from: date)
//        print("\(string)")
//        calendar.scope = .week
//    }
//
//    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        calendar.scope = .month
//    }
//}
