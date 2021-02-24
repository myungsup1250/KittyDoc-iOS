//
//  DeviceManager.swift
//  KittyDocBLETest
//
//  Created by 곽명섭 on 2021/01/03.
//  Copyright © 2020 Myungsup. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol DeviceManagerDelegate {
    func onDeviceNotFound()
    func onDeviceConnected(peripheral: CBPeripheral) // 기기 연결됨
    func onDeviceDisconnected()
    
//    @optional
    func onBluetoothNotAccessible() // BLE Off or No Permission... etc.
    func onDevicesFound(peripherals: [PeripheralData])
    func onConnectionFailed()
    func onServiceFound()// 장비에 필요한 서비스/캐랙터리스틱을 모두 찾음. 그냥 연결만하면 서비스 접근시 크래시
    func onDfuTargFound(peripheral: CBPeripheral)
}
protocol DeviceManagerSecondDelegate {
    func onSysCmdResponse(data: Data)
    func onSyncProgress(progress: Int)
    func onReadBattery(percent: Int)
    func onSyncCompleted()
}

class DeviceManager: NSObject {
    // Declare class instance property
    public static let shared = DeviceManager()

    public static let KEY_DEVICE = String("device") // NSString* KEY_DEVICE = @"device";
    public static let KEY_NAME = String("name")     // NSString* KEY_NAME = @"name";
    public static let KEY_DICTIONARY = String("device_dictionary")// NSString* KEY_DICTIONARY = @"device_dictionary";
    
    // queue 예약작업 명령들
    public static let COMMAND_FACTORY_RESET = String("factory_reset")
    public static let COMMAND_BATTERY = String("battery")

    var delegate: DeviceManagerDelegate?
    var secondDelegate: DeviceManagerSecondDelegate?
    var commandQueue: [String]// 연결 후 실행할 명령 큐 // @property (strong, nonatomic) NSMutableArray *commandQueue;
    var foundDevices: [PeripheralData]
    
    var peripheral: CBPeripheral?
    var manager: CBCentralManager?
    var syncControlCharacteristic: CBCharacteristic?
    var syncDataCharacteristic: CBCharacteristic?
    var sysCmdCharacteristic: CBCharacteristic?
    var batteryCharacteristic: CBCharacteristic?
    var firmwareVersion: String
    private var _batteryLevel: Int
    public var batteryLevel: Int { // batteryLevel : { [0, 100] : normal state } + {-1 : initial state(not set)}
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
    var curRSSI: Int
    var maxRSSI: Int32
    private var _isConnected: Bool
    private var _isSyncServiceFound: Bool
    private var _isRequiredServicesFound: Bool// 필요 서비스들 모두 찾았는가?
    private var _isScanningDfuTarg: Bool
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
    // 21.01.31 totalSyncBytes => totalSyncBytesLeft 용도 변경?

    private override init() {
        print("DeviceManager.init()")
        
        delegate = nil
        secondDelegate = nil
        commandQueue = [String]()// 연결 후 실행할 명령 큐
        foundDevices = [PeripheralData]()
            
        peripheral = nil
        manager = nil
        syncControlCharacteristic = nil
        syncDataCharacteristic = nil
        sysCmdCharacteristic = nil
        batteryCharacteristic = nil
        firmwareVersion = ""
        
        _batteryLevel = -1
        //batteryLevel = 100
        curRSSI = 0
        maxRSSI = 0
        
        _isConnected = false
        _isSyncServiceFound = false
        _isRequiredServicesFound = false// 필요 서비스들 모두 찾았는가?
        _isScanningDfuTarg = false
        //isConnected
        //isSyncServiceFound
        //isRequiredServicesFound
        //isScanningDfuTarg
        
        syncData = Data()
        syncDataCount = 0
        totalSyncBytes = 0
        totalSyncBytesLeft = 0
    }
}

extension DeviceManager {
    func resetCharacteristics() {
        syncControlCharacteristic = nil
        syncDataCharacteristic = nil
        sysCmdCharacteristic = nil
        batteryCharacteristic = nil
    }
    
    func removeDevices() { // 앱에서 장비를 지움
        disconnect()
        removePeripheral()
        resetCharacteristics()
        foundDevices.removeAll() // self.foundDevices?.removeAllObjects()
    }
    
    func disconnect() { // 연결만 끊음
        isRequiredServicesFound = false
        isConnected = false
        
        if (self.peripheral != nil && self.manager != nil) {
            self.manager!.cancelPeripheralConnection(self.peripheral!)

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
        print("removePeripheral()")
        self.isRequiredServicesFound = false
        self.peripheral = nil
        self.resetCharacteristics()
        self.foundDevices.removeAll()
        
        UserDefaults.standard.removeObject(forKey: DeviceManager.KEY_DICTIONARY)
        UserDefaults.standard.synchronize()
    }

    func savedDeviceUUIDString() -> String? {
        print("savedDeviceUUIDString()", terminator: " ")
        let dict = UserDefaults.standard.dictionary(forKey: DeviceManager.KEY_DICTIONARY)
        guard dict != nil else {
            print("\(DeviceManager.KEY_DICTIONARY) does not exist!")
            return nil
        }
        
        let uuid: String? = dict![DeviceManager.KEY_DEVICE] as? String
        print("will return uuid(\(uuid!)")
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
        print("reestablishConnection()")
        self.isRequiredServicesFound = false
        
        //pred = 0// static dispatch_once_t pred; // delegate method 중복호출 방지
        self.resetCharacteristics()
        let centralQueue: DispatchQueue = DispatchQueue(label: "devicemanager")
        self.manager = CBCentralManager(delegate: self, queue: centralQueue)
//        self.manager = CBCentralManager(delegate: self, queue: nil)//DispatchQueue.main
    }

    func scanPeripheral() { // KittyDoc 서비스를 가진 장비를 스캔
        //print("[+]scanPeripheral()")
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
//                            if(p.peripheral!.name?.lowercased() != String("sleepdoc")) {// whosecat?
                                kittydocDevices.append(p)
//                            }
                        }
                    }

                    self.foundDevices.removeAll()
                    self.foundDevices.append(contentsOf: kittydocDevices) // [self.foundDevices addObjectsFromArray:puppydocDevices];
                    self.foundDevices.sort { (obj1: PeripheralData, obj2: PeripheralData) -> Bool in
                        return obj1.rssi > obj2.rssi // 신호 강한 것이 앞으로...
                    }
                    //print("foundDevices : \(self.foundDevices)")
                    guard self.delegate?.onDevicesFound(peripherals: self.foundDevices) != nil else {
                        print("self.delegate?.onDevicesFound(:) == nil!(scanPeripheral)")
                        return
                    }
                }
            }
        }
        //print("[-]scanPeripheral()")
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
        print("unixTime : \(unixTime), GMTOffset : \(GMTOffset)")//, secondsFromGMT : \(TimeZone.current.secondsFromGMT())")

        var bytes: [UInt8] = [SyncCmd.SYSCMD_SET_RTC, ]
        let unixTimeInBytes = withUnsafeBytes(of: unixTime.littleEndian) {
            Array($0)
        }
        print("unixTimeInBytes : \(unixTimeInBytes)")
        bytes.append(contentsOf: unixTimeInBytes)
        let gmtOffsetInBytes = withUnsafeBytes(of: GMTOffset.littleEndian) {
            Array($0)
        }
        print("gmtOffsetInBytes : \(gmtOffsetInBytes)")
        bytes.append(contentsOf: gmtOffsetInBytes)
        
        print("bytes.count : \(bytes.count), ", terminator: "")
        guard bytes.count == 9 else {
            print("bytes.count ins't 9!")
            return
        }
        print("bytes : \(bytes)")
        self.peripheral!.writeValue(Data(bytes), for: self.sysCmdCharacteristic!, type: .withResponse)
        
        print("[-]setRTC")
    }
    
    func getUUID() { // get UUID
        print("[+]getUUID()")
        guard (self.peripheral != nil && self.sysCmdCharacteristic != nil) else {
            print("self.peripheral is nil || self.sysCmdCharacteristic is nil!")
            return
        }

        print("Getting UUID...")
        self.peripheral!.setNotifyValue(true, for: self.sysCmdCharacteristic!)
        self.peripheral!.writeValue(Data([SyncCmd.SYSCMD_GET_UUID]), for: self.sysCmdCharacteristic!, type: .withResponse)
        print("[-]getUUID()")
    }
    
    func setUUID(uuid: CBUUID) {
        print("[+]setUUID()")
        guard (self.peripheral != nil && self.sysCmdCharacteristic != nil) else {
            print("self.peripheral is nil || self.sysCmdCharacteristic is nil!")
            return
        }

        print("Writing UUID... [\(uuid)]")
        
        var bytes: [UInt8] = [SyncCmd.SYSCMD_SET_UUID, ] // 총 길이 17이어야 함!
        
        print("uuid : ", terminator: "")
        for i in 0..<uuid.UUIDValue!.bytes.count {//uuid.data.count
            print("\(uuid.UUIDValue!.bytes[i]) ", terminator: "")//uuid.data[i]
        }
        print("")
        
        var temp = Data()
        temp.append(uuid.data)//temp.append(contentsOf: uuid!.UUIDValue!.bytes)
        print("Regenerated UUID : \(CBUUID(data: temp))")

        bytes.append(contentsOf: uuid.data) // 16 Bytes 인지 확인!
        print("bytes.count : \(bytes.count)")
        self.peripheral!.writeValue(Data(bytes), for: self.sysCmdCharacteristic!, type: .withResponse)
        print("[-]setUUID()")
    }
    
    func getBattery() {
        guard (self.peripheral != nil && self.batteryCharacteristic != nil) else {
            print("self.peripheral is nil || self.batteryCharacteristic is nil!")
            return
        }
        
        //print("Getting Battery Level...")
        self.peripheral!.readValue(for: self.batteryCharacteristic!)
    }

    func searchSyncRequiredCharacteristics(service: CBService) {
        print("[+]searchSyncRequiredCharacteristics()")
        self.syncControlCharacteristic = nil
        self.syncDataCharacteristic = nil
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Found characteristic \(characteristic.uuid)")
                print("")
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
        print("[-]searchSyncRequiredCharacteristics()")
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
