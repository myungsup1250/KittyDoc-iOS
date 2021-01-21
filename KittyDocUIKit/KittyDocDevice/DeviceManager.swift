// DeviceManager 완벽 구현까지 주석처리
////
////  DeviceManager.swift
////  KittyDocBLETest
////
////  Created by 곽명섭 on 2021/01/03.
////  Copyright © 2020 Myungsup. All rights reserved.
////
//
//import Foundation
//import CoreBluetooth
//
//public extension UUID {
//    internal var bytes : [UInt8] {
//        let (u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16) = self.uuid
//        return [u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16]     }
//    internal var data : Data { Data(bytes) }
//}
//
//class DeviceManager {
//    public static let KEY_DEVICE = String("device")
//    public static let KEY_NAME = String("name")
//    public static let KEY_DICTIONARY = String("device_dictionary")
////    NSString* KEY_DEVICE = @"device";
////    NSString* KEY_NAME = @"name";
////    NSString* KEY_DICTIONARY = @"device_dictionary";
//
//    
////    var delegate: id // @property (strong, nonatomic) id delegate;
//    var commandQueue: NSMutableArray? // 연결 후 실행할 명령 큐 // @property (strong, nonatomic) NSMutableArray *commandQueue;
////    var foundDevices: NSMutableArray? // @property (strong, nonatomic) NSMutableArray *foundDevices;
//    var foundDevices: Array<Any>
//// ////////foundDevices: Array or NSMutableArray??????????????????????????
//
//    var peripheral: CBPeripheral?                    // @property (strong, nonatomic) CBPeripheral * _Nullable peripheral;
//    var manager: CBCentralManager?                   // @property (strong, nonatomic) CBCentralManager *manager;
//    var syncControlCharacteristic: CBCharacteristic? // @property (strong, nonatomic) CBCharacteristic *syncControlCharacteristic;
//    var syncDataCharacteristic: CBCharacteristic?    // @property (strong, nonatomic) CBCharacteristic *syncDataCharacteristic;
//    var sysCmdCharacteristic: CBCharacteristic?      // @property (strong, nonatomic) CBCharacteristic *sysCmdCharacteristic;
//    var batteryCharacteristic: CBCharacteristic?     // @property (strong, nonatomic) CBCharacteristic *batteryCharacteristic;
//    var firmwareVersion: String                      // @property (strong, nonatomic) NSString *firmwareVersion;
//    private var _batteryLevel: Int                   // @property (nonatomic) int batteryLevel; // in percent (0~100)
//    public var batteryLevel: Int {                   // batteryLevel : { [0, 100] : normal state } + {-1 : initial state(not set)}
//        get {
//            return self._batteryLevel
//        }
//        set(newLevel) {
////            if(newLevel == -1) {
////                print("Set batteryLevl to \(newLevel) as an initial value!")
////            }
//            guard (newLevel > -1 && newLevel < 101) else {
//                print("batteryLevel should be 0 to 100, input : \(newLevel)")
//                return
//            }
//            self._batteryLevel = newLevel
//        }
//    }
//
//    private var maxRSSI : Int32
//    
//    private var _isConnected : Bool
//    private var _isSyncServiceFound : Bool
//    private var _isRequiredServicesFound : Bool // 필요 서비스들 모두 찾았는가?
//    private var _isScanningDfuTarg : Bool
//    // https://medium.com/ios-development-with-swift/%ED%94%84%EB%A1%9C%ED%8D%BC%ED%8B%B0-get-set-didset-willset-in-ios-a8f2d4da5514 참고: Getter & Setter
//    public var isConnected: Bool {
//        get {
//            return self._isConnected
//        }
//        set(isConnected) {
//            self._isConnected = isConnected
//        }
//    }
//    public var isSyncServiceFound: Bool {
//        get {
//            return self._isSyncServiceFound
//        }
//        set(isSyncServiceFound) {
//            self._isSyncServiceFound = isSyncServiceFound
//        }
//    }
//    public var isRequiredServicesFound: Bool {
//        get {
//            return self._isRequiredServicesFound
//        }
//        set(isRequiredServicesFound) {
//            self._isRequiredServicesFound = isRequiredServicesFound
//        }
//    }
//    public var isScanningDfuTarg: Bool {
//        get {
//            return self._isScanningDfuTarg
//        }
//        set(isScanningDfuTarg) {
//            self._isScanningDfuTarg = isScanningDfuTarg
//        }
//    }
//
//    private var syncData : Data
//    private var totalSyncBytes : UInt32 // 동기화할 전체 바이트수
////    @implementation DeviceManager
////    {
////        long maxRSSI;
////        BOOL isConnected;
////        BOOL isSyncServiceFound;
////        BOOL isRequiredServicesFound; // 필요 서비스들 모두 찾아서 준비가 다 됐는지
////        NSMutableData *syncData;
////        UInt32 totalSyncBytes;  // 동기화할 전체 바이트수
////        BOOL isScanningDfuTarg;
////    }
//
////    public var syncControlCharacteristic : CBCharacteristic?
////    public var syncDataCharacteristic : CBCharacteristic?
//
////    NSString* KEY_DEVICE = @"device";
////    NSString* KEY_NAME = @"name";
////    NSString* KEY_DICTIONARY = @"device_dictionary";
////
////    static DeviceManager *_sharedInstance = nil;
////    static dispatch_once_t pred; // delegate method 중복호출 방지
//
//    // Declare class instance property
//    public static let sharedInstance = DeviceManager()
//    
//    // Add a function
//    func processDeviceManagerOperation() {
//        print("Started processing Device Manager Operation")
//
//        // Your other code here
//    }
////    // Call function of Singleton class
////    DeviceManager.sharedInstance.processDeviceManagerOperation()
////
////    // Call cloud code operation function again
////    DeviceManager.sharedInstance.processDeviceManagerOperation()
////
////    // And again to see that class initializer was called only once
////    DeviceManager.sharedInstance.processDeviceManagerOperation()
////
//
//    
//     // Declare an initializer
//     // Because this class is singleton only one instance of this class can be created
//    init() {
//        self.maxRSSI = 0
//
//        self._isConnected = false
//        self._isSyncServiceFound = false
//        self._isRequiredServicesFound = false
//        self._isScanningDfuTarg = false
//
//        self.syncData = Data()
//        self.totalSyncBytes = 0
//        
//        self.syncControlCharacteristic = nil
//        self.syncDataCharacteristic = nil
//        
//        self.commandQueue = nil // Optional에만 nil 입력 가능...
//        self.foundDevices = Array<Any>()
//
//        self.peripheral = nil
//        self.manager = nil
//        self.syncControlCharacteristic = nil
//        self.syncDataCharacteristic = nil
//        self.sysCmdCharacteristic = nil
//        self.batteryCharacteristic = nil
//        self.firmwareVersion = String("") // 빈 문자열로 정의?
//        self._batteryLevel = -1
//    }
//    
//    func resetCharacteristics() {
//        self.syncControlCharacteristic = nil
//        self.syncDataCharacteristic = nil
//        self.sysCmdCharacteristic = nil
//        self.batteryCharacteristic = nil
//    }
//    
//    func removeDevices() { // 앱에서 장비를 지움
//        self.disconnect()
////        self.removePeropheral()
//        self.resetCharacteristics()
//        self.foundDevices.removeAll() // self.foundDevices?.removeAllObjects()
//    }
//    
//    func disconnect() { // 연결만 끊음
//        self.isRequiredServicesFound = false
//        self.isConnected = false
//        
//        if (self.peripheral != nil) {
//            self.manager?.cancelPeripheralConnection(self.peripheral!) // Value of optional type 'CBPeripheral?' must be unwrapped to a value of type 'CBPeripheral'
//
//            // 연결 끊으면 해당 기기 자동연결하지 않도록
////            self.removePeripheral()
//        }
//    }
//    
//    func getSavedDeviceName() -> String {
//        let dict: Dictionary = UserDefaults.standard.dictionary(forKey: DeviceManager.KEY_DICTIONARY)!
//        return dict[DeviceManager.KEY_NAME] as! String
//    }
//
//    func savedDeviceInfo() -> Dictionary<String, Any> {
//        let dict: Dictionary = UserDefaults.standard.dictionary(forKey: DeviceManager.KEY_DICTIONARY)! //string(forKey: DeviceManager.KEY_DICTIONARY)
//        return dict
//    }
//
//    func connectPeripheral() {
//        self.isRequiredServicesFound = false
//        
//        //pred = 0// static dispatch_once_t pred; // delegate method 중복호출 방지
//        self.resetCharacteristics()
//        if(self.peripheral == nil) {
////            self.delegate.onConnectionFailed()
//        } else {
//            self.manager?.connect(self.peripheral!, options: nil)
//        }
//        
//
//    }
//    
//    func removePeripheral() {
//        self.isRequiredServicesFound = false
//        
//        self.peripheral = nil
//        self.resetCharacteristics()
//        self.foundDevices.removeAll() // self.foundDevices?.removeAllObjects()
//        
//        UserDefaults.standard.removeObject(forKey: DeviceManager.KEY_DICTIONARY)
//        UserDefaults.standard.synchronize()
//
//    }
//
//    func savedDeviceUUIDString() -> String? {
////        return nil// bingo에서는 안쓴다 => 요건 서버에서 수정하기 전까지 막아둠 ??
//        let dict: Dictionary? = UserDefaults.standard.dictionary(forKey: DeviceManager.KEY_DICTIONARY)!
//        if(dict == nil) {
//            return nil
//        }
//        
//        let uuid: String = dict![DeviceManager.KEY_DEVICE] as! String
//        return uuid
//    }
//    
//    func setSavedDeviceUUIDString(uuid: String) {
//        var dict: Dictionary = Dictionary<String, Any>()
//        
//        dict[DeviceManager.KEY_DEVICE] = uuid
//        dict[DeviceManager.KEY_NAME] = "kittydoc"// puppydoc
//        UserDefaults.standard.dictionary(forKey: DeviceManager.KEY_DICTIONARY)
//    }
//    
//    func connectPeripheral(uuid: String, name: String) { // 지정한 UUID의 장비로 연결
//        var dict: Dictionary = Dictionary<String, Any>()
//
//        dict[DeviceManager.KEY_DEVICE] = uuid
//        dict[DeviceManager.KEY_NAME] = name
//        UserDefaults.standard.dictionary(forKey: DeviceManager.KEY_DICTIONARY)
//        
//        self.reestablishConnection()
//    }
//    
//    func reestablishConnection() { // 저장된 장비에 다시 연결
//        self.isRequiredServicesFound = false
//        
//        //pred = 0// static dispatch_once_t pred; // delegate method 중복호출 방지
//        self.resetCharacteristics()
//        var centralQueue: DispatchQueue = DispatchQueue(label: "devicemanager")
//        self.manager = CBCentralManager(delegate: self.manager?.delegate, queue: centralQueue)
////        self.manager = [[CBCentralManager alloc]initWithDelegate:self queue:centralQueue];
//    }
//
//    func scanPeripheral() { // SleepDoc 서비스를 가진 장비를 스캔
//        // 기존 장비 지우고
//        self.removePeripheral()
//        self.resetCharacteristics()
//        self.foundDevices.removeAll() // self.foundDevices?.removeAllObjects()
//        
//        var centralQueue: DispatchQueue = DispatchQueue(label: "devicemanager")
//        self.manager = CBCentralManager(delegate: self.manager?.delegate, queue: centralQueue)
////        var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
////        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
////            // your function here
////        })
////        var dispatchTime: DispatchTime = DispatchTime(uptimeNanoseconds: UInt64(5000 * Double(NSEC_PER_MSEC)))
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5000 * Double(NSEC_PER_MSEC)) {// var NSEC_PER_MSEC: UInt64 /* nanoseconds per millisecond */
//            // Stop scanning
//            self.manager?.stopScan()
//            
//            if (self.foundDevices.count == 0) {
////                self.delegate.onDeviceNotFound()
//            } else {
//               // bingo : sleepdoc 장비는 검색되지 않게
//                var kittydocDevices: Array = Array<Any>() // NSMutableArray *puppydocDevices = [[NSMutableArray alloc] init];
////                for p in self.foundDevices {
////                    if(p.peripheral.name?.lowercased() != String("sleepdoc")) {
////                        kittydocDevices.append(p)
////                    }
////                }
//
//                self.foundDevices.removeAll() // self.foundDevices?.removeAllObjects()
//                self.foundDevices.append(contentsOf: kittydocDevices) // [self.foundDevices addObjectsFromArray:puppydocDevices];
////                self.foundDevices.sort { (obj1: PeripheralData, obj2: PeripheralData) -> Bool in
////                    return obj2.rssi - obj1.rssi
////                }
////               [self.foundDevices sortUsingComparator:^NSComparisonResult(PeripheralData* obj1, PeripheralData* obj2) {
////                   return obj2.rssi - obj1.rssi;
////               }];
////                self.delegate.respondsToSelector~~~~
////               if( [self.delegate respondsToSelector:@selector(onDevicesFound:)])
////               {
////                   [self.delegate onDevicesFound:self.foundDevices];
////               }
//// //                           [self connectPeripheral];
//            }
//        }
//        
//
//    }
//
//
////    - (void)scanPeripheral
////    {
////        // 기존 장비 지우고
////        [self removePeripheral];
////        [self resetCharacteristics];
////        [self.foundDevices removeAllObjects];
////
////        dispatch_queue_t centralQueue = dispatch_queue_create("devicemanager", DISPATCH_QUEUE_SERIAL);
////        self.manager = [[CBCentralManager alloc]initWithDelegate:self queue:centralQueue];
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5000*NSEC_PER_MSEC),
////                       dispatch_get_main_queue(), ^{
////                           // stop scanning
////                           [self.manager stopScan];
////
////                           if( [self.foundDevices count] == 0 )
////                           {
////                               [self.delegate onDeviceNotFound];
////                           } else
////                           {
////                               // bingo : sleepdoc 장비는 검색되지 않게
////                               NSMutableArray *puppydocDevices = [[NSMutableArray alloc] init];
////                               for( PeripheralData* p in self.foundDevices ) {
////                                   if( ![p.peripheral.name.lowercaseString isEqualToString:@"sleepdoc"] ) {
////                                       [puppydocDevices addObject:p];
////                                   }
////                               }
////                               [self.foundDevices removeAllObjects];
////                               [self.foundDevices addObjectsFromArray:puppydocDevices];
////
////                               [self.foundDevices sortUsingComparator:^NSComparisonResult(PeripheralData* obj1, PeripheralData* obj2) {
////                                   return obj2.rssi - obj1.rssi;
////                               }];
////                               if( [self.delegate respondsToSelector:@selector(onDevicesFound:)])
////                               {
////                                   [self.delegate onDevicesFound:self.foundDevices];
////                               }
////    //                           [self connectPeripheral];
////                           }
////                       });
////    }
//
//    func setRTC() { // set RTC
//        print("Setting RTC...")
//        let now: Date = Date()
//        let unixTime: UInt32 = UInt32(now.timeIntervalSince1970)
//        let GMTOffset: Int32 = Int32(TimeZone.current.secondsFromGMT())
//        // int GMTOffset = [Util getGMTOffset];
//        // // // // // GMTOffset 몇 바이트인지 확인 필요!!!!!! Should be 3 Bytes??????
//        var bytes: [UInt8] = [SyncCmd.SYSCMD_SET_RTC, ]
//        let unixTimeInBytes = withUnsafeBytes(of: unixTime.littleEndian) {
//            Array($0)
//        }
////        print(unixTimeInBytes)
//        bytes.append(contentsOf: unixTimeInBytes)
//        let gmtOffsetInBytes = withUnsafeBytes(of: GMTOffset.littleEndian) {
//            Array($0)
//        }
////        print(gmtOffsetInBytes)
//        bytes.append(contentsOf: gmtOffsetInBytes)
//        
////        print("bytes.count : \(bytes.count)")
//        self.peripheral!.writeValue(Data(bytes), for: self.sysCmdCharacteristic!, type: .withResponse)
//
////        char bytes[9] = {SYSCMD_SET_RTC, 0,};
////        memcpy(bytes+1, &unixTime, sizeof(unixTime));
////        memcpy(bytes+5, &GMTOffset, sizeof(GMTOffset));
////        [self.peripheral writeValue:[NSData dataWithBytes:bytes length:sizeof(bytes)] forCharacteristic:self.sysCmdCharacteristic type:CBCharacteristicWriteWithResponse];
//    }
//    
//    func getUUID() { // get UUID
//        print("Getting UUID...")
//        guard (self.peripheral != nil) else {
//            print("self.peripheral is nil!")
//            return
//        }
//        guard (self.sysCmdCharacteristic != nil) else {
//            print("self.sysCmdCharacteristic is nil!")
//            return
//        }
//
//        self.peripheral!.setNotifyValue(true, for: self.sysCmdCharacteristic!)
//        self.peripheral!.writeValue(Data([SyncCmd.SYSCMD_GET_UUID]), for: self.sysCmdCharacteristic!, type: .withResponse)
//    }
//    
//    func getBattery() {
//        print("Getting Battery...")
//        guard (self.peripheral != nil) else {
//            print("self.peripheral is nil!")
//            return
//        }
//        guard (self.batteryCharacteristic != nil) else {
//            print("self.batteryCharacteristic is nil!")
//            return
//        }
//        self.peripheral!.readValue(for: self.batteryCharacteristic!)
//    }
//    
//
//    func setUUID(uuid: CBUUID) {
//        print("Writing UUID \(uuid.uuidString)")
//        var bytes: [UInt8] = [SyncCmd.SYSCMD_SET_UUID, ] // 총 길이 17이어야 함!
////        uuid.getUUIDBytes
//        let uuidInBytes = withUnsafeBytes(of: uuid) {
//            Array($0)
//        }
//        print(uuidInBytes)
//        bytes.append(contentsOf: uuidInBytes) // 16 Bytes 인지 확인!!!!!!!!!!!!!
//        self.peripheral!.writeValue(Data(uuidInBytes), for: self.sysCmdCharacteristic!, type: .withResponse)
//
//    }
//
//    func searchSyncRequiredCharacteristics(service: CBService) {
//        print("[+] searchSyncRequiredCharacteristics()")
//
//        self.syncControlCharacteristic = nil
//        self.syncDataCharacteristic = nil
//        if let characteristics = service.characteristics {
//            for characteristic in characteristics {
//                print("Found characteristic \(characteristic.uuid)")
//                if characteristic.uuid.isEqual(PeripheralUUID.SYNC_CONTROL_CHAR_UUID) {
//                    print("Sync control characteristic found")
//                    self.syncControlCharacteristic = characteristic
//                }
//                if characteristic.uuid.isEqual(PeripheralUUID.SYNC_DATA_CHAR_UUID) {
//                    print("Sync data characteristic found")
//                    self.syncDataCharacteristic = characteristic
//                }
//            }
//        }
//    }
//    
//    func startSyncTest() {
//        guard (self.peripheral != nil) else {
//            print("self.peripheral == nil !!")
//            return
//        }
//        guard (self.syncControlCharacteristic != nil || self.syncDataCharacteristic != nil) else {
//            print("Required sync service not found.")
//            return
//        }
//        print("Start sync...")
//        // 기기가 여러대인 경우 대비하여 DB를 싹 지우자
////        CoreDataManager *cdm = [CoreDataManager sharedManager];
////        [cdm resetDB];
//
////        syncData = [NSMutableData data];
//
//        self.peripheral!.setNotifyValue(true, for: self.syncControlCharacteristic!)
//        self.peripheral!.writeValue(Data([SyncCmd.SYNC_CONTROL_START]), for: self.syncControlCharacteristic!, type: .withResponse)
//        //print("writeValue(0x01) done <SYNC_CONTROL_START>")
//    }
//    
//    func scanDfuTarget() {
//        self.isScanningDfuTarg = true
//        //var filterUUID: CBUUID = CBUUID(string: dfuServiceUUIDString)
////        CBUUID *filterUUID = [CBUUID UUIDWithString:dfuServiceUUIDString];
////        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
////
////        [self.manager setDelegate:self];
////        [self.manager scanForPeripheralsWithServices:@[ filterUUID ] options:options];
//
//    }
//    
//    func doFactoryReset() {
//        guard (self.peripheral != nil) else {
//            print("self.peripheral == nil !!")
//            return
//        }
//        guard (self.sysCmdCharacteristic != nil) else {
//            print("self.sysCmdCharacteristic == nil !!")
//            return
//        }
//
//        self.peripheral!.writeValue(Data([SyncCmd.FACTORY_RESET_CMD]), for: self.sysCmdCharacteristic!, type: .withResponse)
//
//    }
//    
//    func reserveCommand(command: String) {
//        self.commandQueue?.add(command)
//    }
//
//    func performQueueCommands() { // queue에 저장된 명령 실행
////        var queueCopy: Array = Array.arraywith
//    }
//
////    - (void)performQueueCommands
////    {
////        NSArray *queueCopy = [NSArray arrayWithArray:self.commandQueue];
////        for( NSString *cmd in queueCopy )
////        {
////            if( [cmd isEqualToString:COMMAND_FACTORY_RESET] )
////            {
////                [self doFactoryReset];
////            }
////            else if( [cmd isEqualToString:COMMAND_BATTERY] )
////            {
////                [self getBattery];
////            }
////
////            [self.commandQueue removeObjectAtIndex:0];
////        }
////    }
//
//
//}
