//
//  DeviceManager.swift
//  KittyDocBLETest
//
//  Created by 곽명섭 on 2021/01/03.
//  Copyright © 2020 Myungsup. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol DeviceManagerDelegate {//: NSObject {
    func onDeviceNotFound()
    func onDeviceConnected(peripheral: CBPeripheral) // 기기 연결됨
    func onDeviceDisconnected()
    
//    @optional
    func onBluetoothNotAccessible() // BLE Off or No Permission... etc.
    func onDevicesFound(peripherals: [PeripheralData])
    func onSyncCompleted()
    func onConnectionFailed()
    func onServiceFound()// 장비에 필요한 서비스/캐랙터리스틱을 모두 찾음. 그냥 연결만하면 서비스 접근시 크래시
    func onSysCmdResponse(data: Data)
    func onSyncProgress(progress: Int)
    func onReadBattery(percent: Int)
    func onDfuTargFound(peripheral: CBPeripheral)
}

class DeviceManager: NSObject {
    // Declare class instance property
    public static let shared = DeviceManager()
     // Declare an initializer
     // Because this class is singleton only one instance of this class can be created

    public static let KEY_DEVICE = String("device") // NSString* KEY_DEVICE = @"device";
    public static let KEY_NAME = String("name")     // NSString* KEY_NAME = @"name";
    public static let KEY_DICTIONARY = String("device_dictionary")// NSString* KEY_DICTIONARY = @"device_dictionary";
    
    // queue 예약작업 명령들
    public static let COMMAND_FACTORY_RESET = String("factory_reset")
    public static let COMMAND_BATTERY = String("battery")

    var delegate: DeviceManagerDelegate?
//    var delegate: id // @property (strong, nonatomic) id delegate;
    var commandQueue: [String] = [String]()// 연결 후 실행할 명령 큐 // @property (strong, nonatomic) NSMutableArray *commandQueue;
//    var foundDevices: NSMutableArray? // @property (strong, nonatomic) NSMutableArray *foundDevices;
//    var foundDevices: Array<Any>
    var foundDevices: [PeripheralData] = [PeripheralData]()
// ////////foundDevices: Array or NSMutableArray??????????????????????????

    var peripheral: CBPeripheral?                    // @property (strong, nonatomic) CBPeripheral * _Nullable peripheral;
    var manager: CBCentralManager?                   // @property (strong, nonatomic) CBCentralManager *manager;
    var syncControlCharacteristic: CBCharacteristic? // @property (strong, nonatomic) CBCharacteristic *syncControlCharacteristic;
    var syncDataCharacteristic: CBCharacteristic?    // @property (strong, nonatomic) CBCharacteristic *syncDataCharacteristic;
    var sysCmdCharacteristic: CBCharacteristic?      // @property (strong, nonatomic) CBCharacteristic *sysCmdCharacteristic;
    var batteryCharacteristic: CBCharacteristic?     // @property (strong, nonatomic) CBCharacteristic *batteryCharacteristic;
    var firmwareVersion: String = ""                 // @property (strong, nonatomic) NSString *firmwareVersion;
    private var _batteryLevel: Int = -1              // @property (nonatomic) int batteryLevel; // in percent (0~100)
    public var batteryLevel: Int {                   // batteryLevel : { [0, 100] : normal state } + {-1 : initial state(not set)}
        get {
            return self._batteryLevel
        }
        set(newLevel) {
//            if(newLevel == -1) {
//                print("Set batteryLevl to \(newLevel) as an initial value!")
//            }
            guard (newLevel > -1 && newLevel < 101) else {
                print("batteryLevel should be 0 to 100, input : \(newLevel)")
                return
            }
            self._batteryLevel = newLevel
        }
    }

    var maxRSSI : Int32 = 0
    
    private var _isConnected : Bool = false
    private var _isSyncServiceFound : Bool = false
    private var _isRequiredServicesFound : Bool  = false// 필요 서비스들 모두 찾았는가?
    private var _isScanningDfuTarg : Bool = false
    // https://medium.com/ios-development-with-swift/%ED%94%84%EB%A1%9C%ED%8D%BC%ED%8B%B0-get-set-didset-willset-in-ios-a8f2d4da5514 참고: Getter & Setter
    public var isConnected: Bool {
        get {
            return self._isConnected
        }
        set(isConnected) {
            self._isConnected = isConnected
        }
    }
    public var isSyncServiceFound: Bool {
        get {
            return self._isSyncServiceFound
        }
        set(isSyncServiceFound) {
            self._isSyncServiceFound = isSyncServiceFound
        }
    }
    public var isRequiredServicesFound: Bool {
        get {
            return self._isRequiredServicesFound
        }
        set(isRequiredServicesFound) {
            self._isRequiredServicesFound = isRequiredServicesFound
        }
    }
    public var isScanningDfuTarg: Bool {
        get {
            return self._isScanningDfuTarg
        }
        set(isScanningDfuTarg) {
            self._isScanningDfuTarg = isScanningDfuTarg
        }
    }

    public var syncData: Data
    public var syncDataCount: Int// KittyDoc 기기로부터 받은 KittyDoc_Ext_Interface_Data_Type 데이터 수
    public var totalSyncBytes: Int// 동기화할 전체 바이트수
    public var totalSyncBytesLeft: Int// 앞으로 동기화할 남은 바이트수
//    public var syncData: Data = Data()
//    public var syncDataCount: Int = 0// KittyDoc 기기로부터 받은 KittyDoc_Ext_Interface_Data_Type 데이터 수
//    public var totalSyncBytes: Int = 0// 동기화할 전체 바이트수
//    public var totalSyncBytesLeft: Int = 0// 앞으로 동기화할 남은 바이트수
    // 21.01.31 totalSyncBytes => totalSyncBytesLeft 용도 변경?

//    @implementation DeviceManager
//    {
//        long maxRSSI;
//        BOOL isConnected;
//        BOOL isSyncServiceFound;
//        BOOL isRequiredServicesFound; // 필요 서비스들 모두 찾아서 준비가 다 됐는지
//        NSMutableData *syncData;
//        UInt32 totalSyncBytes;  // 동기화할 전체 바이트수
//        BOOL isScanningDfuTarg;
//    }

//    static DeviceManager *_sharedInstance = nil;
//    static dispatch_once_t pred; // delegate method 중복호출 방지
    
    private override init() {
//        super.init()
        print("DeviceManager.init()")
        
        self.delegate = nil

        self.maxRSSI = 0

        self._isConnected = false
        self._isSyncServiceFound = false
        self._isRequiredServicesFound = false
        self._isScanningDfuTarg = false

        self.syncData = Data()
        self.syncDataCount = 0
        self.totalSyncBytes = 0
        self.totalSyncBytesLeft = 0

        self.syncControlCharacteristic = nil
        self.syncDataCharacteristic = nil
        
        self.commandQueue.removeAll()
        self.foundDevices.removeAll()

        self.peripheral = nil
        self.manager = nil
        self.syncControlCharacteristic = nil
        self.syncDataCharacteristic = nil
        self.sysCmdCharacteristic = nil
        self.batteryCharacteristic = nil
        self.firmwareVersion = String("") // 빈 문자열로 정의?
        self._batteryLevel = -1
    }
    
    func resetCharacteristics() {
        self.syncControlCharacteristic = nil
        self.syncDataCharacteristic = nil
        self.sysCmdCharacteristic = nil
        self.batteryCharacteristic = nil
    }
    
    func removeDevices() { // 앱에서 장비를 지움
        self.disconnect()
        self.removePeripheral()
        self.resetCharacteristics()
        self.foundDevices.removeAll() // self.foundDevices?.removeAllObjects()
    }
    
    func disconnect() { // 연결만 끊음
        self.isRequiredServicesFound = false
        self.isConnected = false
        
        if (self.peripheral != nil && self.manager != nil) {
            self.manager!.cancelPeripheralConnection(self.peripheral!)
            // Value of optional type 'CBPeripheral?' must be unwrapped to a value of type 'CBPeripheral'

            // 연결 끊으면 해당 기기 자동연결하지 않도록
            self.removePeripheral()
        }
    }
    
    func getSavedDeviceName() -> String {
        let dict: Dictionary = UserDefaults.standard.dictionary(forKey: DeviceManager.KEY_DICTIONARY)!
        return dict[DeviceManager.KEY_NAME] as! String
    }

    func savedDeviceInfo() -> Dictionary<String, Any> {
        let dict: Dictionary = UserDefaults.standard.dictionary(forKey: DeviceManager.KEY_DICTIONARY)! //string(forKey: DeviceManager.KEY_DICTIONARY)
        return dict
    }

    func connectPeripheral() {
        print("[+]connectPeripheral()")
        self.isRequiredServicesFound = false
        
        //pred = 0// static dispatch_once_t pred; // delegate method 중복호출 방지
        self.resetCharacteristics()
        guard (self.peripheral != nil && self.manager != nil) else {
            print("self.peripheral == nil || self.manager == nil!(connectPeripheral)")
            guard self.delegate?.onConnectionFailed() != nil else {
                print("self.delegate?.onConnectionFailed() == nil!(connectPeripheral)")
                return
            }
            return
        }
        self.manager!.connect(self.peripheral!, options: nil)
        print("[-]connectPeripheral()")
    }

    func removePeripheral() {
        self.isRequiredServicesFound = false
        
        self.peripheral = nil
        self.resetCharacteristics()
        self.foundDevices.removeAll() // self.foundDevices?.removeAllObjects()
        
        UserDefaults.standard.removeObject(forKey: DeviceManager.KEY_DICTIONARY)
        UserDefaults.standard.synchronize()

    }

    func savedDeviceUUIDString() -> String? {
//        return nil// bingo에서는 안쓴다 => 요건 서버에서 수정하기 전까지 막아둠 ??
        let dict: Dictionary? = UserDefaults.standard.dictionary(forKey: DeviceManager.KEY_DICTIONARY)
        guard (dict != nil) else {
            print("\(DeviceManager.KEY_DICTIONARY) does not exist!")
            return nil
        }
        
        let uuid: String? = dict![DeviceManager.KEY_DEVICE] as? String
        return uuid
    }

    func setSavedDeviceUUIDString(uuid: String) {
        var dict: Dictionary = Dictionary<String, Any>()
        
        dict[DeviceManager.KEY_DEVICE] = uuid
        dict[DeviceManager.KEY_NAME] = "kittydoc"// puppydoc
        
        UserDefaults.standard.setValue(dict, forKey: DeviceManager.KEY_DICTIONARY)
    }
    
    func connectPeripheral(uuid: String, name: String) { // 지정한 UUID의 장비로 연결
        var dict: Dictionary = Dictionary<String, Any>()

        dict[DeviceManager.KEY_DEVICE] = uuid
        dict[DeviceManager.KEY_NAME] = name
        UserDefaults.standard.setValue(dict, forKey: DeviceManager.KEY_DICTIONARY)
        
        self.reestablishConnection()
    }
    
    func reestablishConnection() { // 저장된 장비에 다시 연결
        self.isRequiredServicesFound = false
        
        //pred = 0// static dispatch_once_t pred; // delegate method 중복호출 방지
        self.resetCharacteristics()
//        let centralQueue: DispatchQueue = DispatchQueue(label: "devicemanager")
//        self.manager = CBCentralManager(delegate: self, queue: centralQueue)
        self.manager = CBCentralManager(delegate: self, queue: nil)//DispatchQueue.main
    }

    func scanPeripheral() { // KittyDoc 서비스를 가진 장비를 스캔
        print("[+]scanPeripheral()")
        // 기존 장비 지우기
        self.removePeripheral()
        self.resetCharacteristics()
        self.foundDevices.removeAll()
        
        let centralQueue: DispatchQueue = DispatchQueue(label: "devicemanager")
        self.manager = CBCentralManager(delegate: self, queue: centralQueue)
//        self.manager = CBCentralManager(delegate: self, queue: nil)
        
        DispatchQueue.background(delay: 11.0, background: nil) {// Stop scanning after deadine
            print("DispatchQueue.main.asyncAfter(deadline: .now() + 11)")
            self.manager?.stopScan()
            if (!self.isConnected || !self.isRequiredServicesFound) {
                if (self.foundDevices.count == 0) {
                    guard self.delegate?.onDeviceNotFound() != nil else {
                        print("self.delegate?.onDeviceNotFound() == nil!(scanPeripheral)")
                        return
                    }
                } else {
                   // bingo : sleepdoc 장비는 검색되지 않게
                    var kittydocDevices: Array = Array<PeripheralData>()
                    for p in self.foundDevices {
                        if p.peripheral != nil {
//                            if(p.peripheral!.name?.lowercased() != String("sleepdoc")) {
                                print("kittydocDevices.append(p)")
                                kittydocDevices.append(p)
//                            }
                        }
                    }

                    self.foundDevices.removeAll()
                    self.foundDevices.append(contentsOf: kittydocDevices) // [self.foundDevices addObjectsFromArray:puppydocDevices];
                    self.foundDevices.sort { (obj1: PeripheralData, obj2: PeripheralData) -> Bool in
//                        return obj1.rssi < obj2.rssi // 신호 약한 것이 앞으로...
                        return obj1.rssi > obj2.rssi // 신호 강한 것이 앞으로...
                    }
                    // Sort 결과 확인
                    //print("kittydocDevices : \(kittydocDevices)")
                    print("foundDevices : \(self.foundDevices)")
                    guard self.delegate?.onDevicesFound(peripherals: self.foundDevices) != nil else {
                        print("self.delegate?.onDevicesFound(:) == nil!(scanPeripheral)")
                        return
                    }
                }
            }
        }
        print("[-]scanPeripheral()")
    }

    func setRTC() { // set RTC
        print("[+]setRTC")
        guard (self.peripheral != nil && self.sysCmdCharacteristic != nil) else {
            print("self.peripheral == nil || self.sysCmdCharacteristic is nil!")
            return
        }

        print("Setting RTC...")
        let now: Date = Date()
        let unixTime: UInt32 = UInt32(now.timeIntervalSince1970)
        let GMTOffset: Int32 = Int32(TimeZone.current.secondsFromGMT())
        print("unixTime : \(unixTime)")
        print("GMTOffset : \(GMTOffset), secondsFromGMT : \(TimeZone.current.secondsFromGMT())")

        var bytes: [UInt8] = [SyncCmd.SYSCMD_SET_RTC, ]
        let unixTimeInBytes = withUnsafeBytes(of: unixTime.littleEndian) {
            Array($0)
        }
        print("unixTime : \(unixTime)")
        print("unixTimeInBytes : \(unixTimeInBytes)")
        bytes.append(contentsOf: unixTimeInBytes)
        let gmtOffsetInBytes = withUnsafeBytes(of: GMTOffset.littleEndian) {
            Array($0)
        }
        print("GMTOffset : \(GMTOffset)")
        print("gmtOffsetInBytes : \(gmtOffsetInBytes)")
        bytes.append(contentsOf: gmtOffsetInBytes)
        
        print("bytes.count : \(bytes.count)")
        guard bytes.count == 9 else {
            print("bytes.count != 9!")
            return
        }
        self.peripheral!.writeValue(Data(bytes), for: self.sysCmdCharacteristic!, type: .withResponse)
        
        print("[-]setRTC")
    }
    
    func getUUID() { // get UUID
        guard (self.peripheral != nil) else {
            print("self.peripheral is nil!")
            return
        }
        guard (self.sysCmdCharacteristic != nil) else {
            print("self.sysCmdCharacteristic is nil!")
            return
        }

        print("Getting UUID...")
        self.peripheral!.setNotifyValue(true, for: self.sysCmdCharacteristic!)
        self.peripheral!.writeValue(Data([SyncCmd.SYSCMD_GET_UUID]), for: self.sysCmdCharacteristic!, type: .withResponse)
    }
    
    func getBattery() {
        guard (self.peripheral != nil) else {
            print("self.peripheral is nil!")
            return
        }
        guard (self.batteryCharacteristic != nil) else {
            print("self.batteryCharacteristic is nil!")
            return
        }
        
        //print("Getting Battery Level...")
        self.peripheral!.readValue(for: self.batteryCharacteristic!)
    }
    
    func setUUID(uuid: CBUUID) {
        guard (self.peripheral != nil) else {
            print("self.peripheral is nil!")
            return
        }
        guard (self.sysCmdCharacteristic != nil) else {
            print("self.sysCmdCharacteristic is nil!")
            return
        }

        print("Writing UUID \(uuid.uuidString), count : \(uuid.uuidString.count)")
        let uuidString = UUID(uuidString: uuid.uuidString)
        print("Converted uuidString : \(String(describing: uuidString))")
        let uuidData = uuid.data
        print("uuidData : \(uuidData)")

        var bytes: [UInt8] = [SyncCmd.SYSCMD_SET_UUID, ] // 총 길이 17이어야 함!
//        uuid.getUUIDBytes
        let uuidInBytes = withUnsafeBytes(of: uuid) {
            Array($0)
        }
        
        print(uuidInBytes, "uuidInBytes.count : \(uuidInBytes.count)")
        bytes.append(contentsOf: uuidInBytes) // 16 Bytes 인지 확인!
        self.peripheral!.writeValue(Data(uuidInBytes), for: self.sysCmdCharacteristic!, type: .withResponse)
    }

    func searchSyncRequiredCharacteristics(service: CBService) {
        print("[+] searchSyncRequiredCharacteristics()")

        self.syncControlCharacteristic = nil
        self.syncDataCharacteristic = nil
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Found characteristic \(characteristic.uuid)")
                if characteristic.uuid.isEqual(PeripheralUUID.SYNC_CONTROL_CHAR_UUID) {
                    print("Sync control characteristic found")
                    self.syncControlCharacteristic = characteristic
                }
                if characteristic.uuid.isEqual(PeripheralUUID.SYNC_DATA_CHAR_UUID) {
                    print("Sync data characteristic found")
                    self.syncDataCharacteristic = characteristic
                }
            }
        }
    }
    
    func scanDfuTarget() {
        guard self.manager != nil else {
            print("self.manager == nil!(scanDfuTarget)")
            return
        }
        
        self.isScanningDfuTarg = true
        self.manager!.delegate = self
        self.manager!.scanForPeripherals(withServices: [KittyDocUtility.dfuServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])// options에 nil을 줄 경우 모든 BLE 기기를 탐색한다.
    }
    
    func doFactoryReset() {
        guard self.peripheral != nil else {
            print("self.peripheral == nil!(doFactoryReset)")
            return
        }
        guard self.sysCmdCharacteristic != nil else {
            print("self.sysCmdCharacteristic == nil!(doFactoryReset)")
            return
        }

        self.peripheral!.writeValue(Data([SyncCmd.FACTORY_RESET_CMD]), for: self.sysCmdCharacteristic!, type: .withResponse)

    }
    
    func reserveCommand(command: String) {
        self.commandQueue.append(command)
    }

    func performQueueCommands() { // queue에 저장된 명령 실행
        let queueCopy: [String] = self.commandQueue//Array(self.commandQueue)
        for cmd: String in queueCopy {
            if cmd == DeviceManager.COMMAND_FACTORY_RESET {
                self.doFactoryReset()
            } else if cmd == DeviceManager.COMMAND_BATTERY {
                self.getBattery()
            }
            self.commandQueue.remove(at: 0)
        }
    }

}
