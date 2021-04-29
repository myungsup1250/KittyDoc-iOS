//
//  HomeViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/16.
//

import UIKit
import Charts
import CoreBluetooth
import UICircularProgressRing
import SideMenu



class HomeViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var piChartView: UIView!
    @IBOutlet weak var walkView: UIView!
    @IBOutlet weak var sunExView: UIView!
    @IBOutlet weak var vitaDView: UIView!
    @IBOutlet weak var uvRayView: UIView!
    @IBOutlet weak var LuxPolView: UIView!
    @IBOutlet weak var progressView: RingProgressGroupView!
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var sunExLabel: UILabel!
    @IBOutlet weak var vitaDLabel: UILabel!
    @IBOutlet weak var uvRayLabel: UILabel!
    @IBOutlet weak var luxPolLabel: UILabel!
    @IBOutlet weak var stepProgressView: UIProgressView!
    
    
    private let sideMenu = SideMenuNavigationController(rootViewController: UIViewController())
    let deviceManager = DeviceManager.shared
    var count = 0
    var selectedRow = 0
    var piChart = PieChartView()
    var piValues: [Int] = []
    
    var waterValue: Int = 0 {
        didSet {
            //petWaterLabel.text = "\(waterValue)"
            waterRing.value = CGFloat(waterValue)
        }
    }
    
    let MINUTE_IN_SEC:Int = 60
    let HOUR_IN_SEC:Int = 60 * 60
    
    //sunExValue랑 lightVal이 뭘 뜻하는지 애매해서 이야기 해봐야함
    var breakValue: Int = 0
    var exerciseValue: Int = 0
    var walkValue: Int = 0
    var stepValue: Int = 0
    var vitaDValue: Double = 0
    var sunExValue: Int = 0
    var uvRayValue: Double = 0
    var luxPolValue: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewAddBackground()

        sideMenu.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        piChart.delegate = self
        self.title = "Hello, JENNY👋"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        deviceManager.delegate = self
        deviceManager.secondDelegate = self
        print("HomeViewController.viewDidLoad()")
        
        if let uuid = deviceManager.savedDeviceUUIDString() { // 저장된 기기가 있을 경우 연결 시도
            deviceManager.connectPeripheral(uuid: uuid, name: "kittydoc")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSyncDataDone), name: .receiveSyncDataDone, object: nil)
        
        // These are optional and only serve to improve accessibility
        progressView.ring1.accessibilityLabel = NSLocalizedString("Move", comment: "Move")
        progressView.ring2.accessibilityLabel = NSLocalizedString("Exercise", comment: "Exercise")
        progressView.ring3.accessibilityLabel = NSLocalizedString("Stand", comment: "Stand")
        
        progressView.ring1.progress = 0.2
        progressView.ring2.progress = 0.7
        progressView.ring3.progress = 0.52

        //홈에서 먼저 정보를 가져와야 배열이 생기기 때문에 일단은 복붙해두었음... 이건 고민해봅시당
        let findData:FindData_Pet = FindData_Pet(_ownerId: UserInfo.shared.UserID)
        let server:KittyDocServer = KittyDocServer()
        let findResponse:ServerResponse = server.petFind(data: findData)
        
        if(findResponse.getCode() as! Int == ServerResponse.FIND_SUCCESS) {
            let jsonString:String = findResponse.getMessage() as! String
            if let arrData = jsonString.data(using: .utf8) {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: arrData, options: .allowFragments) as? [AnyObject] {
                        for i in 0..<jsonArray.count {
                            let petInfo:PetInfo = PetInfo()
                            petInfo.PetID = jsonArray[i]["PetID"] as! Int
                            petInfo.PetName = jsonArray[i]["PetName"] as! String
                            petInfo.OwnerID = jsonArray[i]["OwnerID"] as! Int
                            //petkg과 petlb를 서버에서 string으로 다루고 있는 오류가 있어서, 추후에 그부분이 수정되면
                            //이곳도 수정필요!
                            petInfo.PetKG = jsonArray[i]["PetKG"] as! Double
                            petInfo.PetLB = jsonArray[i]["PetLB"] as! Double
                            petInfo.PetSex = jsonArray[i]["PetSex"] as! String
                            petInfo.PetBirth = jsonArray[i]["PetBirth"] as! String
                            petInfo.Device = jsonArray[i]["Device"] as! String
                            
                            if !PetInfo.shared.petArray.contains(where: { (original: PetInfo) -> Bool in
                                return original.PetName == petInfo.PetName
                            }) {
                                PetInfo.shared.petArray.append(petInfo)
                            }
                        }
                    }
                } catch {
                    print("JSON 파싱 에러")
                }
            }
        } else if(findResponse.getCode() as! Int == ServerResponse.FIND_FAILURE) {
            //alertWithMessage(message: findResponse.getMessage())
            print("Error (findResponse.getCode() as! Int == ServerResponse.FIND_FAILURE)")
        }
        ////json parsing
        if !PetInfo.shared.petArray.isEmpty {
           // petNameSelectTF.text = PetInfo.shared.petArray[0].PetName
        }
        
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
       
        
        PetChange(index: 0)
        //setPiChartsData()
        //piChartView.addSubview(progress)
        setData()

        stepProgressView.setProgress(2, animated: true)
        stepProgressView.progress = 0.3
    }
    
    func setPiChartsData() {
        var entries = [ChartDataEntry]()
        
        for x in 0..<piValues.count {
            entries.append(ChartDataEntry(x: Double(x),
                                          y: Double(piValues[x])))
        }
        print("이거다~~")
        print(entries)
        
        let set = PieChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.colorful()
        
        let data = PieChartData(dataSet: set)
        piChart.data = data
    }
    
    func setData() {
        stepLabel.text = "\(stepValue)"
        kcalLabel.text = ""
        sunExLabel.text = "\(sunExValue) Lux"
        vitaDLabel.text = "\(vitaDValue) iu"
        uvRayLabel.text = "\(uvRayValue) 점"
        luxPolLabel.text = "\(luxPolValue) 점"
    }
    
    
        
    func viewAddBackground() {
        walkView.addColor(color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        sunExView.addColor(color: #colorLiteral(red: 0.7725490196, green: 0.8509803922, blue: 0.9294117647, alpha: 0.6849207594))
        vitaDView.addColor(color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        uvRayView.addColor(color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        LuxPolView.addColor(color: #colorLiteral(red: 0.7725490196, green: 0.8509803922, blue: 0.9294117647, alpha: 0.6786131195))
    }
    
    //    override func viewDidDisappear(_ animated: Bool) {// View가 사라질 때. ViewWillDisappear은 View가 안 보일 때.
    //        NotificationCenter.default.removeObserver(self, name: .receiveSyncDataDone, object: nil)
    //        print("HomeViewController.viewDidDisappear()")
    //    }
    
    @IBAction func didTapSideMenuBtn() {
        present(sideMenu, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let today = Date()
        let hour = Calendar.current.component(.hour, from: today)
        let minute = Calendar.current.component(.minute, from: today)
        let second = Calendar.current.component(.second, from: today)
        let timeIntervalSince1970 = today.timeIntervalSince1970
        let thisDayStartSec = Int(timeIntervalSince1970) - (HOUR_IN_SEC * hour) - (MINUTE_IN_SEC * minute) - second
        let thisDayEndSec = Int(timeIntervalSince1970) + (HOUR_IN_SEC * (23-hour)) + (MINUTE_IN_SEC * (59 - minute)) + (60-second) - 1
        
        let analysisData:AnalysisData = AnalysisData(_petID: PetInfo.shared.petArray[selectedRow].PetID, _startMilliSec: (thisDayStartSec * 1000), _endMilliSec: (thisDayEndSec * 1000))
        let server:KittyDocServer = KittyDocServer()
        let analysisResponse:ServerResponse = server.sensorRequestDay(data: analysisData)
        
        
        

        if(analysisResponse.getCode() as! Int == ServerResponse.ANALYSIS_SUCCESS) {
            let jsonString: String = analysisResponse.getMessage() as! String
            if let arrData = jsonString.data(using: .utf8) {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: arrData, options: .allowFragments) as? [AnyObject] {
                        
                        //let petData = PetData()
                        //petData.time = jsonArray[0]["Time"] as! CLong
                        //petData.time /= 1000 // Translate millisec to sec
                        sunExValue = jsonArray[0]["SunVal"] as! Int
                        //petData.uvVal = jsonArray[0]["UvVal"] as! Double
                        uvRayValue = jsonArray[0]["UvVal"] as! Double
                        vitaDValue = jsonArray[0]["VitDVal"] as! Double
                        exerciseValue = jsonArray[0]["ExerciseVal"] as! Int
                        walkValue = jsonArray[0]["WalkVal"] as! Int
                        breakValue = jsonArray[0]["RestVal"] as! Int
                        stepValue = jsonArray[0]["StepVal"] as! Int
                        luxPolValue = jsonArray[0]["LuxpolVal"] as! Double
                        
                        //petData.kalVal = jsonArray[0]["KalVal"] as! Double
                        //petData.waterVal = jsonArray[0]["WaterVal"] as! Int
//                        print("today's data!")
//                        print(lightValue)
//                        print(vitaDValue)
//                        print(exerciseValue)
//                        print(walkValue)
//                        print(stepValue)
//                        print(sunExValue)
//                        print(breakValue)
                        
                        piValues.append(exerciseValue)
                        piValues.append(breakValue)
                        piValues.append(walkValue)
                        
                        print(piValues[0])
                        print(piValues[1])
                        print(piValues[2])
                    }
                } catch {
                    print("JSON 파싱 에러")
                }
            
            } else if(analysisResponse.getCode() as! Int == ServerResponse.ANALYSIS_FAILURE){
                print(analysisResponse.getMessage() as! String)
            }
            
        }
        setPiChartsData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PetInfo.shared.petArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PetInfo.shared.petArray[row].PetName
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //petNameSelectTF.text = PetInfo.shared.petArray[row].PetName //텍스트 필드 이름 변경
        selectedRow = row
        PetChange(index: row) //표시되는 데이터들 변경
    } //펫이 선택되었을 때 호출되는 함수!!!
    
    
    func PetChange(index: Int) {
        //이 함수는 위의 pickerView(....didSelectRow...) 함수안에 있는 메소드야! (didSelectRow 저 함수는 피커뷰로 펫을 선택했을 때 호출되는 함수이고!) 보이는 데이터들을 변경해주려고 만든 함수임!!
        //PetInfo.shared.petArray[index] 이것이 펫 배열에서 펫 가져오기!
        
        
    }
    
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.frame = CGRect(x: 0, y: 250, width: self.view.bounds.width, height: 180)
        picker.backgroundColor = .white
        picker.delegate = self
        picker.dataSource = self
        
        let doneBtn = UIBarButtonItem()
        doneBtn.title = "Done"
        doneBtn.target = self
        doneBtn.action = #selector(doneBtnPressed)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        toolBar.setItems([flexSpace, doneBtn], animated: true)
        //petNameSelectTF.inputAccessoryView = toolBar
        
        return picker
    }()
    
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddWater" {
            let destinationVC = segue.destination as! WaterViewController
            destinationVC.petNum = selectedRow
            destinationVC.water.setValue(Float(waterValue), animated: true)
            
        }
        
    }
    
    lazy var waterRing: UICircularProgressRing = {
        let waterRing = UICircularProgressRing()
        waterRing.frame = CGRect(x: 200, y: 500, width: 100, height: 100)
        waterRing.style = .ontop
        waterRing.outerRingColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        waterRing.innerRingColor = .systemBlue
        waterRing.value = CGFloat(waterValue)
        waterRing.minValue = 0
        waterRing.maxValue = 300
        return waterRing
    }()
}

extension HomeViewController: DeviceManagerDelegate {
    func onDeviceNotFound() {
        DispatchQueue.main.async {
            print("Couldn't find any KittyDoc Devices!")
        }
    }
    
    func onDeviceConnected(peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            print("Successfully Connected to KittyDoc Device!")
        }
    }
    
    func onDeviceDisconnected() {
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController(title: "Disconnected!", message: "Disonnected from KittyDoc Device!", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func onBluetoothNotAccessible() {
        print("[+]onBluetoothNotAccessible()")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error on Bluetooth!", message: "Please check your settings!", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "Settings", style: .default) { (alert: UIAlertAction!) in
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {//"App-Prefs:root=Bluetooth" //Banned from Apple App Store
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            let cancel = UIAlertAction(title: "Dismiss", style: .destructive) { (alert: UIAlertAction!) in
                print("Dismiss Alert")
            }
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        }
        print("[-]onBluetoothNotAccessible()")
    }
    
    func onDevicesFound(peripherals: [PeripheralData]) {// peripherals 사용?
        print("[+]onDevicesFound()")
        DispatchQueue.main.async {
            print("\n<<< Found some KittyDoc Devices! >>>\n")
        }
        print("[-]onDevicesFound()")
    }
    
    func onConnectionFailed() {
        print("[+]onConnectionFailed()")
        DispatchQueue.main.async {
            print("\n<<< Failed to Connect to KittyDoc Device! >>>\n")
        }
        print("[-]onConnectionFailed()")
    }
    
    func onServiceFound() {
        //print("[+]HomeViewController.onServiceFound")
        DispatchQueue.main.async {
            print("\n<<< Found all required Service! >>>\n")
        }
        //print("[-]HomeViewController.onServiceFound")
        
    }
    
    func onDfuTargFound(peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController(title: "Found DFU Device!", message: "There is a DFU Device!", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension HomeViewController: DeviceManagerSecondDelegate {
    func onSysCmdResponse(data: Data) {
        print("[+]onSysCmdResponse")
        //        print("Data : \(data)")
        //        print("data(count : \(data.count)) => ", terminator: "")
        //        for i in 0..<data.count {
        //            print("\(data[i]) ", terminator: "")
        //        }
        //        print("")
        if count == 0 {
            count += 1
            deviceManager.setUUID(uuid: CBUUID(data: data.advanced(by: 1)))
        }
        print("[-]onSysCmdResponse")
    }
    
    func onSyncProgress(progress: Int) {
        print("[+]onSyncProgress")
        print("Progress Percent : \(progress)")
        print("[-]onSyncProgress")
    }
    
    func onReadBattery(percent: Int) {
        print("[+]onReadBattery")
        print("batteryLevel : \(percent)")
        print("[-]onReadBattery")
    }
    
    func onSyncCompleted() {
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController(title: "Sync Completed!", message: "Synchronization Completed!", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension HomeViewController { // @objc funcs
    
    // receiveSyncDataDone() will be called when Receiving SyncData Done!
    @objc func receiveSyncDataDone() {
        print("\n<<< HomeViewController.receiveSyncDataDone() >>>")
        let startTime = Int(Date().timeIntervalSince1970 * 1000 - 604800000 * 2)
        let endTime = Int(Date().timeIntervalSince1970 * 1000 - 604800000)
        print("endTime RAW : \(endTime), endTime [\(unixtimeToString(unixtime: time_t(endTime / 1000)))]")
        print("startTime RAW : \(startTime), startTime [\(unixtimeToString(unixtime: time_t(startTime / 1000)))]")
        let analysisData:AnalysisData = AnalysisData(_petID: 32, _startMilliSec: startTime, _endMilliSec: endTime)
        let server:KittyDocServer = KittyDocServer()
        let analysisResponse:ServerResponse = server.sensorRequestHour(data: analysisData)
        
        if(analysisResponse.getCode() as! Int == ServerResponse.ANALYSIS_SUCCESS){
            print(analysisResponse.getMessage() as! String)
        } else if(analysisResponse.getCode() as! Int == ServerResponse.ANALYSIS_FAILURE){
            print(analysisResponse.getMessage() as! String)
        }
    }
    
    @objc func doneBtnPressed() {
        self.view.endEditing(true)
    }
    
    @objc func didTapWaterBtn() {
        if PetInfo.shared.petArray.count != 0 {
            performSegue(withIdentifier: "AddWater", sender: self)
        }
    }
    
}


extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: CGRect(x: -20, y: 0, width: bounds.width + 20, height: bounds.height))
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subView.clipsToBounds = true
        subView.layer.cornerRadius = 20
        insertSubview(subView, at: 0)
    }
}


extension UIView {
    func addColor(color: UIColor) {
        self.backgroundColor = color
        self.layer.cornerRadius = 20
        self.layer.shadowColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = .init(width: self.layer.borderWidth, height: 10)
        self.layer.shadowRadius = 5
    }
}




extension HomeViewController: ChartViewDelegate {
    
    
    
}


class SideMenuViewController: UIViewController {
    
}
