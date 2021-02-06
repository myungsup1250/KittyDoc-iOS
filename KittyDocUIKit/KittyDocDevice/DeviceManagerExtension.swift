//
//  DeviceManagerExtension.swift
//  KittyDocBLEUIKit
//
//  Created by 곽명섭 on 2021/01/24.
//

import Foundation
import CoreBluetooth

extension DeviceManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("[+] centralManagerDidUpdateState()")
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
            //fallthrough
        case .resetting:
            print("central.state is .resetting")
            //fallthrough
        case .unsupported:
            print("central.state is .unsupported")
            //fallthrough
        case .unauthorized:
            print("central.state is .unauthorised")
            //fallthrough
        case .poweredOff:
            print("central.state is .poweredOff")
            // 연결할 수 없음
            guard self.delegate?.onBluetoothNotAccessible() != nil else {
                print("self.delegate?.onBluetoothNotAccessible() == nil!(centralManagerDidUpdateState)")
                return
            }
        case .poweredOn:
            print("central.state is .poweredOn")
            //print("DeviceManager will scan IoT Device")
            // User Defaults에 저장된게 있으면 다시 연결
            if self.savedDeviceUUIDString() != nil {
                print("deviceManager.savedDeviceUUIDString() != nil")
                let uuid: CBUUID? = CBUUID(string: self.savedDeviceUUIDString() ?? "")
                // 안드 mac 형식이면 nil 이 된다?
                let uuidTest: UUID? = UUID(uuidString: self.savedDeviceUUIDString() ?? "")

                var peripherals = [CBPeripheral]()
                var peripheralsTest = [CBPeripheral]()

                if uuid != nil {
                    peripherals = central.retrievePeripherals(withIdentifiers: [uuid!.UUIDValue!])
                    print("peripherals attempt 1 : \(peripherals)")
                    peripheralsTest = central.retrievePeripherals(withIdentifiers: [uuidTest!])
                    print("peripherals attempt 2 : \(peripheralsTest)")
                }
                if peripherals.count > 0 {
                    self.peripheral = peripherals[0]
                    self.peripheral!.delegate = self
                    central.connect(self.peripheral!, options: nil)

                    // 장비연결 안되는 경우 대비. 20초 내로 필요 서비스를 다 찾으면 아무것도 안하고 못찾은 상태라면 타임아웃 처리.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        print("DispatchQueue.main.asyncAfter(deadline: .now() + 10)")
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
                    print("DispatchQueue.main.asyncAfter(deadline: .now() + 10)")
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
                        }
                    }
                }
            }
        @unknown default:
            fatalError("Fatal Error in KittyDoc Device!")
        }
        print("[-] centralManagerDidUpdateState()")
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print("[+] centralManager(didDiscover)")
        
        guard self.manager == central else {
            print("self.manager != central!(didDiscoverPeripheral)")
            return
        }
        //print("didDiscovorPeripheral : \(advertisementData["kCBAdvDataLocalName"] ?? "-"), RSSI : \(RSSI.intValue)")
        //Keys : "kCBAdvDataRxSecondaryPHY", "kCBAdvDataServiceUUIDs", "kCBAdvDataLocalName", "kCBAdvDataRxPrimaryPHY", "kCBAdvDataIsConnectable", "kCBAdvDataTimestamp"
//        ["kCBAdvDataServiceUUIDs": <__NSArrayM 0x283319530>(Battery, Device Information, FFFA, FFFE),
//         "kCBAdvDataIsConnectable": 1, "kCBAdvDataRxPrimaryPHY": 1, "kCBAdvDataRxSecondaryPHY": 0,
//         "kCBAdvDataLocalName": PuppyDoc, "kCBAdvDataTimestamp": 633509251.352404]

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
            //print("\tfor loop in self.foundDevices")
            if (self.foundDevices[i].peripheral!.isEqual(peripheral) && rssi < 0) {
                //print("\tif (self.foundDevices[i].peripheral!.isEqual(peripheral) && rssi < 0)")
                found = true
                // rssi 업데이트. 가끔 127이라는 엉뚱한 값이 나와서 음수인 경우만 처리? => overflow
                self.foundDevices[i].rssi = self.foundDevices[i].rssi < rssi ? rssi : self.foundDevices[i].rssi
//                if self.foundDevices[i].rssi < rssi {
//                    print("\(self.foundDevices[i].rssi) < \(rssi)")
//                    self.foundDevices[i].rssi = rssi
//                }
                break
            }
        }

        if (!found && rssi < 0) {// not found and rssi < 0
            //print("\tif (!found && rssi < 0)")

            // add
            var peripheralData = PeripheralData()
            peripheralData.peripheral = peripheral
            peripheralData.rssi = rssi
            self.foundDevices.append(peripheralData)
            print("Adding \(peripheralData.peripheral?.name ?? "Unknown") to foundDevices")
        }
        self.foundDevices.sort { (obj1: PeripheralData, obj2: PeripheralData) -> Bool in
            //return obj1.rssi < obj2.rssi // 신호 약한 것이 앞으로...
            return obj1.rssi > obj2.rssi // 신호 강한 것이 앞으로...
        }
        //print("[-] centralManager(didDiscover)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[+] centralManager(didConnect)")
        
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
        // 장비에 다시 연결하면 배터리 경고 초기화
        //KittyDocUtility.clearBatteryWarning() //[Util clearBatteryWarning];
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
        // User defaults에 저장
        var dict: Dictionary = Dictionary<String, Any>()
        dict[DeviceManager.KEY_DEVICE] = peripheral.identifier.uuidString
        dict[DeviceManager.KEY_NAME] = peripheral.name
        UserDefaults.standard.setValue(dict, forKey: DeviceManager.KEY_DICTIONARY)
        UserDefaults.standard.synchronize()
        isConnected = true
        
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
        isConnected = false
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
        isConnected = false
        isRequiredServicesFound = false
//        pred = 0;
        // 기존 장비 지우고 -> 장비에서 연결 끊은 경우 지워지면 안됨. 앱에서 끊는 경우에만 지우자.
//        [self removePeripheral];
        
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
        //print(peripheral.state) // 1 service exist
        //print("Discovered Services : \(services.count)") // 1 service exist
        //print("Service Info :", terminator: " ")//\(services)\n")
        //peripheral.canSendWriteWithoutResponse == true
        //for service in services {
        //    print("<\(service.uuid)>,", terminator: " ")
        //}
        guard peripheral == self.peripheral else {
            print("peripheral != self.peripheral!(didDiscoverServices)")
            return
        }
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
            //@@@
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
    
    func searchSyncRequiredCharacteristics(_ service: CBService) {
        print("[+] searchSyncRequiredCharacteristics()")

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
        print("[-] searchSyncRequiredCharacteristics() DONE")
    }
    
    func startSync() {
        guard (self.syncControlCharacteristic != nil && self.syncDataCharacteristic != nil) else {
            print("Required sync service not found!(startSync)")
            return
        }
        guard self.peripheral != nil else {
            print("self.peripheral == nil!(startSync)")
            return
        }
        print("\n<<< Start sync... >>>")
        
        // 기기가 여러대인 경우 대비하여 DB를 싹 지우자
//        CoreDataManager *cdm = [CoreDataManager sharedManager];
//        [cdm resetDB];
        
        syncData = Data()
        self.peripheral!.setNotifyValue(true, for: self.syncControlCharacteristic!)
        self.peripheral!.writeValue(Data([SyncCmd.SYNC_CONTROL_START]), for: self.syncControlCharacteristic!, type: .withResponse)
        //print("writeValue(0x01) done <SYNC_CONTROL_START>")
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
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
            var battery: UInt8 = 0
            if self.batteryCharacteristic != nil {
                //print("self.batteryCharacteristic!.value!.count : \(self.batteryCharacteristic!.value!.count)")
                battery = UInt8(self.batteryCharacteristic!.value![0]) //[self.batteryCharacteristic.value getBytes:&battery length:1];
                //print("battery : \(battery)")
                if bytes.count == 1 {
                    // [self.batteryCharacteristic.value getBytes:&battery length:1];
                    battery = bytes[0]
                    self.batteryLevel = Int(battery)
                    //print("self.batteryLevel is set to \(self.batteryLevel)")
                }
            }
            guard self.delegate?.onReadBattery(percent: Int(battery)) != nil else {
                print("self.delegate?.onReadBattery(:) == nil!(didUpdateValueForCharacteristic)")
                return
            }
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
        } else if characteristic.uuid.isEqual(PeripheralUUID.SYNC_CONTROL_CHAR_UUID) {
            //print("[+] Sync Control Characteristic value : \(characteristic.value!)")
            
            //print("bytes[0] : \(bytes[0])", terminator: "")//", 0x11 : \(0x11), 0x12 : \(0x12), 0x13 : \(0x13)")
            if bytes[0] == SyncCmd.SYNC_NOTI_READY || bytes[0] == SyncCmd.SYNC_NOTI_NEXT_READY {
                // 첫 20bytes를 읽어들인다
                //print(", Reading sync data...")// <totalSyncBytesLeft : \(totalSyncBytesLeft)>", terminator: "")
                //self.totalSyncBytesLeft = 0
                //print("After : totalSyncBytesLeft : \(totalSyncBytesLeft)")
                guard (self.peripheral != nil && self.syncDataCharacteristic != nil) else {
                    print("peripheral or syncDataCharacteristic is nil!(didUpdateValueForCharacteristic)")
                    return
                }
                self.peripheral!.readValue(for: self.syncDataCharacteristic!)
            }
//            else if data[0] == SyncCmd.SYNC_NOTI_DONE {
//                print(">>> SYNC DONE CHECKED! <<<")
//            } else if data[0] == SyncCmd.SYNC_NOTI_ERROR {
//                print(">>> ERROR IN SYNC PROCESS! <<<")
//            }
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
                    //print("syncData.count : \(syncData.count)")
                    let temp = syncData.subdata(in: 0..<154)
                    //temp.append(contentsOf: syncData.subdata(in: Range(0...154-1)))
                    kittydoc_data = KittyDoc_Ext_Interface_Data_Type(data: temp)
                    self.syncDataCount += 1
                    if syncData.count == 154 {
                        syncData.removeAll()
                    } else {
                        syncData = syncData.advanced(by: 154) // syncData.dropFirst(154)
                    }
                    // 중요!!! // 21.01.02 발견
                    // advanced(by: Int)는 Sliced Array가 0부터 인덱스 시작 (0 ~ n) => (0 ~ n-k) <n-k개>
                    // dropFirst(k: Int)는 Sliced Array가 k부터 인덱스 시작 (0 ~ n) => (k ~ n) <n-k개>

                    //totalSyncBytesLeft -= 154
                    //print("syncData : \(syncData.count), totalSyncBytesLeft : \(totalSyncBytesLeft)")
                    //for i in 0..<temp.count {
                    //    let string = String(format:"%.2X", temp[i])
                    //    print("\(string)", terminator: " ")
                    //    if((i%19)==18) {
                    //        print("")
                    //    }
                    //}
                    //print("")

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
                        let helper: SyncHelper = SyncHelper()
                        helper.parseData(data: syncData)
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //

                        // notify to delegate
                        guard self.delegate?.onSyncCompleted() != nil else {
                            print("self.delegate?.onSyncCompleted() == nil!(didUpdateValueForCharacteristic1)")
                            return
                        }
                        return
                    }

                    print("┌-------------------------------------------------------------------------------------------------------------------------------------------┐")
                    print("|   s_tick   |       s_time        |   e_tick   |       s_time        |  steps  |  t_lux  | avg_lux |  avg_k  |  vct_x  |  vct_y  |  vct_z  |")
                    for i in 0...5 {
                        let sensorData:SensorData = SensorData(_object: kittydoc_data.d[i], _petID: UserInfo.shared.UserID, _petLB: 0)
                        let server:KittyDocServer = KittyDocServer()
                        let sensorResponse:ServerResponse = server.sensorSend(data: sensorData)
                        if(sensorResponse.getCode() as! Int == ServerResponse.SENSOR_SUCCESS){
                            print(sensorResponse.getMessage())
                        } else {
                            print(sensorResponse.getMessage())
                        }

                        //print("kittydoc_data.d[\(i)]")
                        let s_time = unixtimeToString(unixtime: time_t(kittydoc_data.d[i].s_tick))
                        let e_time = unixtimeToString(unixtime: time_t(kittydoc_data.d[i].e_tick))
                        print("| \(kittydoc_data.d[i].s_tick) | \(s_time) |", terminator: "")
                        print(" \(kittydoc_data.d[i].e_tick) | \(e_time) |", terminator: "")
                        print(" \(String(format: "%07d", kittydoc_data.d[i].steps)) |", terminator: "")
                        print(" \(String(format: "%07d", kittydoc_data.d[i].t_lux)) |", terminator: "")
                        print(" \(String(format: "%07d", kittydoc_data.d[i].avg_lux)) |", terminator: "")
                        print(" \(String(format: "%07d", kittydoc_data.d[i].avg_k)) |", terminator: "")
                        print(" \(String(format: "%07d", kittydoc_data.d[i].vector_x)) |", terminator: "")
                        print(" \(String(format: "%07d", kittydoc_data.d[i].vector_y)) |", terminator: "")
                        print(" \(String(format: "%07d", kittydoc_data.d[i].vector_z)) |")
                    }
                    print("├-------------------------------------------------------------------------------------------------------------------------------------------┤")

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
                    print("| remainings : \(kittydoc_data.remainings), reset_num : \(kittydoc_data.reset_num), time_zone : \(kittydoc_data.time_zone), progress : \(String(format: "%03d", progress)) (\(String(format: "%06d", self.syncDataCount * 154)) / \(String(format: "%06d", totalSyncBytes)))                                                     |")
                    print("└-------------------------------------------------------------------------------------------------------------------------------------------┘")
                    guard totalSyncBytes >= 0 && (self.delegate?.onSyncProgress(progress: progress) != nil) else {
                        print("self.delegate?.onSyncProgress(:) == nil || totalSyncBytes < 0!(didUpdateValueForCharacteristic)")
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

                if self.syncControlCharacteristic != nil {
                    peripheral.writeValue(Data([SyncCmd.SYNC_CONTROL_DONE]), for: self.syncControlCharacteristic!, type: .withResponse)
                    //print("writeValue(0x03) done <SYNC_CONTROL_DONE>")
                }
                
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
                let helper: SyncHelper = SyncHelper()
                helper.parseData(data: syncData)
                
                // notify to delegate
                guard self.delegate?.onSyncCompleted() != nil else {
                    print("self.delegate?.onSyncCompleted() == nil!(didUpdateValueForCharacteristic2)")
                    return
                }
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
            }
        } else if characteristic.uuid.isEqual(PeripheralUUID.SYSCMD_CHAR_UUID) {
            // system command 응답 처리
            guard self.delegate?.onSysCmdResponse(data: data) != nil else {
                print("self.delegate?.onSysCmdResponse(:) == nil!(didUpdateValueForCharacteristic)")
                return
            }
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