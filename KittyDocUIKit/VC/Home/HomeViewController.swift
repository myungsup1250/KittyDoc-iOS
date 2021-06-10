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

protocol MenuControllerDelegate {
    func didSelectMenuItem(name: String)
}

class HomeViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, ChartViewDelegate {
    @IBOutlet weak var piChartView: UIView!
    @IBOutlet weak var walkView: UIView!
    @IBOutlet weak var sunExView: UIView!
    @IBOutlet weak var vitaDView: UIView!
    @IBOutlet weak var uvRayView: UIView!
    @IBOutlet weak var LuxPolView: UIView!
    @IBOutlet weak var progressView: RingProgressGroupView!
    @IBOutlet weak var connectionView: UIView!
    @IBOutlet weak var waterView: UIView!
    @IBOutlet weak var waterFinalView: UIView!
    @IBOutlet weak var batteryView: UIProgressView!
    
    @IBOutlet weak var petPickerView: UIPickerView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var sunExLabel: UILabel!
    @IBOutlet weak var vitaDLabel: UILabel!
    @IBOutlet weak var uvRayLabel: UILabel!
    @IBOutlet weak var luxPolLabel: UILabel!
    @IBOutlet weak var waterLabel: UILabel!
    @IBOutlet weak var waterFinalLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var stepProgressView: UIProgressView!
    @IBOutlet weak var waterSlide: UISlider!
    @IBOutlet weak var connectionLabel: UILabel!
    
    let width: CGFloat = 100
    let height: CGFloat = 100

    private var sideMenu: SideMenuNavigationController?
    private var scaleController : ScaleViewController? = nil
    private var rtspController : RTSPStreamViewController? = nil

    var delegate : ScaleViewControllerDelegate?

    let deviceManager = DeviceManager.shared
    var count = 0
    var selectedRow = 0
    var piChart = PieChartView()
    var piValues = [Int]()
    
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
    var kcalValue: Double = 0
    var waterFinalValue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HomeViewController.viewDidLoad()")
        self.title = "Home"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSyncDataDone), name: .receiveSyncDataDone, object: nil)

        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        viewAddBackground()
        setPetPickerView()
        
        let menu = SideMenuViewController()
        menu.delegate = self
        piChart.delegate = self
        deviceManager.delegate = self
        deviceManager.secondDelegate = self
        
        sideMenu = SideMenuNavigationController(rootViewController: menu)
        sideMenu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        
        scaleController = self.storyboard?.instantiateViewController(identifier: "ScaleViewController") as? ScaleViewController
        rtspController = self.storyboard?.instantiateViewController(identifier: "RTSPStreamViewController") as?
            RTSPStreamViewController

        addChildController()
                
        // These are optional and only serve to improve accessibility
        progressView.ring1.accessibilityLabel = NSLocalizedString("Move", comment: "Move")
        progressView.ring2.accessibilityLabel = NSLocalizedString("Exercise", comment: "Exercise")
        progressView.ring3.accessibilityLabel = NSLocalizedString("Stand", comment: "Stand")
        
        //홈에서 먼저 정보를 가져와야 배열이 생기기 때문에 일단은 복붙해두었음... 이건 고민해봅시당
        let findData = FindData_Pet(_ownerId: UserInfo.shared.UserID)
        let server = KittyDocServer()
        let findResponse: ServerResponse = server.petFind(data: findData)
        if(findResponse.getCode() as! Int == ServerResponse.FIND_SUCCESS) {
            let jsonString: String = findResponse.getMessage() as! String
            if let arrData = jsonString.data(using: .utf8) {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: arrData, options: .allowFragments) as? [AnyObject] {
                        PetInfo.shared.petArray.removeAll()
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
                            print("[ PetName :", petInfo.PetName, "petID :", petInfo.PetID, "]")
                            PetInfo.shared.petArray.append(petInfo)
                        }
                    }
                } catch {
                    print("JSON 파싱 에러")
                }
            }
        } else if(findResponse.getCode() as! Int == ServerResponse.FIND_FAILURE) {
            //alertWithMessage(message: findResponse.getMessage())
            print("Error (findResponse.getCode() as! Int == ServerResponse.FIND_FAILURE)")
            PetInfo.shared.petArray.removeAll() // 다른 계정의 펫정보가 남아있는 경우를 방지하기 위해 배열을 비운다.
        }
        ////json parsing
        
        //PetChange(index: 0)// 안해도 index 0으로 시작!
        if PetInfo.shared.petArray.isEmpty {
            let petInfo:PetInfo = PetInfo()
            petInfo.PetID = -1
            petInfo.PetName = ""
            petInfo.OwnerID = -1
            //petkg과 petlb를 서버에서 string으로 다루고 있는 오류가 있어서, 추후에 그부분이 수정되면
            //이곳도 수정필요!
            petInfo.PetKG = Double(-1)
            petInfo.PetLB = Double(-1)
            petInfo.PetSex = "None"
            petInfo.PetBirth = "19700101"
            petInfo.Device = "NULL"
            print("Temporary PetInfo Object (PetArray is Empty!)")
        } else {
            // petNameSelectTF.text = PetInfo.shared.petArray[0].PetName
            deviceManager.currentPetId = 0
            let deviceString = PetInfo.shared.petArray[0].Device
            let uuid: UUID? = UUID(uuidString: deviceString)
            // MARK: 연결할 기기 정보가 유효한 경우 연결을 시도
            if uuid != nil {
                print("uuid!.uuidString : \(uuid!.uuidString)")
                deviceManager.removePeripheral()
                deviceManager.connectPeripheral(uuid: uuid!.uuidString, name: "WhoseCat")
            } else {
                print("uuid is nil [ \(deviceString) ]")
            }
        }
//        if let uuid = deviceManager.savedDeviceUUIDString() { // 저장된 기기가 있을 경우 연결 시도
//            deviceManager.connectPeripheral(uuid: uuid, name: "whosecat")
//        }

        // 선택했던 Pet Index를 저장하려면 추가
//        var dict: Dictionary = Dictionary<String, Any>()
//        dict["SelectedPetIndex"] = petChangeIndex
//        UserDefaults.standard.setValue(dict, forKey: DeviceManager.KEY_DICTIONARY)
        // 선택했던 Pet Index로 복원하려면 추가
//        let dict = UserDefaults.standard.dictionary(forKey: DeviceManager.KEY_DICTIONARY)
//        guard dict != nil else {
//            print("\(DeviceManager.KEY_DICTIONARY) does not exist!")
//            return nil
//        }
//        let uuid: String? = dict![DeviceManager.KEY_DEVICE] as? String

        //setPiChartsData()
        //piChartView.addSubview(progress)

        stepProgressView.setProgress(2, animated: true)
        stepProgressView.progress = 0.3
    }
    
    private func addChildController() {
        guard let vc = scaleController else { return }
        guard let rtspvc = rtspController else { return }
        
        addChild(vc)
        addChild(rtspvc)
                
        view.addSubview(vc.view)
        view.addSubview(rtspvc.view)
        
        vc.view.frame = view.bounds
        rtspvc.view.frame = view.bounds
        
        vc.didMove(toParent: self)
        rtspvc.didMove(toParent: self)
        
        vc.view.isHidden = true
        rtspvc.view.isHidden = true
    }
    
    func setPiChartsData() {
        var entries = [ChartDataEntry]()
        
        for x in 0..<piValues.count {
            entries.append(ChartDataEntry(x: Double(x),
                                          y: Double(piValues[x])))
        }
        
        let set = PieChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.colorful()
        
        let data = PieChartData(dataSet: set)
        piChart.data = data
    }
    
    func setData() {
        stepLabel.text = "\(stepValue)"
        kcalLabel.text = "\(Int(kcalValue))"
        sunExLabel.text = "\(sunExValue) Lux"
        vitaDLabel.text = "\(Int(vitaDValue)) iu"
        uvRayLabel.text = "\(Int(uvRayValue)) 점"
        luxPolLabel.text = "\(Int(luxPolValue)) 점"
        waterFinalLabel.text = "\(waterFinalValue)"
        
        progressView.ring1.progress = (Double((breakValue)) / ChartUtility.RestGoal)
        progressView.ring2.progress = (Double((walkValue)) / ChartUtility.StepGoal)
        progressView.ring3.progress = (Double((exerciseValue)) / ChartUtility.ExerciseGoal)
        
        stepProgressView.progress = Float((Double(stepValue) / 1500))
    }
    
    func viewAddBackground() {
        walkView.addColor(color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        sunExView.addColor(color: #colorLiteral(red: 0.7725490196, green: 0.8509803922, blue: 0.9294117647, alpha: 0.6849207594))
        vitaDView.addColor(color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        uvRayView.addColor(color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        LuxPolView.addColor(color: #colorLiteral(red: 0.7725490196, green: 0.8509803922, blue: 0.9294117647, alpha: 0.68))
        connectionView.addColor(color: #colorLiteral(red: 0.7725490196, green: 0.8509803922, blue: 0.9294117647, alpha: 0.7892104395))
        waterView.addColor(color: .white)
        waterFinalView.addColor(color: .white)
    }
    
    func setPetPickerView() {
        var rotationAngle: CGFloat!
        
        petPickerView.delegate = self
        petPickerView.dataSource = self
        
        // 회전 - 전체 틀을 horizontal로 돌리기 위함
        rotationAngle = -90 * (.pi/180)
        petPickerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
    }
    
    @IBAction func didTapSideMenuBtn() {
        present(sideMenu!, animated: true, completion: nil)
    }
    
    
    @IBAction func waterValueChanged(_ sender: UISlider) {
        waterLabel.text = "\(Int(round(sender.value)))"
    }
    
    @IBAction func waterValueMakeZero(_ sender: Any) {
        waterSlide.value = 0
        waterLabel.text = "0"
    }
    
    @IBAction func waterSubmitBtnClicked(_ sender: Any) {
        let waterData = WaterData(_petID: PetInfo.shared.petArray[selectedRow].PetID, _tick: Int(Date().timeIntervalSince1970) * 1000, _waterVal: Int(waterLabel.text!)!)
        let server = KittyDocServer()
        let waterResponse:ServerResponse = server.waterSend(data: waterData)
        
        //가능하다면 실패 시에 잘못 입력한 뷰로 focus를 주는 기능이 들어가는게 좋을듯. --- O
        //회원가입 화면에 보면, UserInfo를 회원가입 성공시 초기화 한다는 주석이 있는데 아닌것 같음.
        //회원가입만 하면 로그인도 안했는데 로그인 한것처럼 어플이 이미 모든 로그인 데이터를 가지고 있게 되니까! OOOK!
        //intent느낌으로 메인 화면 방금 가입한 이메일이랑 비밀번호 채워주는건 좋은듯 ---- LATER
        
        //서버가 꺼져있어서 서버 연결이 안되는 상황에 로그 외에 UIAlertController 활용해서 서버 연결 실패했다고 알려주고 다시 시도하도록 했으면 좋겠음.
        //지금은 서버 연결이 안되면 앱이 아무런 말도 없이 멈춰버린다. 로그를 보지 못하면 알 수가 없다!
        
        //21.03.12 명섭 제안
        
        if(waterResponse.getCode() as! Int == ServerResponse.WATER_SUCCESS){
            let present:Int = Int(waterFinalLabel.text!)!
            let new:Int = Int(waterResponse.getMessage() as! String) ?? 0
            print("present")
            print(present)
            print("new")
            print(new)
            
            waterFinalLabel.text = String(present + new)
            //수분량 입력 화면의 숫자와 막대가 올라간 양? 모두 0으로 만들기
        } else if(waterResponse.getCode() as! Int == ServerResponse.WATER_FAILURE){
            //수분량 입력 화면의 숫자와 막대가 올라간 양? 모두 0으로 만들기
        } else {
            print("water unknown error")
            //수분량 입력 화면의 숫자와 막대가 올라간 양? 모두 0으로 만들기
        }
    }
    
    func getData(index: Int) {
        let today = Date()
        let hour = Calendar.current.component(.hour, from: today)
        let minute = Calendar.current.component(.minute, from: today)
        let second = Calendar.current.component(.second, from: today)
        let timeIntervalSince1970 = today.timeIntervalSince1970
        let thisDayStartSec = Int(timeIntervalSince1970) - (HOUR_IN_SEC * hour) - (MINUTE_IN_SEC * minute) - second
        let thisDayEndSec = Int(timeIntervalSince1970) + (HOUR_IN_SEC * (23-hour)) + (MINUTE_IN_SEC * (59 - minute)) + (60-second) - 1
        
        let analysisData:AnalysisData = AnalysisData(_petID: PetInfo.shared.petArray[index].PetID, _startMilliSec: (thisDayStartSec * 1000), _endMilliSec: (thisDayEndSec * 1000))
        let server:KittyDocServer = KittyDocServer()
        let analysisResponse:ServerResponse = server.sensorRequestDay(data: analysisData)

        if (analysisResponse.getCode() as! Int == ServerResponse.ANALYSIS_SUCCESS) {
            let jsonString: String = analysisResponse.getMessage() as! String
            if let arrData = jsonString.data(using: .utf8) {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: arrData, options: .allowFragments) as? [AnyObject] {
                        //let petData = PetData()
                        //petData.time = jsonArray[0]["Time"] as! CLong
                        //petData.time /= 1000 // Translate millisec to sec
                        sunExValue = jsonArray[0]["SunVal"] as! Int
                        uvRayValue = jsonArray[0]["UvVal"] as! Double
                        vitaDValue = jsonArray[0]["VitDVal"] as! Double
                        exerciseValue = jsonArray[0]["ExerciseVal"] as! Int
                        walkValue = jsonArray[0]["WalkVal"] as! Int
                        breakValue = jsonArray[0]["RestVal"] as! Int
                        stepValue = jsonArray[0]["StepVal"] as! Int
                        luxPolValue = jsonArray[0]["LuxpolVal"] as! Double
                        kcalValue = jsonArray[0]["KalVal"] as! Double
                        waterFinalValue = jsonArray[0]["WaterVal"] as! Int
                    }
                } catch {
                    print("JSON 파싱 에러")
                }
            
            } else if(analysisResponse.getCode() as! Int == ServerResponse.ANALYSIS_FAILURE){
                print(analysisResponse.getMessage() as! String)
            }
        
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        setPiChartsData()
        if !PetInfo.shared.petArray.isEmpty {// PetArray가 비어있지 않을 경우에만 서버에 요청
            getData(index: selectedRow)
        }
        setData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return height
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return width
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        //pickerView.backgroundColor = .clear
        pickerView.subviews.forEach {
            $0.backgroundColor = .clear
        }
        
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        view.transform = CGAffineTransform(rotationAngle: 90 * (.pi/180))

        let label = UILabel()
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: width, height: height)
        label.text = PetInfo.shared.petArray[row].PetName
        label.font = UIFont.systemFont(ofSize: 25)
        view.addSubview(label)

        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
        PetChange(index: selectedRow) // 표시되는 데이터들 변경
        deviceManager.currentPetId = selectedRow
        let deviceString = PetInfo.shared.petArray[selectedRow].Device
        let uuid: UUID? = UUID(uuidString: deviceString)
        // MARK: 연결할 기기 정보가 유효한 경우 연결을 시도할 지 사용자에게 묻는다
        DispatchQueue.main.async { [self] in
            //self.connectionLabel.text = ""
            print("pickerView(didSelectRow: \(selectedRow)")
            if uuid != nil {
                print("uuid!.UUIDValue! : \(uuid!.uuidString)")
                let alert = UIAlertController(title: "Pet changed to \(PetInfo.shared.petArray[selectedRow].PetName)", message: "Do you want to connect to \(PetInfo.shared.petArray[selectedRow].PetName)'s Device?", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "Confirm", style: .default) { (alert: UIAlertAction!) in
                    print("Disconnect from current device And connect to New One")
                    deviceManager.removePeripheral()
                    deviceManager.connectPeripheral(uuid: uuid!.uuidString, name: "WhoseCat")
                }
                let cancel = UIAlertAction(title: "Dismiss", style: .destructive) { (alert: UIAlertAction!) in
                    print("Dismiss Alert")
                }
                alert.addAction(confirm)
                alert.addAction(cancel)
                
                self.present(alert, animated: true, completion: nil)
            } else {
                print("uuid is nil (\(deviceString))")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dailyreportSegue" {
            guard let vc = segue.destination as? DailyReportViewController  else { return }
            vc.sunValue = self.sunExValue
            vc.moveValue = self.exerciseValue
            vc.vitaValue = Int(self.vitaDValue)
        }
    }
    
    func PetChange(index: Int) {
        deviceManager.currentPetId = selectedRow
        getData(index: selectedRow)
        setData()
        // MARK: - 펫 변경할 때 기기 상태바 변경하기
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

    var waterRing: UICircularProgressRing = {
        let waterRing = UICircularProgressRing()
        waterRing.frame = CGRect(x: 200, y: 500, width: 100, height: 100)
        waterRing.style = .ontop
        waterRing.outerRingColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        waterRing.innerRingColor = .systemBlue
        waterRing.minValue = 0
        waterRing.maxValue = 300
        return waterRing
    }()
}

extension HomeViewController: DeviceManagerDelegate {
    func onDeviceNotFound() {
        DispatchQueue.main.async {
            print("Couldn't find any KittyDoc Devices!")
            self.connectionLabel.text = "기기를 찾을 수 없습니다"
        }
    }
    
    func onDeviceConnected(peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            print("onDeviceConnected(\(peripheral))")
            self.connectionLabel.text = "기기에 연결 중..."
        }
    }
    
    func onDeviceDisconnected() {
        DispatchQueue.main.async {
            self.connectionLabel.text = "기기 연결이 해제되었습니다"
            let alert: UIAlertController = UIAlertController(title: "Disconnected!", message: "Disonnected from KittyDoc Device!", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func onBluetoothNotAccessible() {
        //print("[+]onBluetoothNotAccessible()")
        DispatchQueue.main.async {
            self.connectionLabel.text = "블루투스 에러 : 설정을 확인하세요"
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
        //print("[-]onBluetoothNotAccessible()")
    }
    
    func onDevicesFound(peripherals: [PeripheralData]) {// peripherals 사용?
        //print("[+]onDevicesFound()")
        DispatchQueue.main.async {
            print("\n<<< Found some KittyDoc Devices! >>>\n")
            self.connectionLabel.text = "기기를 찾았습니다"
        }
        //print("[-]onDevicesFound()")
    }
    
    func onConnectionFailed() {
        //print("[+]onConnectionFailed()")
        DispatchQueue.main.async {
            print("\n<<< Failed to Connect to KittyDoc Device! >>>\n")
            self.connectionLabel.text = "연결이 해제되었습니다"
        }
        //print("[-]onConnectionFailed()")
    }
    
    func onServiceFound() {
        //print("[+]HomeViewController.onServiceFound")
        DispatchQueue.main.async {
            print("\n<<< Found all required Service! >>>\n")
            self.connectionLabel.text = "기기에 연결되었습니다"
            self.deviceManager.getBattery()
            self.deviceManager.startSync()
        }
        //print("[-]HomeViewController.onServiceFound")
    }
    
    func onDfuTargFound(peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.connectionLabel.text = "초기화가 필요합니다"
            let alert: UIAlertController = UIAlertController(title: "Found DFU Device!", message: "There is a DFU Device!", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension HomeViewController: DeviceManagerSecondDelegate {
    func onSysCmdResponse(data: Data) {
//        print("[+]onSysCmdResponse")
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
//        print("[-]onSysCmdResponse")
    }
    
    func onSyncProgress(progress: Int) {
        DispatchQueue.main.async {
            //print("[+]onSyncProgress")
            print("Progress Percent : \(progress)")
            self.connectionLabel.text = "동기화 중... (\(progress)%)"
            //print("[-]onSyncProgress")
        }
    }
    
    func onReadBattery(percent: Int) {
        DispatchQueue.main.async {
            //print("[+]onReadBattery")
            print("batteryLevel : \(percent)")
            let percentDivide: Double = Double(percent) / 100
            self.batteryView.progress = Float(percentDivide)
            self.batteryLabel.text = "\(percent) %"
            //print("[-]onReadBattery")
        }
    }
    
    func onSyncCompleted() {
        DispatchQueue.main.async {
            self.connectionLabel.text = "동기화 완료"
        }
    }
}

extension HomeViewController { // @objc funcs
    // receiveSyncDataDone() will be called when Receiving SyncData Done!
    @objc func receiveSyncDataDone() {
        print("\n<<< HomeViewController.receiveSyncDataDone() >>>")
        let startTime: TimeInterval = Date().timeIntervalSince1970 * 1000 - 604800000 * 2
        let endTime: TimeInterval = Date().timeIntervalSince1970 * 1000 - 604800000
        print("endTime RAW : \(endTime), endTime [\(unixtimeToString(unixtime: endTime / 1000))]")
        print("startTime RAW : \(startTime), startTime [\(unixtimeToString(unixtime: startTime / 1000))]")
        let analysisData:AnalysisData = AnalysisData(_petID: 32, _startMilliSec: Int(startTime), _endMilliSec: Int(endTime))
        let server:KittyDocServer = KittyDocServer()
        let analysisResponse:ServerResponse = server.sensorRequestHour(data: analysisData)
        
        if(analysisResponse.getCode() as! Int == ServerResponse.ANALYSIS_SUCCESS){
            print(analysisResponse.getMessage() as! String)
        } else if(analysisResponse.getCode() as! Int == ServerResponse.ANALYSIS_FAILURE){
            print(analysisResponse.getMessage() as! String)
        }
        
        // UI에 값 입력해서 출력시키기.
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
    
    func batteryRadius() {
        self.layer.cornerRadius = 3
    }
}

class SideMenuViewController: UITableViewController {
    
    public var delegate: MenuControllerDelegate?
    
    var items = ["홈", "체중 측정", "급수량 측정", "급식량 측정", "CCTV 관리"]
    var images = ["house", "scalemass", "drop", "torus", "camera.metering.center.weighted"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "SideMenuTableViewCell", bundle: nil)
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 250))
        let emailLabel = UILabel(frame: CGRect(x: 20, y: 100, width: 200, height: 50))
        let nameLabel = UILabel(frame: CGRect(x: 20, y: 130, width: 150, height: 50))
        emailLabel.text = "\(UserInfo.shared.Email)"
        nameLabel.text = "\(UserInfo.shared.Name)"
        
        emailLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        header.addSubview(emailLabel)
        header.addSubview(nameLabel)

        tableView.tableHeaderView = header
        tableView.register(nib, forCellReuseIdentifier: "SideMenuTableViewCell")
        tableView.backgroundColor = #colorLiteral(red: 0.7725490196, green: 0.8509803922, blue: 0.9294117647, alpha: 1)
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell",                                       for: indexPath) as! SideMenuTableViewCell
        
        cell.nameLabel.text = items[indexPath.row]
        cell.userimageView.image = UIImage(systemName: images[indexPath.row])
        cell.userimageView.tintColor = #colorLiteral(red: 0.3336932659, green: 0.535705924, blue: 0.6768123507, alpha: 1)
        cell.backgroundColor = #colorLiteral(red: 0.7725490196, green: 0.8509803922, blue: 0.9294117647, alpha: 1)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let seletedItem = items[indexPath.row]
        delegate?.didSelectMenuItem(name: seletedItem)
    }

}

extension HomeViewController: MenuControllerDelegate {
    
    func didSelectMenuItem(name: String) {
        sideMenu?.dismiss(animated: true, completion: { [weak self] in
            print("didSelectMenuItem(name: \(name))")

            self?.title = name
            
            guard let scale = self?.scaleController else { return }
            guard let rtsp = self?.rtspController else { return }
            scale.view.isHidden = true
            rtsp.view.isHidden = true
            if name == "체중 측정" {
                scale.view.isHidden = false
                rtsp.view.isHidden = true
                if !PetInfo.shared.petArray.isEmpty {
                    NotificationCenter.default.post(name: .petName, object: "\(PetInfo.shared.petArray[self!.selectedRow].PetName)")
                }
                //self?.delegate?.setPetName(name: PetInfo.shared.petArray[self!.selectedRow].PetName)
            } else if name == "홈" {
                scale.view.isHidden = true
                rtsp.view.isHidden = true
            } else if name == "CCTV" {
                rtsp.view.isHidden = false
                scale.view.isHidden = true
            }
        })
    }
}
