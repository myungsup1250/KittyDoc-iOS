//
//  AnalysisViewController.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/16.
//

import UIKit
import Charts
import MASegmentedControl

class AnalysisViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var chartSelect: UISegmentedControl!
    @IBOutlet weak var dateTextField: ConstantUITextField!
    @IBOutlet weak var chartDateLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueUnitLabel: UILabel!
    @IBOutlet weak var calBtn: UIButton!
    @IBOutlet weak var dataPickerView: UIPickerView!
    var timeSegmentControl: MASegmentedControl!
    //var optionTextField: ConstantUITextField!
    var datePicker: UIDatePicker!
    var yearMonthPickerView: DatePickerView!
    var yearPickerView: YearPickerView!
    //var pickerView: UIPickerView!
    var barChartView: BarChartView!
    var highlighted = Highlight()

    var userInterfaceStyle: UIUserInterfaceStyle!
    var deviceManager = DeviceManager.shared
    var safeArea: UILayoutGuide!
    var dateInput: String = ""
    var petDatas = [PetData]()
    var dateFormatter: DateFormatter!

    var optionsIndex = 7//0
    let options = [ "Sun", "UV", "Vitmin D", "Exercise", "Walk", "Steps", "LuxPolution", "Rest", "Kal", "Water"]
    let units = [ "Sun", "UV", "Vitmin D", "Exercise", "Walk", "Steps", "LuxPolution", "Rest", "Kal", "Water"] // 추후 맞는 단위로 수정필요
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let days = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
    let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let times = ["00시", "01시", "02시", "03시", "04시", "05시", "06시", "07시", "08시", "09시", "10시", "11시", "12시", "13시", "14시", "15시", "16시", "17시", "18시", "19시", "20시", "21시", "22시", "23시"]
        //["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        safeArea = view.safeAreaLayoutGuide
        userInterfaceStyle = self.traitCollection.userInterfaceStyle
        dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent

        initUIViews()
        addSubviews()
        prepareForAutoLayout()
        setConstraints()
        manageUserInterfaceStyle()
        addObservers()

        refreshChartData()
        chartOptionChanged(selected: SegSelect(rawValue: timeSegmentControl.selectedSegmentIndex)!, pickerOption: options[optionsIndex])
        // segSelect = 2 : Day
        // Initial Setup : Day && Sun && CurrentDate
    }
    
    
    private func refreshChartData() {
        valueLabel.text = "0"
        valueUnitLabel.text = units[optionsIndex]
        chartDateLabel.text = ""
        petDatas.removeAll()
        petDatas = requestServerData()//센서 데이터 수신 코드
    }
    
    fileprivate func requestServerData() -> [PetData] {//(forDays: UInt, forHours: UInt) -> [PetData] {
        var dataArray = [PetData]()
        let hourInSec: TimeInterval = 3600
        let dayInSec: TimeInterval = 86400 // 24Hours in seconds

        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentCal = Calendar.current
        let today = Date()
        let segDate = dateFormatter.date(from: dateFormatter.string(from: datePicker.date))!// Multiple Castings to get exact day without extra seconds
        guard currentCal.compare(segDate, to: today, toGranularity: .day) != .orderedDescending else {
            print("segDate(\(unixtimeToString(unixtime: segDate.timeIntervalSince1970))) and today(\(unixtimeToString(unixtime: today.timeIntervalSince1970))) is not orderedDescending, [There will be no data!]")
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "ERROR in Date!", message: "There is no data for future!", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "Confirm", style: .default) { _ in
                    self.yearPickerView.selectToday()
                    self.yearMonthPickerView.selectToday()
                    self.manageDateFormatter(date: Date())
                    self.dateTextField.becomeFirstResponder()
                }
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)
            }
            return []
        }

        var endTime: TimeInterval = 0
        var startTime: TimeInterval = 0
        let segDateYear = currentCal.component(.year,  from: segDate)
        let segDateMonth = currentCal.component(.month,  from: segDate)
        let segDateDay = currentCal.component(.day,  from: segDate)
        let segSelect = SegSelect(rawValue: timeSegmentControl.selectedSegmentIndex)!//chartSelect.selectedSegmentIndex)!
        let timeIntervalSince1970 = today.timeIntervalSince1970
        let timeIntervalFromMidnight = TimeInterval(Int(timeIntervalSince1970 + hourInSec * 9) % Int(dayInSec))
        //print("segDate(\(unixtimeToString(unixtime: segDate.timeIntervalSince1970))) and today(\(unixtimeToString(unixtime: today.timeIntervalSince1970)))")
        
        switch segSelect {
        case .Year:
            print("[ Year Data! ]")
            // Comparison on Year will be processed on chartOptionChanged()
        case .Month:
            print("[ Month Data! ]")//\(segDateMonth)월 1~\(segDateDay)일간의 데이터만을 불러옵니다.]")
            // 현재 일자까지만 나오도록 1달 데이터를 자르는 기능 -> 제거 21.05.04
//            if Calendar.current.compare(segDate, to: today, toGranularity: .month) == .orderedSame {
//                print("Same Month!")
//
//                endTime = TimeInterval((segDate.timeIntervalSince1970 + dayInSec - 1) * 1000)
//                startTime = endTime - TimeInterval((dayInSec * Double(segDateDay)) * 1000)
//            } else if comparisonResult == .orderedAscending {
//                print("orderedAscending!")
//
//                endTime = (tmpDate.timeIntervalSince1970 + dayInSec - 1) * 1000
//                startTime = endTime - (dayInSec * Double(daysOfThisMonth) - 1) * 1000
//            }
            guard let daysOfThisMonth = getDaysInMonth(month: segDateMonth, year: segDateYear) else {
                print("Error in getDaysInMonth(month: , year:)!!")
                return []
            }
            let tmpDate = dateFormatter.date(from: String(segDateYear)+"-"+String(segDateMonth)+"-"+String(daysOfThisMonth))!

            endTime = (tmpDate.timeIntervalSince1970 + dayInSec - 1) * 1000
            startTime = endTime - (dayInSec * Double(daysOfThisMonth) - 1) * 1000
        case .Day:
            print("[ Day Data! ]")
            let comparisonResult = currentCal.compare(segDate, to: today, toGranularity: .day)
            if comparisonResult == .orderedSame {
                print("Same Day!")

                // 00시부터 지금까지
                startTime = (timeIntervalSince1970 - timeIntervalFromMidnight) * 1000
                endTime = timeIntervalSince1970 * 1000
            } else if comparisonResult == .orderedAscending {
                print("orderedAscending!")

                startTime = segDate.timeIntervalSince1970 * 1000
                endTime = startTime + dayInSec * 1000
                // frontTime : 00:00:24이어야 전날 00시부터 24개 데이터 받아온다?!
            }
        case .Week:
            print("[ Week Data! 7일간(\(segDateMonth)월 \(segDateDay)일 포함)의 데이터를 불러옵니다.]")
            //let weekday = currentCal.component(.weekday, from: segDate)
            //startTime = Int((segDate.timeIntervalSince1970 - (dayInSec * Double(weekday - 1))) * 1000)
            startTime = (segDate.timeIntervalSince1970 - dayInSec * 6) * 1000
            endTime = (segDate.timeIntervalSince1970 + dayInSec - 1) * 1000
        }
        print("requestServerData(From : \(unixtimeToString(unixtime: startTime / 1000))), Til : \(unixtimeToString(unixtime: endTime / 1000)))")
        //print("startTime RAW : \(startTime), endTime RAW : \(endTime)")

        let petID = 41// // // // // // // // // //
        let analysisData = AnalysisData(_petID: petID, _startMilliSec: Int(startTime), _endMilliSec: Int(endTime))
        let server = KittyDocServer()
        var analysisResponse: ServerResponse!
        
        switch segSelect {
        case .Year:
            print("server.sensorRequestYear()")
            let analData_Year = AnalysisData_Year(_petID: petID, _year: segDateYear)
            analysisResponse = server.sensorRequestYear(data: analData_Year)
        case .Month, .Week:
            print("server.sensorRequestDay(Month)")
            analysisResponse = server.sensorRequestDay(data: analysisData)
        case .Day:
            print("server.sensorRequestHour()")
            analysisResponse = server.sensorRequestHour(data: analysisData)
        }
        
        if(analysisResponse.getCode() as! Int == ServerResponse.ANALYSIS_SUCCESS) {
            let jsonString: String = analysisResponse.getMessage() as! String
            print("ANALYSIS_SUCCESS!!")
            //print(jsonString)
            if let arrData = jsonString.data(using: .utf8) {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: arrData, options: .allowFragments) as? [AnyObject] {
                        for item in jsonArray {
                            let petData = PetData()
                            petData.time = item["Time"] as! TimeInterval
                            petData.time /= 1000 // Translate millisec to sec
                            petData.sunVal = item["SunVal"] as! Int
                            petData.uvVal = item["UvVal"] as! Double
                            petData.vitDVal = item["VitDVal"] as! Double
                            petData.exerciseVal = item["ExerciseVal"] as! Int
                            petData.walkVal = item["WalkVal"] as! Int
                            petData.stepVal = item["StepVal"] as! Int
                            petData.luxpolVal = item["LuxpolVal"] as! Double
                            petData.restVal = item["RestVal"] as! Int
                            petData.kalVal = item["KalVal"] as! Double
                            petData.waterVal = item["WaterVal"] as! Int
                            dataArray.append(petData)
                            
                            //print("Time : \(unixtimeToString(unixtime: petData.time))", terminator: " ")
                            //print("UV : \(String(format: "%.2f", petData.uvVal))", terminator: " ")
                            //print("Vit-D : \(String(format: "%.2f", petData.vitDVal))", terminator: " ")
                            //print("Rest : \(String(format: "%.2f", petData.restVal))")
                        }
                    }
                } catch {
                    print("JSON 파싱 에러")
                }
            }
        } else if(analysisResponse.getCode() as! Int == ServerResponse.ANALYSIS_FAILURE) {
            print(analysisResponse.getMessage() as! String)
            print("ServerResponse.ANALYSIS_FAILURE!!!")
        }

        print("dataArray.count : \(dataArray.count)")
        return dataArray
    }
    
    func manageUserInterfaceStyle() {
        switch userInterfaceStyle {
        case .dark:
            view.backgroundColor = .black
            barChartView.backgroundColor = .black
        case .light:
            view.backgroundColor = .white
            barChartView.backgroundColor = .white
        default:// .unspecified 포함
            view.backgroundColor = .white
            barChartView.backgroundColor = .white
        }
    }

//    override func viewDidDisappear(_ animated: Bool) {// View가 사라질 때. ViewWillDisappear은 View가 안 보일 때.
//        NotificationCenter.default.removeObserver(self, name: .receiveSyncDataDone, object: nil)
//        print("AnalysisViewController.viewDidDisappear()")
//    }
    
    // receiveSyncDataDone() will be called when Receiving SyncData Done!
    @objc func receiveSyncDataDone() {
        print("\n<<< AnalysisViewController.receiveSyncDataDone() >>>")
        DispatchQueue.background(delay: 0, background: nil) { [self] in
            refreshChartData()
        }
    }
    
    // describeHighlightedData() will be called when Chart Data highlighted!
    @objc func describeHighlightedData(_ notification: Notification) {
        //print("describeHighlightedData()")
        if let data = notification.userInfo as? [String: Highlight] {
            if let highlight = data["highlighted"] {
                //print("highlight: \(highlight.x), value: \(highlight.y)")
                valueLabel.text = String(Int(highlight.y))
                valueUnitLabel.text = units[optionsIndex]
                switch SegSelect(rawValue: timeSegmentControl.selectedSegmentIndex)! {
                case .Year:
                    dateFormatter.dateFormat = "yyyy "
                    chartDateLabel.text = dateFormatter.string(from: datePicker.date) + months[Int(highlight.x)]
                case .Month:
                    dateFormatter.dateFormat = "yyyy MMM "
                    chartDateLabel.text = dateFormatter.string(from: datePicker.date) + days[Int(highlight.x)]
                case .Day:
                    dateFormatter.dateFormat = "MMM dd "
                    chartDateLabel.text = dateFormatter.string(from: datePicker.date) +  times[Int(highlight.x)]
                case .Week:
                    print("Week")
//                    dateFormatter.dateFormat = "yyyy-MM-dd"
//                    timeValueLabel.text = weekDays[Int(highlight.x)] + " ~ " + weekDays[Int(highlight.x) + 1]
                }
            }
        }
    }

    // custumDatePickerChanged() will be called when Chart Data highlighted!
    @objc func custumDatePickerChanged(_ notification: Notification) {
        print("\t\t[ custumDatePickerChanged() ]")
        if let data = notification.userInfo as? [String: Date] {
            if let receivedDate = data["date"] {
                print("received date : \(unixtimeToString(unixtime: receivedDate.timeIntervalSince1970))")
                manageDateFormatter(date: receivedDate)
                //manageDateFormatter(date: nil)
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가도록
    }
    

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        print("AnalysisViewController.viewDidLayoutSubviews()")
//    }
}

extension AnalysisViewController {
    func setChart(dataName: String, dataPoints: [String], values: [Double], goal: Double, max: Double) {
        // 데이터 생성
        var dataEntries = [BarChartDataEntry]()
        var colorSet = [UIColor]()
        
        for i in 0..<values.count {
            if values[i] < goal {
                colorSet.append(#colorLiteral(red: 0.8470588235, green: 0.8901960784, blue: 0.9058823529, alpha: 1))
            } else {
                colorSet.append(#colorLiteral(red: 0.3098039216, green: 0.5803921569, blue: 0.831372549, alpha: 1))//.lightblue
            }
            dataEntries.append(BarChartDataEntry(x: Double(i), y: values[i]))
        }

        let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataName)
        // 차트 데이터 컬러
        chartDataSet.colors = colorSet
        chartDataSet.axisDependency = .left
        chartDataSet.highlightEnabled = true
        // Hide data value
        chartDataSet.drawValuesEnabled = false
        //chartDataSet.valueColors = colorSet

        //chartDataSet.label = dataName
        //chartDataSet.isDrawIconsEnabled
        //chartDataSet.iconsOffset
        //chartDataSet.highlightLineWidth
        //chartDataSet.highlightLineDashLengths
        //chartDataSet.highlightAlpha
        //chartDataSet.highlightColor
        //chartDataSet.highlightLineDashPhase
        
        //chartDataSet.form = .circle
        //chartDataSet.formSize
        //chartDataSet.formLineWidth
        //chartDataSet.form

        // Resets highlighted data
        barChartView.highlightValue(nil)
        // Enable highlight data
        barChartView.highlightPerTapEnabled = true
        
        // Sets min, max values for Chart
        barChartView.leftAxis.axisMaximum = max
        barChartView.leftAxis.axisMinimum = 0

        // 더블 탭으로 줌 안되게
        barChartView.doubleTapToZoomEnabled = false

        // 데이터 삽입
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        // Charts 기본 설정
        // Hide legends (colorset, dataName 숨기기.)
        barChartView.legend.enabled = false
        
        // X축 레이블 위치 조정
        barChartView.xAxis.labelPosition = .bottom
        // X축 레이블 포맷 지정
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
        //barChartView.xAxis.setLabelCount(dataPoints.count, force: false)
        //barChartView.xAxis.labelCount = dataPoints.count / 3
        // 확대하더라도 x축 레이블이 여러개가 되지 않도록 한다
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.granularity = 1
        // GridLine Data 뒤에 그리기 -> GridLine 지우므로 무의미.
        //barChartView.xAxis.drawLimitLinesBehindDataEnabled = true
        // GridLine 지우기
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.drawGridLinesEnabled = false
        //barChartView.rightAxis.drawGridLinesEnabled = false

        //barChartView.xAxis.spaceMax = 0.0
        //barChartView.xAxis.spaceMax = 0.0
        
        //barChartView.xAxis.xOffset = 5.0
        //barChartView.xAxis.yOffset = 5.0
        
        barChartView.leftAxis.labelPosition = .outsideChart
        //barChartView.leftAxis.labelXOffset = 5

        // 오른쪽 레이블 제거
        barChartView.rightAxis.enabled = false
        // 애니메이션
        barChartView.animate(yAxisDuration: 2.0, easingOption: .easeInOutQuad)

        // 모든 데이터가 보이도록 설정
        barChartView.setVisibleXRangeMaximum(Double(dataPoints.count))
//        if (!dataPoints.isEmpty && !values.isEmpty) {
//            barChartView.zoom(scaleX: CGFloat(1/dataPoints.count), scaleY: 1.0, x: 0, y: 0)
//            print("dataPoints.count : \(dataPoints.count), barChartView.zoom(scaleX: \(String(format: "%.3f", CGFloat(1/dataPoints.count))), scaleY: 1.0, x: 0, y: 0)")
            barChartView.setScaleEnabled(true)// Disables Pinch to zoom feature
//        }
        
        setLimitLines(to: barChartView, goal: goal)
    }
    
    func setLimitLines(to barChartView: BarChartView, goal: Double) {
        // Use LimitLine as Goal
        let ll = ChartLimitLine(limit: goal, label: "Goal")
        ll.lineColor = .lightblue
        ll.lineWidth = 2.0
        switch userInterfaceStyle {
        case .dark:
            ll.valueTextColor = .white
        case .light:
            ll.valueTextColor = .black
        default:// .unspecified 포함
            ll.valueTextColor = .black
        }
        barChartView.leftAxis.removeAllLimitLines()
        barChartView.leftAxis.addLimitLine(ll)
    }

    func chartOptionChanged(selected segSelect: SegSelect, pickerOption: String) {
        print("chartOptionChanged(selected: \(segSelect), pickerOption: \(pickerOption))")

        var values = [Double]()
        var valueGoal: Double = 0
        print("You selected \(options[optionsIndex])", terminator: " ")
        switch OptSelect(rawValue: optionsIndex)! {
        case .Sun:
            valueGoal = ChartUtility.SunGoal
            for petData in petDatas {
                values.append(Double(petData.sunVal))
            }
        case .UV:
            valueGoal = ChartUtility.UVGoal
            for petData in petDatas {
                values.append(Double(petData.uvVal))
            }
        case .Vit_D:
            valueGoal = ChartUtility.VitDGoal
            for petData in petDatas {
                values.append(Double(petData.vitDVal))
            }
        case .Exercise:
            valueGoal = ChartUtility.ExerciseGoal
            for petData in petDatas {
                values.append(Double(petData.exerciseVal))
            }
        case .Walk:
            valueGoal = ChartUtility.WalkGoal
            for petData in petDatas {
                values.append(Double(petData.walkVal))
            }
        case .Steps:
            valueGoal = ChartUtility.StepGoal
            for petData in petDatas {
                values.append(Double(petData.stepVal))
            }
        case .LuxPol:
            valueGoal = ChartUtility.LuxPolGoal
            for petData in petDatas {
                values.append(Double(petData.luxpolVal))
            }
        case .Rest:
            valueGoal = ChartUtility.RestGoal
            for petData in petDatas {
                values.append(Double(petData.restVal))
            }
        case .Kal:
            valueGoal = ChartUtility.KalGoal
            for petData in petDatas {
                values.append(Double(petData.sunVal))
            }
        case .Water:
            valueGoal = ChartUtility.WaterGoal
            for petData in petDatas {
                values.append(Double(petData.sunVal))
            }
        }

        if petDatas.isEmpty { // Avoid crash
            values.append(0)
        }
        
        switch segSelect {
        case .Year:
            print("And Year Data!")

            dateFormatter.dateFormat = "yyyy"
            dateTextField.text = dateFormatter.string(from: datePicker.date)
            
            // 현재 달 까지만 나오도록 12달 데이터를 자르는 기능 -> 제거 21.05.04
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            let today = Date()
//            // Multiple Castings to get exact day without extra seconds
//            let segDate = dateFormatter.date(from: dateFormatter.string(from: datePicker.date))!
//            let comparisonResult = Calendar.current.compare(segDate, to: today, toGranularity: .year)
//            if comparisonResult == .orderedSame {
//                print("Same Year!")
//                let segDateMonth = Calendar.current.component(.month,  from: segDate)
//
//                print("[\tsegDate : \(segDate), segDateMonth : \(segDateMonth)]")
//    //            for i in 0..<petDatas.count {
//    //                values[i] = Double(i + 1) * valueGoal / 24
//    //            }
//                print("Show data only from 1st to until \(segDateMonth)")
//                print("values : ", values)
//                if values.count > (12 - segDateMonth) {
//                    values.removeLast(12 - segDateMonth)
//                }
//            } else if comparisonResult == ComparisonResult.orderedAscending {
//                print("orderedAscending! Do nothing")
//            }
            
            setChart(dataName: options[optionsIndex], dataPoints: months.dropLast(months.count - values.count), values: values, goal: valueGoal, max: valueGoal * 4 / 3)
        case .Month:
            print("And Month Data!")
            
            dateFormatter.dateFormat = "yyyy-MM"
            dateTextField.text = dateFormatter.string(from: datePicker.date)
            
            setChart(dataName: options[optionsIndex], dataPoints: days.dropLast(days.count - values.count), values: values, goal: valueGoal, max: valueGoal * 4 / 3)
        case .Day:
            print("And Day Data!")
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateTextField.text = dateFormatter.string(from: datePicker.date)
            
            setChart(dataName: options[optionsIndex], dataPoints: times.dropLast(times.count - values.count), values: values, goal: valueGoal, max: valueGoal * 4 / 3)
        case .Week:
            print("And Week Data!")
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateTextField.text = dateFormatter.string(from: datePicker.date)
            
            let segDate = datePicker.date
            let segDateWeekDay = Calendar.current.component(.weekday,  from: segDate)
            print("segDate: \(segDate), Weekday: \(segDateWeekDay)(\(weekDays[segDateWeekDay - 1]))")

            var tmpWeekDays = [String]()
            for i in 0..<weekDays.count {
                tmpWeekDays.append(weekDays[(segDateWeekDay + i) % weekDays.count])
            }
            setChart(dataName: options[optionsIndex], dataPoints: tmpWeekDays.dropLast(tmpWeekDays.count - values.count), values: values, goal: valueGoal, max: valueGoal * 4 / 3)
        }
    }

    @objc func calBtnTouched(_ button: UIButton) {
        self.dateTextField.becomeFirstResponder()
    }

    @objc func selectedSegChanged(_ segment: MASegmentedControl) {
        print("selectedSegChanged()")
        
        // 날짜 세그먼트가 바뀌었으므로 서버에서 데이터 다시 받아와야 함.
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 35)
        let today = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(setToday))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        switch SegSelect(rawValue: timeSegmentControl.selectedSegmentIndex)! {
        case .Year:
            
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnOnPickerView(_:)))
            toolBar.setItems([today, space, done], animated: true)
            dateTextField.inputAccessoryView = toolBar
            dateTextField.inputView = yearPickerView
            yearPickerView.selectToday()
            print("selectedSegChanged(Year)")
        case .Month:
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnOnPickerView(_:)))
            toolBar.setItems([today, space, done], animated: true)
            dateTextField.inputAccessoryView = toolBar
            dateTextField.inputView = yearMonthPickerView
            yearMonthPickerView.selectToday()
        case .Day:
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnOnDatePicker(_:)))
            toolBar.setItems([today, space, done], animated: true)
            dateTextField.inputAccessoryView = toolBar
            dateTextField.inputView = datePicker
            manageDateFormatter(date: Date())//datePicker.date = Date()
        case .Week:
            print("Week")
//            dateTextField.inputView = datePicker
//            manageDateFormatter(date: Date())//datePicker.date = Date()
        }
        refreshChartData()
        chartOptionChanged(selected: SegSelect(rawValue: segment.selectedSegmentIndex)!, pickerOption: options[optionsIndex])
    }
    
    @objc func doneBtnOnDatePicker(_ picker: UIDatePicker) {
        doneBtnOnPickers()
    }
    
    @objc func doneBtnOnPickerView(_ picker: UIPickerView) {
        doneBtnOnPickers()
    }

    func doneBtnOnPickers() {
        print("doneBtnOnPickers()")
        self.view.endEditing(true)//dateTextField.resignFirstResponder()
        
        // 날짜가 바뀌었으므로 서버에서 데이터 다시 받아와야 함.
        refreshChartData()
        chartOptionChanged(selected: SegSelect(rawValue: timeSegmentControl.selectedSegmentIndex)!, pickerOption: options[optionsIndex])
    }

    @objc func dateChanged(_ picker: UIDatePicker) {
        manageDateFormatter(date: nil)
    }

    @objc func setToday(_ picker: UIDatePicker) {
        switch SegSelect(rawValue: timeSegmentControl.selectedSegmentIndex)! {
        case .Year:
            yearPickerView.selectToday()
            manageDateFormatter(date: Date())
            print("setToday(Year)")
        case .Month:
            yearMonthPickerView.selectToday()
            manageDateFormatter(date: Date())
        case .Day:
            manageDateFormatter(date: Date())//datePicker.date = Date()
        case .Week:
            print("Deprecated Week")
        }
    }
    
    func manageDateFormatter(date: Date?) { // date가 nil일 경우 picker.date 사용// // // // // // // // // //
        if date != nil {
            datePicker.date = date!
        }
        dateFormatter.dateStyle = .medium //.long
        
        switch SegSelect(rawValue: timeSegmentControl.selectedSegmentIndex)! {
        case .Year:
            print("Year!")
            dateFormatter.dateFormat = "yyyy"
        case .Month:
            print("Month!")
            dateFormatter.dateFormat = "yyyy-MM"
        default:
            print("Week and Day!")
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }
        dateTextField.text = dateFormatter.string(from: datePicker.date)

        dateFormatter.dateFormat = "yyyyMMdd"
        dateInput = dateFormatter.string(from: datePicker.date)
        print("dateTextField.text : \(dateTextField.text ?? "-"), dateInput : \(dateInput)")
    }

//    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat, entry: ChartDataEntry?, highlight: Highlight?, centerIndices:Highlight?) {
//        if let entry = entry, let highlight = highlight {
//            print("chartTranslated info:\n\(self)\ndX and dY:\(dX)-\(dY)\nentry:\(entry)\nhightlight:\(highlight)")
//        }
//        if let centerIndices = centerIndices {
//            print("\n center indices is:\n\(centerIndices)")
//        }
//    }
}

extension AnalysisViewController {
        
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSyncDataDone), name: .receiveSyncDataDone, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(describeHighlightedData(_:)), name: .highlightedData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(custumDatePickerChanged(_:)), name: .custumDatePickerChanged, object: nil)
    }
    
    fileprivate func removeObservers() { // Not used Yet.
        NotificationCenter.default.removeObserver(self, name: .receiveSyncDataDone, object: nil)
        NotificationCenter.default.removeObserver(self, name: .highlightedData, object: nil)
        NotificationCenter.default.removeObserver(self, name: .custumDatePickerChanged, object: nil)
    }
    
    fileprivate func initUIViews() {
        //initChartSelect()
        initDateTextField()
        initOptionTextField()
        initPickerViews()
        //initLabels()
        initButtons()
        initBarChartView()
        initTimeSegmentControl()
    }
    
    fileprivate func addSubviews() {
//        view.addSubview(chartSelect)
//        view.addSubview(dateTextField)
//        view.addSubview(optionTextField)
        view.addSubview(barChartView)
        view.addSubview(timeSegmentControl)
//        view.addSubview(timeLabel)
//        view.addSubview(infoLabel)
//        view.addSubview(timeValueLabel)
//        view.addSubview(infoValueLabel)
    }
    
    fileprivate func prepareForAutoLayout() {
//        chartSelect.translatesAutoresizingMaskIntoConstraints = false
//        dateTextField.translatesAutoresizingMaskIntoConstraints = false
//        optionTextField.translatesAutoresizingMaskIntoConstraints = false
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        timeSegmentControl.translatesAutoresizingMaskIntoConstraints = false
//        presentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
//        valueLabel.translatesAutoresizingMaskIntoConstraints = false
//        valueUnitLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setConstraints() {
//        let chartSelectConstraints = [
//            chartSelect.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            chartSelect.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
//            chartSelect.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
//            chartSelect.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
//            chartSelect.heightAnchor.constraint(equalToConstant: 50)
//        ]
//
//        let dateTextFieldConstraints = [
//            dateTextField.topAnchor.constraint(equalTo: chartSelect.bottomAnchor, constant: 20),
//            dateTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
//            dateTextField.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -10)
//        ]
//
//        let optionTextFieldConstraints = [
//            optionTextField.topAnchor.constraint(equalTo: dateTextField.topAnchor),
//            optionTextField.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
//            optionTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
//        ]
//
        let barChartViewConstraints = [
            barChartView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10),
            barChartView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            barChartView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            barChartView.heightAnchor.constraint(equalTo: barChartView.widthAnchor),
            barChartView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        
        let timeSegmentControlConstraints = [
            timeSegmentControl.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 70),
            timeSegmentControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            timeSegmentControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            timeSegmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeSegmentControl.heightAnchor.constraint(equalToConstant: 50)
        ]

//        let presentTimeLabelConstraints = [
//            presentTimeLabel.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 15),
//            presentTimeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
//        ]
//
//        let valueLabelConstraints = [
//            valueLabel.topAnchor.constraint(equalTo: presentTimeLabel.bottomAnchor, constant: 15),
//            valueLabel.leftAnchor.constraint(equalTo: presentTimeLabel.leftAnchor),
//        ]
//
//        let valueUnitLabelConstraints = [
//            valueUnitLabel.topAnchor.constraint(equalTo: valueLabel.topAnchor),
//            valueUnitLabel.leftAnchor.constraint(equalTo: value.rightAnchor, constant: 10),
//        ]
//
//        [chartSelectConstraints, dateTextFieldConstraints, optionTextFieldConstraints, barChartViewConstraints, timeLabelConstraints, infoLabelConstraints, timeValueLabelConstraints, infoValueLabelConstraints]
//            .forEach(NSLayoutConstraint.activate(_:))
        [barChartViewConstraints].forEach(NSLayoutConstraint.activate(_:))
        [timeSegmentControlConstraints].forEach(NSLayoutConstraint.activate(_:))
    }
}

extension AnalysisViewController {
    
    func initChartSelect() {
       // chartSelect = UISegmentedControl()
//        chartSelect.insertSegment(withTitle: "Year", at: 0, animated: true)
//        chartSelect.insertSegment(withTitle: "Month", at: 1, animated: true)
//        chartSelect.insertSegment(withTitle: "Day", at: 2, animated: true)
//        chartSelect.insertSegment(withTitle: "Week", at: 3, animated: true)
        chartSelect.selectedSegmentIndex = 2 // Set Day as a Default
        chartSelect.addTarget(self, action: #selector(selectedSegChanged(_:)), for: .valueChanged)
    }

    func initDateTextField() {
//        dateTextField = ConstantUITextField()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        //dateTextField.font = UIFont.systemFont(ofSize: 25)
        dateTextField.text = dateFormatter.string(from: Date())
        //dateTextField.textColor = .systemBlue
        dateTextField.textAlignment = .center
        //dateTextField.borderStyle = .roundedRect
    }
    
    func initDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            datePicker.preferredDatePickerStyle = UIDatePickerStyle.automatic
        }
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 35)
        let today = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(setToday))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnOnDatePicker(_:)))
        toolBar.setItems([today, space, done], animated: true)
        dateTextField.inputAccessoryView = toolBar
        dateTextField.inputView = datePicker
    }
    
    func initOptionTextField() {
//        optionTextField = ConstantUITextField()
//        optionTextField.font = UIFont.systemFont(ofSize: 25)
//        optionTextField.text = options[optionsIndex]
//        //optionTextField.textColor = .systemBlue
//        optionTextField.textAlignment = .center
//        optionTextField.borderStyle = .roundedRect
    }
    
    func initPickerViews() {
        initDatePicker()
        //initOptionTFPickerView()
        initYearPickerView()
        initYearMonthPickerView()
        initDataPickerView()
    }
    
    func initOptionTFPickerView() {
//        pickerView = UIPickerView()
//        pickerView.delegate = self
//        pickerView.dataSource = self
//
//        let toolBar = UIToolbar()
//        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 35)
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnOnPickerView(_:)))
//
//        toolBar.setItems([flexSpace, doneBtn], animated: true)
//        optionTextField.inputAccessoryView = toolBar
//        optionTextField.inputView = pickerView
    }

    func initYearPickerView() {
        yearPickerView = YearPickerView()
    }
    
    func initYearMonthPickerView() {
        yearMonthPickerView = DatePickerView()
    }
    
    func initDataPickerView() {
        var rotationAngle: CGFloat!
        
        dataPickerView.delegate = self
        dataPickerView.dataSource = self
        
        // 회전 - 전체 틀을 horizontal로 돌리기 위함
        rotationAngle = -90 * (.pi/180)
        dataPickerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
    }

    func initBarChartView() {
        barChartView = BarChartView()
        barChartView.delegate = self
        barChartView.addTapRecognizer()
    }
    
    func initLabels() {
//        presentTimeBtn = UIButton()
//        presentTimeBtn.text = "1970-01-01"
//        presentTimeBtn.font = UIFont.systemFont(ofSize: 20)
//
//        valueLabel = UILabel()
//        valueLabel.text = "0"
//        valueLabel.font = UIFont.systemFont(ofSize: 25)
//
//        valueUnitLabel = UILabel()
//        valueUnitLabel.text = " "
//        valueUnitLabel.font = UIFont.systemFont(ofSize: 20)
    }
    func initTimeSegmentControl() {
        timeSegmentControl = MASegmentedControl(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        timeSegmentControl.selectedSegmentIndex = 2

        timeSegmentControl.itemsWithText = true
        timeSegmentControl.fillEqually = true
        timeSegmentControl.roundedControl = true
        timeSegmentControl.setSegmentedWith(items: ["Year", "Month", "Day"])
        
        timeSegmentControl.padding = 2
        timeSegmentControl.textColor = .black
        timeSegmentControl.selectedTextColor = .white
        timeSegmentControl.thumbViewColor = #colorLiteral(red: 0.3098039216, green: 0.5803921569, blue: 0.831372549, alpha: 1)
        timeSegmentControl.titlesFont = UIFont.systemFont(ofSize: 25, weight: .medium)
        
        timeSegmentControl.addTarget(self, action: #selector(selectedSegChanged(_:)), for: .valueChanged)

    }
}

extension AnalysisViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 100
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let width = 100
        let height = 100
        
        dataPickerView.subviews.forEach {
            $0.backgroundColor = .clear
        }
        
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        view.transform = CGAffineTransform(rotationAngle: 90 * (.pi/180))

        let label = UILabel()
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: width, height: height)
        label.text = options[row]
        label.font = UIFont.systemFont(ofSize: 25)
        view.addSubview(label)
        


        return view
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        optionsIndex = row // Manage selected row globally - 21.03.12 by ms
        //optionTextField.text = options[row]
        print("Change chart data for \(options[row]) graph!")
        refreshChartData()
        chartOptionChanged(selected: SegSelect(rawValue: timeSegmentControl.selectedSegmentIndex)!, pickerOption: options[optionsIndex])
    }
    
    
    @IBAction func preDataBtnClicked(_ sender: UIButton) {
        if optionsIndex > 0 {
            dataPickerView.selectRow(optionsIndex - 1, inComponent: 0, animated: true)
            optionsIndex = optionsIndex - 1
        }
    }
    
    @IBAction func nextDataBtnClicked(_ sender: UIButton) {
        if optionsIndex < options.count {
            dataPickerView.selectRow(optionsIndex + 1, inComponent: 0, animated: true)
            optionsIndex = optionsIndex + 1
        }
    }

    func initButtons() {
        //calBtn = UIButton()
        calBtn.addTarget(self, action: #selector(calBtnTouched(_:)), for: .touchDown)
    }

}

//extension AnalysisViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return options.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return options[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        optionsIndex = row // Manage selected row globally - 21.03.12 by ms
//        optionTextField.text = options[row]
//        print("Change chart data for \(options[row]) graph!")
//    }
//}

