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
    func onServiceFound()// 장비에 필요한 서비스/캐랙터리스틱을 모두 찾았음
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

    public static let KEY_DEVICE = String("device")
    public static let KEY_NAME = String("name")
    public static let KEY_DICTIONARY = String("device_dictionary")
    
    // queue 예약작업 명령들
    public static let COMMAND_FACTORY_RESET = String("factory_reset")
    public static let COMMAND_BATTERY = String("battery")

    var delegate: DeviceManagerDelegate?
    var secondDelegate: DeviceManagerSecondDelegate?
    var commandQueue: [String]// 연결 후 실행할 명령 큐
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
    public var syncDataCount: Int// WhoseCat 기기로부터 받은 WhoseCat_Ext_Interface_Data_Type 데이터 수
    public var totalSyncBytes: Int// 동기화할 전체 바이트수
    public var totalSyncBytesLeft: Int// 앞으로 동기화할 남은 바이트수

    private override init() {
        //print("DeviceManager.init()")
        
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
        _isRequiredServicesFound = false
        _isScanningDfuTarg = false
        
        syncData = Data()
        syncDataCount = 0
        totalSyncBytes = 0
        totalSyncBytesLeft = 0
    }
}

extension DeviceManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //print("[+] centralManagerDidUpdateState()")
        switch central.state {
        case .unknown:
            //print("central.state is .unknown")
            fallthrough
        case .resetting:
            //print("central.state is .resetting")
            fallthrough
        case .unsupported:
            //print("central.state is .unsupported")
            fallthrough
        case .unauthorized:
            //print("central.state is .unauthorised")
            fallthrough
        case .poweredOff:
            //print("central.state is .poweredOff")
            // 연결할 수 없음
            print("central.state is .poweredOn, DeviceManager will scan IoT Device")
            guard self.delegate?.onBluetoothNotAccessible() != nil else {
                print("self.delegate?.onBluetoothNotAccessible() == nil!(centralManagerDidUpdateState)")
                return
            }
        case .poweredOn:
            print("central.state is .poweredOn, DeviceManager will scan IoT Device")
            // User Defaults에 저장된게 있으면 다시 연결
            if let savedDeviceUUID = self.savedDeviceUUIDString() {
                print("deviceManager.savedDeviceUUIDString() != nil")
                var peripherals = [CBPeripheral]()
                let uuid: CBUUID? = CBUUID(string: savedDeviceUUID)
                //let uuidTest: UUID? = UUID(uuidString: self.savedDeviceUUIDString() ?? "")
                // 안드 mac 형식이면 nil 이 된다?
                
                if uuid != nil {
                    peripherals = central.retrievePeripherals(withIdentifiers: [uuid!.UUIDValue!])
                    //peripherals = central.retrievePeripherals(withIdentifiers: [uuidTest!])
                    //print("peripherals : \(peripherals)")
                }
                
                if peripherals.count > 0 {
                    self.peripheral = peripherals[0]
                    self.peripheral!.delegate = self
                    central.connect(self.peripheral!, options: nil)

                    // 장비연결 안되는 경우 대비. 10초 내로 필요 서비스를 다 찾으면 아무것도 안하고 못찾은 상태라면 타임아웃 처리.
                    DispatchQueue.background(delay: 5.0, background: nil) {
                        print("DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5)")
                        if (!self.isConnected || !self.isRequiredServicesFound) {
                            print("Timeout. Cancel connection.")
                            if self.peripheral != nil {
                                central.cancelPeripheralConnection(self.peripheral!)
                            }
                           // 연결 실패 메시지 보여주기... 실패 팝업?
                            guard self.delegate?.onConnectionFailed() != nil else {
                                print("self.delegate?.onConnectionFailed() == nil!(centralManagerDidUpdateState1)")
                                return
                            }
                        }
                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//
//                    }
                } else {
                    // 연결할 수 있는 장비가 없음
                    guard self.delegate?.onConnectionFailed() != nil else {
                        print("self.delegate?.onConnectionFailed() == nil!(centralManagerDidUpdateState2)")
                        return
                    }
                }
            } else { // deviceManager.savedDeviceUUIDString() == nil
                print("deviceManager.savedDeviceUUIDString() == nil")
                self.maxRSSI = -100
                self.peripheral = nil
                guard self.manager == central else {
                    print("self.manager != central!(centralManagerDidUpdateState)")
                    return
                }
                
                //central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
                central.scanForPeripherals(withServices: [PeripheralUUID.SYNC_SERVICE_UUID, PeripheralUUID.GENERAL_SERVICE_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])// options에 nil을 줄 경우 모든 BLE 기기를 탐색한다.
                DispatchQueue.background(delay: 10.0, background: nil) { // 10초 동안 KittyDoc 기기를 검색. 못찾은 상태라면 타임아웃 처리.
                    print("DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 10)")
                    if (!self.isConnected || !self.isRequiredServicesFound) {
                        self.manager?.stopScan()
                        if self.foundDevices.isEmpty {
                            print("No Devices Found!")
                            // No devices 메시지
                            guard self.delegate?.onConnectionFailed() != nil else {
                                print("self.delegate?.onConnectionFailed() == nil!(centralManagerDidUpdateState3)")
                                return
                            }
                        } else {
                            print("Found some KittyDoc Devices!")
                            print("foundDevices : \(self.foundDevices)")
                        }
                    }
                }
            }
        @unknown default:
            fatalError("Fatal Error in KittyDoc Device!")
        }
        //print("[-] centralManagerDidUpdateState()")
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print("[+] centralManager(didDiscover)")
        
        guard self.manager == central else {
            print("self.manager != central!(didDiscoverPeripheral)")
            return
        }
        //print("didDiscovorPeripheral : \(advertisementData["kCBAdvDataLocalName"] ?? "-"), RSSI : \(RSSI.intValue)")
        //Keys : "kCBAdvDataRxSecondaryPHY", "kCBAdvDataServiceUUIDs", "kCBAdvDataLocalName", "kCBAdvDataRxPrimaryPHY", "kCBAdvDataIsConnectable", "kCBAdvDataTimestamp"

        if isScanningDfuTarg {
            central.stopScan()
            guard self.delegate?.onDfuTargFound(peripheral: peripheral) != nil else {
                print("self.delegate?.onDfuTargFound(:) == nil!(didDiscoverPeripheral)")
                return
            }
            return
        }
        
        var found: Bool = false
        let rssi: Int = RSSI.intValue
        for i in 0..<self.foundDevices.count {
            if (self.foundDevices[i].peripheral!.isEqual(peripheral) && rssi < 0) {
                found = true
                // rssi 업데이트. 가끔 127이라는 엉뚱한 값이 나와서 음수인 경우만 처리? => overflow
                self.foundDevices[i].rssi = self.foundDevices[i].rssi < rssi ? rssi : self.foundDevices[i].rssi
                
                break
            }
        }

        if (!found && rssi < 0) {// not found and rssi < 0
            // add
            var peripheralData = PeripheralData()
            peripheralData.peripheral = peripheral
            peripheralData.rssi = rssi
            self.foundDevices.append(peripheralData)
            print("Adding \(peripheralData.peripheral?.name ?? "Unknown") to foundDevices")
        }
        self.foundDevices.sort { (obj1: PeripheralData, obj2: PeripheralData) -> Bool in
            return obj1.rssi > obj2.rssi // 신호 강한 것이 앞으로...
        }
        //print("[-] centralManager(didDiscover)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[+] centralManager(didConnect)")
        
        // User defaults에 저장
        var dict: Dictionary = Dictionary<String, Any>()
        dict[DeviceManager.KEY_DEVICE] = peripheral.identifier.uuidString
        dict[DeviceManager.KEY_NAME] = peripheral.name
        UserDefaults.standard.setValue(dict, forKey: DeviceManager.KEY_DICTIONARY)
        UserDefaults.standard.synchronize()
        self.isConnected = true
        
        print("Saved device \(dict[DeviceManager.KEY_DEVICE] ?? "-") to UserDefaults!")
        
        if peripheral == self.peripheral {
            print("Connected! \(peripheral)")
            self.peripheral = peripheral;
            self.peripheral!.delegate = self;
            self.peripheral!.discoverServices(nil)
        }
        
        print("[-] centralManager(didConnect)")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("[+] centralManager(didFailToConnect)")
        
        print("Failed to Connect to KittyDoc Device!\n\tError: \(error?.localizedDescription ?? "-")")
        self.isConnected = false
//        pred = 0;
        guard self.delegate?.onConnectionFailed() != nil else {
            print("self.delegate?.onConnectionFailed() == nil!(didFailToConnect)")
            return
        }
        print("[-] centralManager(didFailToConnect)")
    }

    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        print(" [+]centralManager(connectionEventDidOccur)")
        if peripheral == self.peripheral {
            print("Connection event occurred [ \(String(describing: event)) ]")
        }
        print(" [-]centralManager(connectionEventDidOccur)")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("[+] centralManager(didDisconnectPeripheral)")
        
        print("didDisconnectPeripheral error : \(error?.localizedDescription ?? "-")")
        self.isConnected = false
        self.isRequiredServicesFound = false
//        pred = 0;
        // 기존 장비 지우고 -> 장비에서 연결 끊은 경우 지워지면 안됨. 앱에서 끊는 경우에만 지우자.
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
//        self.removePeripheral()
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //

        guard self.delegate?.onDeviceDisconnected() != nil else {
            print("self.delegate?.onDeviceDisconnected() == nil!(didDisconnectPeripheral)")
            return
        }

        print("[-] centralManager(didDisconnectPeripheral)")
    }
}

extension DeviceManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("[+] centralManager(didDiscoverServices)")
                
        guard let services = peripheral.services else {
            print("There is no Service at all!(didDiscoverServices)")
            return
        }
        guard peripheral == self.peripheral else {
            print("peripheral != self.peripheral!(didDiscoverServices)")
            return
        }
        
        //print(peripheral.state) // 1 service exist
        //print("Discovered Services : \(services.count)") // 1 service exist
        for service: CBService in services {
            print("Discovered service : \(service.uuid)")//\(service.uuid.uuidString)")
            if service.uuid.isEqual(PeripheralUUID.SYNC_SERVICE_UUID) {
                //print("Sync Service Found!")
                isSyncServiceFound = true
            }
            // Now kick off discovery of characteristics
            self.peripheral!.discoverCharacteristics(nil, for: service)
        }
        if isSyncServiceFound {
            // Found KittyDoc
            guard self.delegate?.onDeviceConnected(peripheral: peripheral) != nil else {
                print("self.delegate?.onDeviceConnected(:) == nil!(didDiscoverServices)")
                return
            }
        }
        print("[-] centralManager(didDiscoverServices)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        //print("[+] didDiscoverCharacteristicsForService")
        
        guard let characteristics = service.characteristics else {
            print("There is no Characteristic at all!(didDiscoverCharacteristicsFor)")
            return
        }

        if service.uuid.isEqual(PeripheralUUID.SYNC_SERVICE_UUID) { // 0xFFFA
            searchSyncRequiredCharacteristics(service)
        }
        // Searches essential Services & Characteristics
        //print("Found \(characteristics.count) characteristics")
        for characteristic in characteristics {
            //print("\t\(characteristic.uuid) (\(characteristic.uuid.uuidString))")
            // general(main) service
            if service.uuid.isEqual(PeripheralUUID.GENERAL_SERVICE_UUID) && characteristic.uuid.isEqual(PeripheralUUID.SYSCMD_CHAR_UUID) {
                self.sysCmdCharacteristic = characteristic // 0xFFFE, 0xFFFF
            }

            // battery
            if service.uuid.isEqual(PeripheralUUID.BATTERY_SERVICE_UUID) && characteristic.uuid.isEqual(PeripheralUUID.BATTERY_CHAR_UUID) {
                self.batteryCharacteristic = characteristic // 0x180F,0x2A19
            }

            // firmware version
            if service.uuid.isEqual(PeripheralUUID.DEVICE_INFO_SERVICE_UUID) && characteristic.uuid.isEqual(PeripheralUUID.SW_REVISION_CHAR_UUID) { // 0x180A,0x2A28
                print("[+] peripheral.readvalue() <SW_REVISION_CHAR_UUID>")
                guard self.peripheral == peripheral else {
                    print("self.peripheral != peripheral!(didDiscoverCharacteristicsFor)")
                    return
                }
                peripheral.readValue(for: characteristic)

            }
            
            //peripheral.discoverDescriptors(for: characteristic)
        }
        //print("[-] didDiscoverCharacteristicsForService")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("[+]didReadRSSI()")
        self.curRSSI = Int(truncating: RSSI)
        print("[-]didReadRSSI()")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("\n[+] didUpdateValueForCharacteristic peripheral = \(peripheral.identifier.uuidString), \(characteristic.uuid), \(characteristic.value!)")
        
        guard let data = characteristic.value else {
            print("characteristic.value is empty!(didUpdateValueForCharacteristic)")
            return
        }
        let bytes = [UInt8](data)
        
        guard error == nil else {
            print("Error in Notification state: \(String(describing: error))")
            return
       }
        guard bytes.count > 0 else {
            print("char.value is Empty!")
            return
        }
        

        if characteristic.uuid.isEqual(PeripheralUUID.SW_REVISION_CHAR_UUID) {
            // SW Revision
            self.firmwareVersion = String(data: data, encoding: String.Encoding.ascii)!
            print("FirmwareVersion : \(self.firmwareVersion)")
        } else if characteristic.uuid.isEqual(PeripheralUUID.BATTERY_CHAR_UUID) {
            var battery: UInt8 = 0
            if self.batteryCharacteristic != nil {
                battery = UInt8(self.batteryCharacteristic!.value![0])
                //print("battery : \(battery)")
                if bytes.count == 1 {
                    battery = bytes[0]
                    self.batteryLevel = Int(battery)
                    //print("self.batteryLevel is set to \(self.batteryLevel)")
                }
            }
            guard self.secondDelegate?.onReadBattery(percent: Int(battery)) != nil else {
                print("self.delegate?.onReadBattery(:) == nil!(didUpdateValueForCharacteristic)")
                return
            }
        } else if characteristic.uuid.isEqual(PeripheralUUID.SYNC_CONTROL_CHAR_UUID) {
            //print("[+] Sync Control Characteristic value : \(characteristic.value!)")
            
            if bytes[0] == SyncCmd.SYNC_NOTI_READY || bytes[0] == SyncCmd.SYNC_NOTI_NEXT_READY {
                //print("Reading sync data...")// <totalSyncBytesLeft : \(totalSyncBytesLeft)>", terminator: "")
                //self.totalSyncBytesLeft = 0
                //print("After : totalSyncBytesLeft : \(totalSyncBytesLeft)")
                guard (self.peripheral != nil && self.syncDataCharacteristic != nil) else {
                    print("peripheral or syncDataCharacteristic is nil!(didUpdateValueForCharacteristic)")
                    return
                }
                self.peripheral!.readValue(for: self.syncDataCharacteristic!)
            } else if data[0] == SyncCmd.SYNC_NOTI_DONE {
                print(">>> SYNC DONE CHECKED! <<<")
            } else if data[0] == SyncCmd.SYNC_NOTI_ERROR {
                print(">>> ERROR IN SYNC PROCESS! <<<")
            }
        } else if characteristic.uuid.isEqual(PeripheralUUID.SYNC_DATA_CHAR_UUID) {
            //print("[+] Sync Data Characteristic value=\(characteristic.value!)")

            // 길이 필드 값이 0이 될 때까지 다음 패킷을 읽어들인다
            if bytes[0] != 0 {
                let len: Int = Int(bytes[0])
                //print("Data len : \(len), bytes.count : \(bytes.count)") // len 값이 19가 아니라 2이어도, 길이는 19개로 나머지 3~19 칸 데이터를 0으로 채워서 보낸다. 참고
                guard !(len > bytes.count) else { // 있을 수 없는 경우이므로 리턴
                    print("len > bytes.count!(didUpdateValueForCharacteristic)")
                    return
                } // 길이 검사
                
                // data[1] ~ data[19]까지 복사
                syncData.append(contentsOf: data.subdata(in: Range(1...len)))
                //print("syncData : \(syncData.count), totalSyncBytesLeft : \(totalSyncBytesLeft), totalSyncBytes : \(totalSyncBytes)");

                // 진행률 카운트를 위해 sleepdoc_ext_interface_data_type 크기만큼 받아오면 remainings를 가져와서 진행률 계산
                if syncData.count >= 154 { // KittyDoc_Ext_Interface_Data_Type size should be 154...
                    var kittydoc_data: KittyDoc_Ext_Interface_Data_Type // 10분단위가 6개 모이고 위에 타임존, 리셋회수, 남은 개수 데이터가 있는 데이터
                    guard syncData.count >= 154 else {
                        print("syncData.count is less than 154")
                        return
                    }

                    let temp = syncData.subdata(in: 0..<154)
                    kittydoc_data = KittyDoc_Ext_Interface_Data_Type(data: temp)
                    self.syncDataCount += 1
                    if syncData.count == 154 {
                        syncData.removeAll()
                    } else {
                        syncData = syncData.advanced(by: 154) // syncData.dropFirst(154)
                    }

                    //totalSyncBytesLeft -= 154
                    //print("syncData : \(syncData.count), totalSyncBytesLeft : \(totalSyncBytesLeft)")

//                    if (self.totalSyncBytesLeft == 0) {
//                        print("\tif (totalSyncBytesLeft == 0)")
                        self.totalSyncBytesLeft = Int(kittydoc_data.remainings) * 154
                        if self.totalSyncBytes < self.totalSyncBytesLeft {
                            print("if self.totalSyncBytes < self.totalSyncBytesLeft (\(totalSyncBytes) < \(totalSyncBytesLeft))")
                            self.totalSyncBytes = self.totalSyncBytesLeft
                        }
                        // 어디서 계속 self.totalSyncBytesLeft == 0 되는지 확인 필요
                        print(">>> totalSyncBytesLeft : \(self.totalSyncBytesLeft), totalSyncBytes : \(self.totalSyncBytes)");
//                    }

                    // 가끔 totalSyncBytesLeft가 -인 경우가 있다...
                    if( totalSyncBytesLeft < 0 ) { // 동기화 강제종료
                        print(">>> force stopping sync")

                        if self.syncControlCharacteristic != nil {
                            peripheral.writeValue(Data([SyncCmd.SYNC_CONTROL_DONE]), for: self.syncControlCharacteristic!, type: .withResponse)
                            //print("writeValue(0x03) done <SYNC_CONTROL_DONE>")
                        }
                        
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
//                        let helper: SyncHelper = SyncHelper()
//                        helper.parseData(data: syncData)
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //

                        NotificationCenter.default.post(name: .receiveSyncDataDone, object: nil)
                        //현재 HomeViewController, AnalysisViewController에 등록되어있음.
                        
                        // notify to delegate
                        guard self.secondDelegate?.onSyncCompleted() != nil else {
                            print("self.secondDelegate?.onSyncCompleted() == nil!(didUpdateValueForCharacteristic1)")
                            return
                        }
                        return
                    }

                    print("┌-------------------------------------------------------------------------------------------------------------┐")
                    print("|  s_tick  |      s_time       |  e_tick  |      s_time       |steps|  t_lux  |avg_lux|avg_k|vct_x|vct_y|vct_z|")
                    for i in 0...5 {
                        let sensorData = SensorData(_object: kittydoc_data.d[i], _petID: 38, _petLB: PetInfo.shared.petArray.first!.PetLB)
                        let server = KittyDocServer()
                        let sensorResponse = server.sensorSend(data: sensorData)
                        if (sensorResponse.getCode() as! Int == ServerResponse.SENSOR_SUCCESS) {
                            print(sensorResponse.getMessage())
                        } else {
                            print(sensorResponse.getMessage())
                        }

                        let s_time = unixtimeToString(unixtime: time_t(kittydoc_data.d[i].s_tick))
                        let e_time = unixtimeToString(unixtime: time_t(kittydoc_data.d[i].e_tick))
                        print("|\(String(format: "%10d", kittydoc_data.d[i].s_tick))|\(s_time)|", terminator: "")
                        print("\(String(format: "%10d", kittydoc_data.d[i].e_tick))|\(e_time)|", terminator: "")
                        print("\(String(format: "%5d", kittydoc_data.d[i].steps))|", terminator: "")
                        print("\(String(format: "%9d", kittydoc_data.d[i].t_lux))|", terminator: "")
                        print(" \(String(format: "%5d", kittydoc_data.d[i].avg_lux)) |", terminator: "")
                        print("\(String(format: "%5d", kittydoc_data.d[i].avg_k))|", terminator: "")
                        print("\(String(format: "%5d", kittydoc_data.d[i].vector_x))|", terminator: "")
                        print("\(String(format: "%5d", kittydoc_data.d[i].vector_y))|", terminator: "")
                        print("\(String(format: "%5d", kittydoc_data.d[i].vector_z))|")
                    }
                    print("├-------------------------------------------------------------------------------------------------------------┤")

                    // notify to delegate
                    var progress: Int
                    if totalSyncBytes == 0 {
                        progress = 0
                    } else {
                        progress = Int(Double((self.syncDataCount * 154 * 100) / totalSyncBytes)) // int progress = (int)([syncData length] * 100/totalSyncBytes);
                    }
                    if progress < 0 {
                        progress = 0
                    } else if progress > 100 {
                        progress = 100
                    }
                    print("| remainings : \(String(format: "%8d", kittydoc_data.remainings)), reset_num : \(String(format: "%8d", kittydoc_data.reset_num)), time_zone : \(String(format: "%6d", kittydoc_data.time_zone)), progress : \(String(format: "%3d", progress)) (\(String(format: "%8d", self.syncDataCount * 154)) / \(String(format: "%8d", totalSyncBytes)))       |")
                    print("└-------------------------------------------------------------------------------------------------------------┘")
                    
                    guard self.totalSyncBytes >= 0 && (self.secondDelegate?.onSyncProgress(progress: progress) != nil) else {
                        print("self.secondDelegate?.onSyncProgress(:) == nil || totalSyncBytes < 0!(didUpdateValueForCharacteristic)")
                        return
                    }
                }
                
                if self.syncControlCharacteristic != nil {
                    peripheral.writeValue(Data([SyncCmd.SYNC_CONTROL_PREPARE_NEXT]), for: self.syncControlCharacteristic!, type: .withResponse)
                    //print("writeValue(0x02) done <SYNC_CONTROL_PREPARE_NEXT>")
                }
            } else { // bytes[0] == 0
                // end of sync.
                print(">>> SYNC DONE")
                
                guard self.syncControlCharacteristic != nil else {
                    print("self.syncControlCharacteristic == nil!")
                    return
                }

                peripheral.writeValue(Data([SyncCmd.SYNC_CONTROL_DONE]), for: self.syncControlCharacteristic!, type: .withResponse)
                
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
//                let helper: SyncHelper = SyncHelper()
//                helper.parseData(data: syncData)
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //

                NotificationCenter.default.post(name: .receiveSyncDataDone, object: nil)
                //현재 HomeViewController, AnalysisViewController에 등록되어있음.
                
                // notify to delegate
                guard self.secondDelegate?.onSyncCompleted() != nil else {
                    print("self.secondDelegate?.onSyncCompleted() == nil!(didUpdateValueForCharacteristic2)")
                    return
                }
            }
        } else if characteristic.uuid.isEqual(PeripheralUUID.SYSCMD_CHAR_UUID) {// 17 bytes on respond.
            // getUUID 호출 응답 (17Bytes) 11 218 36 68 179 86 114 75 88 164 51 166 109 100 235 140 4
            // setUUID 호출 응답 (17Bytes) 10 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
            print("\n[+]characteristic.uuid.isEqual(PeripheralUUID.SYSCMD_CHAR_UUID)\n")
            // system command 응답 처리
            print("data(count : \(bytes.count)) => ", terminator: "")
            for i in 0..<bytes.count {
                print("\(bytes[i]) ", terminator: "")
                //print("\(String(format: "%c", bytes[i])) ", terminator: "")
            }
            print("")
            
            print("uuid : \(CBUUID(data: data.advanced(by: 1)))")
            guard self.secondDelegate?.onSysCmdResponse(data: data) != nil else {
                print("self.secondDelegate?.onSysCmdResponse(:) == nil!(didUpdateValueForCharacteristic)")
                return
            }
            print("\n[-]characteristic.uuid.isEqual(PeripheralUUID.SYSCMD_CHAR_UUID)\n")
        }
        
        if (self.syncControlCharacteristic != nil && self.syncDataCharacteristic != nil && self.sysCmdCharacteristic != nil && !self.firmwareVersion.isEmpty && !self.isRequiredServicesFound) {
            guard self.delegate?.onServiceFound() != nil else {
                print("self.delegate?.onServiceFound() == nil!(didUpdateValueForCharacteristic)")
                return
            }
            self.isRequiredServicesFound = true
            // 예약작업 실행
            self.performQueueCommands() // [self performQueueCommands];
        }
        //print("[-] didUpdateValueForCharacteristic")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Error in writing to Characteristic \(characteristic.uuid) and Error : \(error?.localizedDescription ?? "-")")
        } else {
            //print("didWriteValueForCharacteristic \(characteristic.uuid) and Value : \(characteristic.value ?? Data())")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristics: CBCharacteristic, error: Error?) {
//        print("[+] didDiscoverDescriptorsForCharacteristic")
//
//        guard let descriptors = characteristics.descriptors else {
//            return
//        }
//
//        print("Found \(descriptors.count) descriptors \(descriptors)")
//        for descriptor in descriptors {
//            if descriptor.characteristic.properties.contains(.write) {
//                peripheral.writeValue(Data([0x01]), for: descriptor)
//                print("writeValue(0x01) done")
//            }
//            if descriptor.characteristic.properties.contains(.writeWithoutResponse) {
//                peripheral.writeValue(Data([0x01]), for: descriptor)
//                print("writeValue(0x01) done")
//            }
//            if descriptor.characteristic.properties.contains(.read) {
//                peripheral.readValue(for: descriptor)
//                print(".readValue() from [ \(descriptor.uuid) ]")
//                print("and the data is [ \(String(describing: descriptor.value)) ]")
//            }
//            if descriptor.characteristic.properties.contains(.notify) {
//                peripheral.setNotifyValue(true, for: characteristics.self)
//            }
//        }
//
//        print("[-] didDiscoverDescriptorsForCharacteristic")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
//        let data = descriptor.value
//
//        print("Update descriptor Raw Data : \(data!)")
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        let data = descriptor.value

        print("Write descriptor Raw Data : \(data!)")
    }

}

extension DeviceManager {// Manage Services, Characteristics, Peripherals
    func resetCharacteristics() {
        syncControlCharacteristic = nil
        syncDataCharacteristic = nil
        sysCmdCharacteristic = nil
        batteryCharacteristic = nil
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

    func connectPeripheral(uuid: String, name: String) { // 지정한 UUID의 장비로 연결
        var dict: Dictionary = Dictionary<String, Any>()

        dict[DeviceManager.KEY_DEVICE] = uuid
        dict[DeviceManager.KEY_NAME] = name
        UserDefaults.standard.setValue(dict, forKey: DeviceManager.KEY_DICTIONARY)
        
        self.reestablishConnection()
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
        //self.manager = CBCentralManager(delegate: self, queue: nil)
        
        DispatchQueue.background(delay: 11.0, background: nil) {// Stop scanning after deadine
            print("DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 11)")
            self.manager?.stopScan()
            if (!self.isConnected || !self.isRequiredServicesFound) {
                if (self.foundDevices.count == 0) {
                    guard self.delegate?.onDeviceNotFound() != nil else {
                        print("self.delegate?.onDeviceNotFound() == nil!(scanPeripheral)")
                        return
                    }
                } else {
                   // sleepdoc, puppydoc 장비는 추가하지 않는다
                    var kittydocDevices: Array = Array<PeripheralData>()
                    for p in self.foundDevices {
                        if p.peripheral != nil {
                            if(p.peripheral!.name?.lowercased() == String("whosecat")) { // kittydoc
                                kittydocDevices.append(p)
                            }
                        }
                    }

                    self.foundDevices.removeAll()
                    self.foundDevices.append(contentsOf: kittydocDevices)
                    self.foundDevices.sort { (obj1: PeripheralData, obj2: PeripheralData) -> Bool in
                        return obj1.rssi > obj2.rssi // 신호 강한 것이 앞으로...
                    }
                    guard self.delegate?.onDevicesFound(peripherals: self.foundDevices) != nil else {
                        print("self.delegate?.onDevicesFound(:) == nil!(scanPeripheral)")
                        return
                    }
                }
            }
        }
        //print("[-]scanPeripheral()")
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
        dict[DeviceManager.KEY_NAME] = "whosecat"// kittydoc
        
        UserDefaults.standard.setValue(dict, forKey: DeviceManager.KEY_DICTIONARY)
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
        print("Regenerated UUID(setUUID) : \(CBUUID(data: temp))")

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

    func searchSyncRequiredCharacteristics(_ service: CBService) {
        //print("[+]searchSyncRequiredCharacteristics()")
        self.syncControlCharacteristic = nil
        self.syncDataCharacteristic = nil
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Found characteristic \(characteristic.uuid)")
                if characteristic.uuid.isEqual(PeripheralUUID.SYNC_CONTROL_CHAR_UUID) {
                    //print("\tSync control characteristic found")
                    self.syncControlCharacteristic = characteristic
                }
                if characteristic.uuid.isEqual(PeripheralUUID.SYNC_DATA_CHAR_UUID) {
                    //print("\tSync data characteristic found")
                    self.syncDataCharacteristic = characteristic
                }
            }
        }
        //print("[-]searchSyncRequiredCharacteristics()")
    }
     
    func startSync() {
        guard (self.syncControlCharacteristic != nil && self.syncDataCharacteristic != nil && self.peripheral != nil) else {
            print("Required sync service not found! or self.peripheral == nil!(startSync)")
            return
        }
        print("\n<<< Start sync... >>>")

        // 기기가 여러대인 경우 대비하여 DB를 싹 지우자
//        CoreDataManager *cdm = [CoreDataManager sharedManager];
//        [cdm resetDB];

        syncData.removeAll()
        self.peripheral!.setNotifyValue(true, for: self.syncControlCharacteristic!)
        self.peripheral!.writeValue(Data([SyncCmd.SYNC_CONTROL_START]), for: self.syncControlCharacteristic!, type: .withResponse)
        //print("writeValue(0x01) done <SYNC_CONTROL_START>")
    }
}
