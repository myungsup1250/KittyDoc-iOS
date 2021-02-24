//
//  SyncCmd.swift
//  KittyDocBLETest
//
//  Created by 곽명섭 on 2020/07/22.
//  Copyright © 2020 Myungsup. All rights reserved.
//

import Foundation
import CoreBluetooth

class SyncCmd: NSObject {
    public static let SYNC_CONTROL_START = UInt8(0x01)
    public static let SYNC_CONTROL_PREPARE_NEXT = UInt8(0x02)
    public static let SYNC_CONTROL_DONE = UInt8(0x03)
    public static let SYNC_CONTROL_ABORT = UInt8(0xFF)

    public static let SYNC_NOTI_READY = UInt8(0x11)
    public static let SYNC_NOTI_NEXT_READY = UInt8(0x12)
    public static let SYNC_NOTI_DONE = UInt8(0x13)
    public static let SYNC_NOTI_ERROR = UInt8(0xFF)
    
    public static let SYSCMD_SET_RTC = UInt8(0x06)
    public static let SYSCMD_SET_UUID = UInt8(0x0A)
    public static let SYSCMD_GET_UUID = UInt8(0x0B)

    public static let FACTORY_RESET_CMD = UInt8(0xAA)
}

/* UUID Lists
    SYNC_CONTROL_START
    SYNC_CONTROL_PREPARE_NEXT
    SYNC_CONTROL_DONE
    SYNC_CONTROL_ABORT
 
    SYNC_NOTI_READY
    SYNC_NOTI_NEXT_READY
    SYNC_NOTI_DONE
    SYNC_NOTI_ERROR
 
    FACTORY_RESET_CMD
*/
