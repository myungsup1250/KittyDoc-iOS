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
