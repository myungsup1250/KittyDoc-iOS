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
    var barChartView: BarChartView!
    var dateTextField: ConstantUITextField!
    var optionTextField: ConstantUITextField!
    var datePicker: UIDatePicker!
    var pickerView: UIPickerView!
    var chartSelect: UISegmentedControl!

    var options = [ "Sun", "UV", "Vitmin D", "Exercise", "Walk", "Steps", "LuxPolution", "Rest", "Kal", "Water"]
    
    var months = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]
    var days = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
    var daysofweek = [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" ]
    var times = [ "00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00" ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = "Analysis"
//        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        NotificationCenter.default.addObserver(self, selector: #selector(receiveSyncDataDone), name: .receiveSyncDataDone, object: nil)
        print("AnalysisViewController.viewDidLoad()")
        
        safeArea = view.safeAreaLayoutGuide// view.layoutMarginsGuide
        userInterfaceStyle = self.traitCollection.userInterfaceStyle
        initUIViews()
        addSubviews()
        prepareForAutoLayout()
        setConstraints()
        manageUserInterfaceStyle()
                
        barChartView.delegate = self
        setChart(dataPoints: times, values: [Double(5), Double(10), Double(15), Double(20), Double(25), Double(30), Double(35), Double(40), Double(45), Double(50), Double(55), Double(60), Double(65), Double(70), Double(75), Double(80), Double(85), Double(90), Double(95), Double(100), Double(105), Double(110), Double(115), Double(120)])
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
//
//        let set = BarChartDataSet(entries: entries, label: "BarChartDataSetLabel")
//
//        // 차트 컬러
//        set.colors = [.systemBlue]//ChartColorTemplates.material()
//
//        // 데이터 삽입
//        let data  = BarChartData(dataSet: set)
//        barChartView.data = data
//    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        // 데이터 생성
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "DataSetName")

        // 차트 컬러
        chartDataSet.colors = [.systemBlue]//ChartColorTemplates.material()
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
        
        // 오른쪽 레이블 제거
        barChartView.rightAxis.enabled = false
        // 애니메이션
        barChartView.animate(yAxisDuration: 2.0, easingOption: .easeInOutQuad)
        
        // 최대 10개까지 보이도록 설정... 나머지는 스크롤해서 보기?
        barChartView.setVisibleXRangeMaximum(Double(10.0))
        barChartView.zoom(scaleX: CGFloat(dataPoints.count/15), scaleY: 1.0, x: 0, y: 0)
        barChartView.setScaleEnabled(false)
        
        // LimitLine
        let ll = ChartLimitLine(limit: 80.0, label: "Goal")
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
        barChartView.leftAxis.addLimitLine(ll)
        // 맥시멈
        barChartView.leftAxis.axisMaximum = 150
        // 미니멈
        barChartView.leftAxis.axisMinimum = 0
                
        // 더블 탭으로 줌 안되게
        barChartView.doubleTapToZoomEnabled = false
        // 선택 안되게
        chartDataSet.highlightEnabled = false
    }
}

extension AnalysisViewController {
        
    func initUIViews() {
        initChartSelect()
        initDateTextField()
        initDatePicker()
        initOptionTextField()
        initPickerView()
        initBarChartView()
    }
    
    func addSubviews() {
        view.addSubview(chartSelect)
        view.addSubview(dateTextField)
        view.addSubview(datePicker)
        view.addSubview(optionTextField)
        view.addSubview(pickerView)
        view.addSubview(barChartView)
    }
    
    func prepareForAutoLayout() {
        chartSelect.translatesAutoresizingMaskIntoConstraints = false
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        optionTextField.translatesAutoresizingMaskIntoConstraints = false
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        barChartView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setConstraints() {
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
        chartSelect.addTarget(self, action: #selector(changeChart), for: .valueChanged)
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
        datePicker.addTarget(self, action: #selector(dataChanged), for: .allEvents)

        let toolBar: UIToolbar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 35)


        let space: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapOnDoneBtn))

        toolBar.setItems([space, done], animated: true)
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
        let doneBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnPressed))

        toolBar.setItems([flexSpace, doneBtn], animated: true)
        optionTextField.inputAccessoryView = toolBar
        optionTextField.inputView = pickerView
    }

    func initBarChartView() {
        barChartView = BarChartView()
        // What to do?
    }
}

extension AnalysisViewController {
    
    enum SegSelect: Int {
        case Year = 0
        case Month
        case Week
        case Day
    }
    
    @objc func changeChart(_ segment: UISegmentedControl) {
        print("changeChart()", terminator: " ")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let yearDate = dateFormatter.date(from: dateTextField.text!)
        let year = Calendar.current.component(.year,  from: yearDate!)

        let monthDate = dateFormatter.date(from: dateTextField.text!)
        let month = Calendar.current.component(.month,  from: monthDate!)

        let dayDate = dateFormatter.date(from: dateTextField.text!)
        let day = Calendar.current.component(.day,  from: dayDate!)
        
        print("dateTextField.text: \(dateTextField.text!)")
        print("year: \(year), month: \(month), day: \(day)")

        let selected = SegSelect(rawValue: segment.selectedSegmentIndex)!
        switch selected {
        case SegSelect.Year:
            print("You Selected Year!")
            setChart(dataPoints: months, values: [Double(10), Double(20), Double(30), Double(40), Double(50), Double(60), Double(70), Double(80), Double(90), Double(100), Double(110), Double(120)])
        case SegSelect.Month:
            print("You Selected Month!")
            guard let numberOfDays = getDaysInMonth(month: month, year: year) else {
                print("Error in getDaysInMonth(month: , year:)!!")
                return
            }
            print("Year : \(year), Month : \(month) => Days : ", numberOfDays)

            //특정 달의 일 수 계산하기 Test Code
            var dayValues = [Double]()
            for i in 1...numberOfDays {
                dayValues.append(Double(i * 5))
            }
            setChart(dataPoints: days.dropLast(31-numberOfDays), values: dayValues)
        case SegSelect.Week:
            print("You Selected Week!")
            setChart(dataPoints: daysofweek, values: [Double(15), Double(30), Double(45), Double(60), Double(75), Double(90), Double(105)])
        case SegSelect.Day:
            print("You Selected Day!")
            setChart(dataPoints: times, values: [Double(5), Double(10), Double(15), Double(20), Double(25), Double(30), Double(35), Double(40), Double(45), Double(50), Double(55), Double(60), Double(65), Double(70), Double(75), Double(80), Double(85), Double(90), Double(95), Double(100), Double(105), Double(110), Double(115), Double(120)])
        }
    }
    
    @objc func dataChanged(_ picker: UIDatePicker) {
        print("dataChanged()")

        let dateFormatter = DateFormatter()
        //dateFormatter.dateStyle = .long
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = dateFormatter.string(from: picker.date)
        
        dateFormatter.dateFormat = "yyyyMMdd"
        dateInput = dateFormatter.string(from: picker.date)
        print("dateTextField.text : \(dateTextField.text ?? "0000-00-00"), dateInput : \(dateInput)")
    }

    @objc func tapOnDoneBtn(_ picker: UIDatePicker) {
        print("tapOnDoneBtn()")
        dateTextField.resignFirstResponder()
    }
    
    @objc func doneBtnPressed() {
        self.view.endEditing(true)
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
        optionTextField.text = options[row]
        print("Ask for \(options[row]) Graph Data!")
//        PetChange(index: row) //표시되는 데이터들 변경
    } //펫이 선택되었을 때 호출되는 함수!!!
}
