//
//  PeripheralData.swift
//  KittyDocBLEUIKit
//
//  Created by 곽명섭 on 2021/01/21.
//

import CoreBluetooth

struct PeripheralData {
    var peripheral: CBPeripheral?
    var rssi: Int
    
    init() {
        peripheral = nil
        rssi = 0
    }
    
    init(peripheral: CBPeripheral, rssi: Int) {
        self.peripheral = peripheral
        self.rssi = rssi
    }
    
    static func ==(lhs: PeripheralData, rhs: PeripheralData) -> Bool {
        return lhs.peripheral == rhs.peripheral
    }

    static func >(lhs: PeripheralData, rhs: PeripheralData) -> Bool { // Added 21.04.26
        return lhs.rssi > rhs.rssi
    }
}
