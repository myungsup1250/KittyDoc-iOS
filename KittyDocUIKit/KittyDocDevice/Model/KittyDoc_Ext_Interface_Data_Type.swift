//
//  KittyDoc_Ext_Interface_Data_Type.swift
//  KittyDocBLETest
//
//  Created by 곽명섭 on 2020/08/11.
//  Copyright © 2020 Myungsup. All rights reserved.
//

import Foundation

public class KittyDoc_Ext_Interface_Data_Type {
    var d = [KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type()]
    var time_zone : Int32 = 0   // Time Zone
    var reset_num : Int16 = 0   // Reset 횟수 ( 나중에 tick 보정에 사용할 예정)
    var remainings : Int32 = 0  // 남아있는 데이터 개수

    init() {
        for i in 0..<6 {
            d[i] = KittyDoc_10_Min_Data_Type()
        }
        self.time_zone = 0
        self.reset_num = 0
        self.remainings = 0
    }
    
    init(data: Data) {
        //print("data.count : \(data.count)")
        for i in 0..<6 {
//            print("\tAttempt \(i)")
            let temp: Data = data.subdata(in: Range(24*(i)...24*(i+1)-1))
            d[i] = KittyDoc_10_Min_Data_Type(data: temp)
        } // 0 ~ 143 바이트 소비
        self.time_zone = Int32(convertUInt32(bytes: [UInt8](data.subdata(in: Range(144...147))), isLittleEndian: true))
        self.reset_num = Int16(convertUInt16(bytes: [UInt8](data.subdata(in: Range(148...149))), isLittleEndian: true))
        self.remainings = Int32(convertUInt32(bytes: [UInt8](data.subdata(in: Range(150...153))), isLittleEndian: true))
        // 144 ~ 153 바이트 소비
//        print("====== Assigning SleepDoc_10_Min_Data_Type Done ======");
//        print("\ttime_zone : \(self.time_zone)");
//        print("\treset_num : \(self.reset_num)");
//        print("\tremainings : \(self.remainings)");
    }
    
    public func size() -> Int {
        return 154
    }
}
