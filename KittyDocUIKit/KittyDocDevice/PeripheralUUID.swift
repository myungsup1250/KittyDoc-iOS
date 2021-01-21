//
//  PeripheralUUID.swift
//  KittyDocBLETest
//
//  Created by 곽명섭 on 2020/07/22.
//  Copyright © 2020 Myungsup. All rights reserved.
//

import Foundation
import CoreBluetooth

class PeripheralUUID: NSObject {
    //  "0xFFFA" == "0000FFFA-0000-1000-8000-00805F9B34FB"
    // public static let SYNC_SERVICE_UUID_TEST = UUID(uuidString: "0000FFFA-0000-1000-8000-00805F9B34FB") //Sync Service UUID
    // CBUUID(nsuuid: PeripheralUUID.SYNC_SERVICE_UUID_TEST!) 로 사용해야함... 불편!!!
    
    public static let SYNC_SERVICE_UUID = CBUUID.init(string: "0xFFFA") //Sync Service UUID
    public static let SYNC_CONTROL_CHAR_UUID = CBUUID.init(string: "0xFFFA") //Sync characteristic1 UUID
    public static let SYNC_DATA_CHAR_UUID = CBUUID.init(string: "0xFFFB") //Sync characteristic2 UUID
    public static let GENERAL_SERVICE_UUID = CBUUID.init(string: "0xFFFE") //
    public static let SYSCMD_CHAR_UUID = CBUUID.init(string: "0xFFFF") //
    public static let DEVICE_INFO_SERVICE_UUID = CBUUID.init(string: "0x180A")
    public static let BATTERY_SERVICE_UUID = CBUUID.init(string: "0x180F") //
    public static let BATTERY_CHAR_UUID = CBUUID.init(string: "0x2A19") //
    public static let CHARACTERISTIC_UPDATE_NOTIFICATION_DESCRIPTOR_UUID = CBUUID.init(string: "0x2902") //Sync Service UUID
    public static let SW_REVISION_CHAR_UUID = CBUUID.init(string: "0x2A28") //
}

/* UUID Lists
    SYNC_SERVICE_UUID
    SYNC_DATA_CHAR_UUID
    GENERAL_SERVICE_UUID
    SYSCMD_CHAR_UUID
    DEVICE_INFO_SERVICE_UUID
    BATTERY_SERVICE_UUID
    BATTERY_CHAR_UUID
    CHARACTERISTIC_UPDATE_NOTIFICATION_DESCRIPTOR_UUID
    SW_REVISION_CHAR_UUID
*/
