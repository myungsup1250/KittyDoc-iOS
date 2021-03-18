//
//  AnalysisViewController.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/16.
//

import UIKit
import Charts

class ConstantUITextField: UITextField {
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        //if action == #selector(paste(_:)) {
        //    return true
        //}
        //return super.canPerformAction(action, withSender: sender)
        // Can't perform Paste func
        return false // Disable all funcs
    }
}

class AnalysisViewController: UIViewController, ChartViewDelegate {
    var userInterfaceStyle: UIUserInterfaceStyle!
    var deviceManager = DeviceManager.shared
    var safeArea: UILayoutGuide!
    
    var dateInput: String = ""
    var chartSelect: UISegmentedControl!
    var dateTextField: ConstantUITextField!
    var optionTextField: ConstantUITextField!
    var datePicker: UIDatePicker!
    var pickerView: UIPickerView!
    var barChartView: BarChartView!

    var options = [ "Sun", "UV", "Vitmin D", "Exercise", "Walk", "Steps", "LuxPolution", "Rest", "Kal", "Water"]
    var optionsIndex = 0
    
    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var days = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
    var daysofweek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    var times = ["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"]
    
    var petDatas = [PetData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("AnalysisViewController.viewDidLoad()")
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSyncDataDone), name: .receiveSyncDataDone, object: nil)
        
        safeArea = view.safeAreaLayoutGuide// view.layoutMarginsGuide
        userInterfaceStyle = self.traitCollection.userInterfaceStyle
        initUIViews()
        addSubviews()
        prepareForAutoLayout()
        setConstraints()

        manageUserInterfaceStyle()

        petDatas.removeAll()
        petDatas = requestServerData(forDays: 1, forHours: 0)//센서 데이터 수신 코드

        var sunValues = [Double]()
        for i in 0..<petDatas.count {
            sunValues.append(Double((i + 1) * 3000))
        }
        if petDatas.isEmpty {
            sunValues.append(0)
        }
        setChart(dataName: optionTextField.text!, dataPoints: times.dropLast(times.count - sunValues.count), values: sunValues, goal: ChartUtility.SunGoal, max: ChartUtility.SunGoal * 4 / 3)
        // Initial Setup : Day && Sun && CurrentDate
        
        // 데이터가 없을 경우 Crash!!!!!! 21.03.15
    }
    
    fileprivate func requestServerData(forDays: UInt, forHours: UInt) -> [PetData] {

        var dataArray: [PetData] = []
        let hourInSec: TimeInterval = 3600
        let dayInSec: TimeInterval = 86400 // (86400 == 24Hours in seconds)
        //let weekInSec: TimeInterval = 604800 // (604800 == A week in seconds)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let today = Date()
        let segDate = dateFormatter.date(from: dateTextField.text!)!
        let timeIntervalSince1970 = today.timeIntervalSince1970
        let timeIntervalFromMidnight = TimeInterval(Int(timeIntervalSince1970 + hourInSec * 9) % Int(dayInSec))
        guard !(Calendar.current.compare(segDate, to: today, toGranularity: .day) == ComparisonResult.orderedDescending) else {
            print("segDate(\(unixtimeToString(unixtime: time_t((segDate.timeIntervalSince1970))))) and today(\(unixtimeToString(unixtime: time_t((today.timeIntervalSince1970))))) is orderedDescending!")
            print("There will be no data!")
            return []
        }

        var endTime: time_t = 0
        var startTime: time_t = 0
        let segSelect = SegSelect(rawValue: chartSelect.selectedSegmentIndex)!
        print("segDate(\(unixtimeToString(unixtime: time_t((segDate.timeIntervalSince1970))))) and today(\(unixtimeToString(unixtime: time_t((today.timeIntervalSince1970))))) is", terminator: " ")
        switch segSelect {
        case SegSelect.Year:
            print("[ Year Data! ]")
            // 
            //startTime = Int((timeIntervalSince1970 - timeIntervalFromMidnight) * 1000)
            //endTime = startTime + Int((dayInSec - 1) * 1000)
        case SegSelect.Month:
            print("[ Month Data! ]")
            
            let segDateYear = Calendar.current.component(.year,  from: segDate)
            let segDateMonth = Calendar.current.component(.month,  from: segDate)
            //let segDateDay = Calendar.current.component(.day,  from: segDate)
            let daysOfThisMonth = getDaysInMonth(month: segDateMonth, year: segDateYear)!
            //let daysOfLastMonth = getDaysInMonth(month: segDateMonth - 1, year: segDateYear)!

            endTime = Int((segDate.timeIntervalSince1970 + dayInSec - 1) * 1000)
            startTime = endTime - Int((dayInSec * Double(daysOfThisMonth)) * 1000)
        case SegSelect.Week:
            print("[ Week Data! ]")

            startTime = Int((segDate.timeIntervalSince1970 - (dayInSec * 6)) * 1000)
            endTime = Int((segDate.timeIntervalSince1970 + dayInSec - 1) * 1000)
        case SegSelect.Day:
            print("[ Day Data! ]")
            if Calendar.current.compare(segDate, to: today, toGranularity: .day) == .orderedSame {
                print("Same Day!")

                // 00시부터 지금까지
                startTime = Int((timeIntervalSince1970 - timeIntervalFromMidnight) * 1000)
                endTime = Int(timeIntervalSince1970 * 1000)
            } else if Calendar.current.compare(segDate, to: today, toGranularity: .day) == ComparisonResult.orderedAscending {
                print("orderedAscending!")

                startTime = Int(segDate.timeIntervalSince1970 * 1000)
                endTime = startTime + Int(dayInSec - 1) * 1000
                // frontTime : 00:00:24이어야 전날 00시부터 24개 데이터 받아온다?!
            }
        }
        print("requestServerData(From : \(unixtimeToString(unixtime: startTime / 1000))), Til : \(unixtimeToString(unixtime: endTime / 1000)))")
        //print("rearTime RAW : \(rearTime), rearTime [\(unixtimeToString(unixtime: time_t(rearTime / 1000)))]")
        //print("frontTime RAW : \(frontTime), frontTime [\(unixtimeToString(unixtime: time_t(frontTime / 1000)))]")

        //_petID: 38은 자신의 펫 아이디로 수정되어야 함. 예시로 38을 적어두었음!
        let analysisData: AnalysisData = AnalysisData(_petID: 38, _startMilliSec: startTime, _endMilliSec: endTime)
        let server: KittyDocServer = KittyDocServer()
        
        var analysisResponse: ServerResponse!
        switch segSelect {
        case SegSelect.Year:
            print("[ server.sensorRequestYear() ]")
            let analysisData_Year: AnalysisData_Year = AnalysisData_Year(_petID: 38, _year: 2021, _offset: -540)
            analysisResponse = server.sensorRequestYear(data: analysisData_Year)
        case SegSelect.Month:
            print("[ server.sensorRequestDay(Month) ]")
            analysisResponse = server.sensorRequestDay(data: analysisData)
        case SegSelect.Week:
            print("[ server.sensorRequestDay(Week) ]")
            analysisResponse = server.sensorRequestDay(data: analysisData)
        case SegSelect.Day:
            print("[ server.sensorRequestHour() ]")
            analysisResponse = server.sensorRequestHour(data: analysisData)
        }

        if(analysisResponse.getCode() as! Int == ServerResponse.ANALYSIS_SUCCESS) {
            //print(analysisResponse.getMessage() as! String)

            let jsonString: String = analysisResponse.getMessage() as! String
            if let arrData = jsonString.data(using: .utf8) {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: arrData, options: .allowFragments) as? [AnyObject] {
                        for i in 0..<jsonArray.count {
                            let petData = PetData()
                            petData.time = jsonArray[i]["Time"] as! CLong
                            petData.time /= 1000 // Translate millisec to sec
                            petData.sunVal = jsonArray[i]["SunVal"] as! Int
                            petData.uvVal = jsonArray[i]["UvVal"] as! Double
                            petData.vitDVal = jsonArray[i]["VitDVal"] as! Double
                            petData.exerciseVal = jsonArray[i]["ExerciseVal"] as! Int
                            petData.walkVal = jsonArray[i]["WalkVal"] as! Int
                            petData.stepVal = jsonArray[i]["StepVal"] as! Int
                            petData.luxpolVal = jsonArray[i]["LuxpolVal"] as! Double
                            petData.restVal = jsonArray[i]["RestVal"] as! Int
                            petData.kalVal = jsonArray[i]["KalVal"] as! Double
                            petData.waterVal = jsonArray[i]["WaterVal"] as! Int
                            dataArray.append(petData)
                            print("Time : \(unixtimeToString(unixtime: time_t(petData.time)))", terminator: " ")
                            print("Sun : \(petData.sunVal)")
                        }
                    }
                } catch {
                    print("JSON 파싱 에러")
                }
            
            } else if(analysisResponse.getCode() as! Int == ServerResponse.ANALYSIS_FAILURE){
                print(analysisResponse.getMessage() as! String)
            }

            print("dataArray.count : \(dataArray.count)")
        }
        return dataArray
    }
    
    func manageUserInterfaceStyle() {
        // .light .dark .unspecified
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
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        let set = BarChartDataSet(entries: entries, label: "BarChartDataSetLabel")
//
//        // 차트 컬러
//        set.colors = [.systemBlue]//ChartColorTemplates.material()
//
//        // 데이터 삽입
//        let data  = BarChartData(dataSet: set)
//        barChartView.data = data
//    }
}

extension AnalysisViewController {
    
    enum SegSelect: Int {
        case Year = 0
        case Month
        case Week
        case Day
    }

    enum OptSelect: Int {
        case Sun = 0
        case UV
        case Vit_D
        case Exercise
        case Walk
        case Steps
        case LuxPol
        case Rest
        case Kal
        case Water
    }
    
    func setChart(dataName: String, dataPoints: [String], values: [Double], goal: Double, max: Double) {
        // 데이터 생성
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataName)

        // 차트 컬러
        chartDataSet.colors = [.systemBlue] // ChartColorTemplates.material()
        //chartDataSet.axisDependency = .left // .right
        //chartDataSet.highlightEnabled = true
        
        // 데이터의 값을 출력할 것인가?
        chartDataSet.drawValuesEnabled = false
        
        // 데이터 삽입
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        // X축 레이블 위치 조정
        barChartView.xAxis.labelPosition = .bottom
        // X축 레이블 포맷 지정
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
        barChartView.xAxis.setLabelCount(dataPoints.count, force: false)
        //barChartView.xAxis.labelCount = 10

        //barChartView.xAxis.wordWrapEnabled = true
        //barChartView.xAxis.wordWrapWidthPercent = 50

        //barChartView.xAxis.spaceMax = 0.0
        //barChartView.xAxis.spaceMax = 0.0

        // 확대하더라도 x축 레이블이 여러개가 되지 않도록 한다
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.granularity = 1
//
//        //barChartView.xAxis.gridLine~~~
//        barChartView.xAxis.drawLimitLinesBehindDataEnabled = true
//        barChartView.xAxis.axisRange = 30

        //barChartView.xAxis.xOffset = 5.0
        //barChartView.xAxis.yOffset = 5.0
        
        barChartView.leftAxis.labelPosition = .insideChart
        //barChartView.leftAxis.labelXOffset = 5

        // 오른쪽 레이블 제거
        barChartView.rightAxis.enabled = false
        // 애니메이션
        barChartView.animate(yAxisDuration: 2.0, easingOption: .easeInOutQuad)

        // 최대 10개까지 보이도록 설정... 나머지는 스크롤해서 보기?
        barChartView.setVisibleXRangeMaximum(Double(10.0))
        if (!dataPoints.isEmpty && !values.isEmpty) {
            barChartView.zoom(scaleX: CGFloat(1/dataPoints.count), scaleY: 1.0, x: 0, y: 0)
            barChartView.setScaleEnabled(false)// Disables Pinch to zoom feature
        }
        
        // Use LimitLine as Goal
        let ll = ChartLimitLine(limit: goal, label: "Goal")
        ll.lineColor = .magenta
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
        // Sets min, max values for Chart
        barChartView.leftAxis.axisMaximum = max
        barChartView.leftAxis.axisMinimum = 0

        // 더블 탭으로 줌 안되게
        barChartView.doubleTapToZoomEnabled = false
        // 선택 안되게
        chartDataSet.highlightEnabled = false
    }

    func chartOptionChanged(selected segSelect: SegSelect, pickerOption: String) {
        print("chartOptionChanged(selected: \(segSelect), pickerOption: \(pickerOption))")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateTextField.text!)
        
        let year = Calendar.current.component(.year,  from: date!)
        let month = Calendar.current.component(.month,  from: date!)
        //let day = Calendar.current.component(.day,  from: date!)
        //let hour = Calendar.current.component(.hour,  from: date!)
        
        var values = [Double]()
        var valueGoal: Double = 0
        let optSelect = OptSelect(rawValue: optionsIndex)!
        print("You selected", terminator: " ")
        switch optSelect {
        case OptSelect.Sun:
            print("Sun", terminator: " ")
            for i in 0..<petDatas.count {
                values.append(Double(petDatas[i].sunVal))
            }
            valueGoal = ChartUtility.SunGoal
        case OptSelect.UV:
            print("UV", terminator: " ")
            for i in 0..<petDatas.count {
                values.append(Double(petDatas[i].uvVal))
            }
            valueGoal = ChartUtility.UVGoal
        case OptSelect.Vit_D:
            print("Vit_D", terminator: " ")
            for i in 0..<petDatas.count {
                values.append(Double(petDatas[i].vitDVal))
            }
            valueGoal = ChartUtility.VitDGoal
        case OptSelect.Exercise:
            print("Exercise", terminator: " ")
            for i in 0..<petDatas.count {
                values.append(Double(petDatas[i].exerciseVal))
            }
            valueGoal = ChartUtility.ExerciseGoal
        case OptSelect.Walk:
            print("Walk", terminator: " ")
            for i in 0..<petDatas.count {
                values.append(Double(petDatas[i].walkVal))
            }
            valueGoal = ChartUtility.WalkGoal
        case OptSelect.Steps:
            print("Steps", terminator: " ")
            for i in 0..<petDatas.count {
                values.append(Double(petDatas[i].stepVal))
            }
            valueGoal = ChartUtility.StepGoal
        case OptSelect.LuxPol:
            print("LuxPol", terminator: " ")
            for i in 0..<petDatas.count {
                values.append(Double(petDatas[i].luxpolVal))
            }
            valueGoal = ChartUtility.LuxPolGoal
        case OptSelect.Rest:
            print("Rest", terminator: " ")
            for i in 0..<petDatas.count {
                values.append(Double(petDatas[i].restVal))
            }
            valueGoal = ChartUtility.RestGoal
        case OptSelect.Kal:
            print("Kal", terminator: " ")
            for i in 0..<petDatas.count {
                values.append(Double(petDatas[i].sunVal))
            }
            valueGoal = ChartUtility.KalGoal
        case OptSelect.Water:
            print("Water", terminator: " ")
            for i in 0..<petDatas.count {
                values.append(Double(petDatas[i].sunVal))
            }
            valueGoal = ChartUtility.WaterGoal
        }

        switch segSelect {
        case SegSelect.Year:
            print("And Year Data![Demo]")
            var monthValues = [Double]()
            for i in 1...12 {
                monthValues.append(Double(i * 10))
            }
            setChart(dataName: "Year", dataPoints: months, values: monthValues, goal: 80, max: 150)
        case SegSelect.Month:
            print("And Month Data![Demo]")
            guard let numberOfDays = getDaysInMonth(month: month, year: year) else {
                print("Error in getDaysInMonth(month: , year:)!!")
                return
            }
            var dayValues = [Double]()
            for i in 1...numberOfDays {
                dayValues.append(Double(i * 3))
            }
            setChart(dataName: "Month", dataPoints: days.dropLast(31-numberOfDays), values: dayValues, goal: 80, max: 150)
        case SegSelect.Week:
            print("And Week Data![Demo]")
            var weekValues = [Double]()
            for i in 1...7 {
                weekValues.append(Double(i * 15))
            }
            setChart(dataName: "Week", dataPoints: daysofweek, values: weekValues, goal: 80, max: 150)
        case SegSelect.Day:
            print("And Day Data!")
            
            //let hour = Calendar.current.component(.hour,  from: Date())
            for i in 0..<petDatas.count {
                values[i] = Double(i + 1) * valueGoal / 24
            }
            if petDatas.isEmpty {
                values.append(0)
            }

            setChart(dataName: optionTextField.text!, dataPoints: times.dropLast(times.count - values.count), values: values, goal: valueGoal, max: valueGoal * 4 / 3)
        }
    }
    
    @objc func selectedSegChanged(_ segment: UISegmentedControl) {
        print("selectedSegChanged()")
        
        // 날짜 세그먼트가 바뀌었으므로 서버에서 데이터 다시 받아와야 함.
        petDatas.removeAll()
        petDatas = requestServerData(forDays: 1, forHours: 0)//센서 데이터 수신 코드

        chartOptionChanged(selected: SegSelect(rawValue: segment.selectedSegmentIndex)!, pickerOption: options[optionsIndex])
    }
    
    @objc func dateChanged(_ picker: UIDatePicker) {
        print("dateChanged()")

        manageDateFormatter(date: nil)
    }

    @objc func setToday(_ picker: UIDatePicker) {
        print("setToday()")
        
        manageDateFormatter(date: Date())
    }
    
    func manageDateFormatter(date: Date?) { // date가 nil일 경우 picker.date 사용
        if date != nil {
            datePicker.date = date!
        }
        let dateFormatter = DateFormatter()
        //dateFormatter.dateStyle = .long
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = dateFormatter.string(from: datePicker.date)
        
        dateFormatter.dateFormat = "yyyyMMdd"
        dateInput = dateFormatter.string(from: datePicker.date)
        print("dateTextField.text : \(dateTextField.text ?? "0000-00-00"), dateInput : \(dateInput)")
    }

    @objc func doneBtnOnDatePicker(_ picker: UIDatePicker) {
        print("doneBtnOnDatePicker()")
        dateTextField.resignFirstResponder()//self.view.endEditing(true)

        // 날짜가 바뀌었으므로 서버에서 데이터 다시 받아와야 함.
        petDatas.removeAll()
        petDatas = requestServerData(forDays: 1, forHours: 0)//센서 데이터 수신 코드

        chartOptionChanged(selected: SegSelect(rawValue: chartSelect.selectedSegmentIndex)!, pickerOption: options[optionsIndex])

    }
    
    @objc func doneBtnOnPickerView(_ picker: UIPickerView) {// UIDatePicker, UIPickerView의 Done 버튼 핸들링 통합?
        print("doneBtnOnPickerView()")
        self.view.endEditing(true)
        
        chartOptionChanged(selected: SegSelect(rawValue: chartSelect.selectedSegmentIndex)!, pickerOption: options[optionsIndex])
    }

    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat, entry: ChartDataEntry?, highlight: Highlight?, centerIndices:Highlight?) {
        if let entry = entry, let highlight = highlight {
            print("chartTranslated info:\n\(self)\ndX and dY:\(dX)-\(dY)\nentry:\(entry)\nhightlight:\(highlight)")
        }
        if let centerIndices = centerIndices {
            print("\n center indices is:\n\(centerIndices)")
        }
    }

//    @objc func didTapStartSync() {
//        let deviceManager = DeviceManager.shared
//
//        if deviceManager.isConnected {
//            print("didTapStartSync() will start sync")
//            deviceManager.startSync()
//            //deviceManager.getUUID()
//            //deviceManager.setRTC()
//        } else {
//            print("didTapStartSync() Not Connected to KittyDoc Device!")
//        }
//    }
}

extension AnalysisViewController {
        
    fileprivate func initUIViews() {
        initChartSelect()
        initDateTextField()
        initDatePicker()
        initOptionTextField()
        initPickerView()
        initBarChartView()
    }
    
    fileprivate func addSubviews() {
        view.addSubview(chartSelect)
        view.addSubview(dateTextField)
        view.addSubview(datePicker)
        view.addSubview(optionTextField)
        view.addSubview(pickerView)
        view.addSubview(barChartView)
    }
    
    fileprivate func prepareForAutoLayout() {
        chartSelect.translatesAutoresizingMaskIntoConstraints = false
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        optionTextField.translatesAutoresizingMaskIntoConstraints = false
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        barChartView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setConstraints() {
        chartSelect.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            .isActive = true
        chartSelect.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10)
            .isActive = true
        chartSelect.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10)
            .isActive = true
        chartSelect.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10)
            .isActive = true
        chartSelect.heightAnchor.constraint(equalToConstant: 50)
            .isActive = true
        
        dateTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            .isActive = true
        dateTextField.topAnchor.constraint(equalTo: chartSelect.bottomAnchor, constant: 20)
            .isActive = true
        dateTextField.widthAnchor.constraint(equalToConstant: 200)
            .isActive = true

        datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            .isActive = true
        datePicker.topAnchor.constraint(equalTo: safeArea.centerYAnchor)
            .isActive = true
        datePicker.leftAnchor.constraint(equalTo: view.leftAnchor)
            .isActive = true
        datePicker.rightAnchor.constraint(equalTo: view.rightAnchor)
            .isActive = true
        datePicker.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
            .isActive = true

        optionTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            .isActive = true
        optionTextField.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 20)
            .isActive = true
        optionTextField.widthAnchor.constraint(equalToConstant: 200)
            .isActive = true

        pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            .isActive = true
        pickerView.topAnchor.constraint(equalTo: safeArea.centerYAnchor)
            .isActive = true
        pickerView.leftAnchor.constraint(equalTo: view.leftAnchor)
            .isActive = true
        pickerView.rightAnchor.constraint(equalTo: view.rightAnchor)
            .isActive = true
        pickerView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
            .isActive = true
        
        barChartView.topAnchor.constraint(equalTo: optionTextField.bottomAnchor, constant: 20)
            .isActive = true
        barChartView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            .isActive = true
        barChartView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5)
            .isActive = true
        barChartView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5)
            .isActive = true
        barChartView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10)
            .isActive = true
    }
}

extension AnalysisViewController {
    
    func initChartSelect() {
        chartSelect = UISegmentedControl()

        chartSelect.insertSegment(withTitle: "Year", at: 0, animated: true)
        chartSelect.insertSegment(withTitle: "Month", at: 1, animated: true)
        chartSelect.insertSegment(withTitle: "Week", at: 2, animated: true)
        chartSelect.insertSegment(withTitle: "Day", at: 3, animated: true)

        chartSelect.selectedSegmentIndex = 3 // Set Day as a Default
        chartSelect.addTarget(self, action: #selector(selectedSegChanged(_:)), for: .valueChanged)
    }

    func initDateTextField() {
        dateTextField = ConstantUITextField()
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateTextField.font = UIFont.systemFont(ofSize: 25)
        dateTextField.text = dateFormatter.string(from: date)
        dateTextField.textAlignment = .center
        dateTextField.borderStyle = .roundedRect
    }
    
    func initDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        let toolBar: UIToolbar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 35)

        let today: UIBarButtonItem = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(setToday))
        let space: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnOnDatePicker(_:)))

        toolBar.setItems([today, space, done], animated: true)
        dateTextField.inputAccessoryView = toolBar
        dateTextField.inputView = datePicker
    }
    
    func initOptionTextField() {
        optionTextField = ConstantUITextField()
        
        optionTextField.font = UIFont.systemFont(ofSize: 25)
        optionTextField.text = options[0]
        optionTextField.textAlignment = .center
        optionTextField.borderStyle = .roundedRect
    }
    
    func initPickerView() {
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self

        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 35)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnOnPickerView(_:)))

        toolBar.setItems([flexSpace, doneBtn], animated: true)
        optionTextField.inputAccessoryView = toolBar
        optionTextField.inputView = pickerView
    }

    func initBarChartView() {
        barChartView = BarChartView()
        barChartView.delegate = self
    }
}

extension AnalysisViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        optionsIndex = row // Manage selected row globally - 21.03.12 by ms
        optionTextField.text = options[row]
        print("Change chart data for \(options[row]) graph!")
        
    }
}

