//
//  KittyDoc_Ext_Interface_Data_Type.swift
//  KittyDocBLETest
//
//  Created by 곽명섭 on 2020/08/11.
//  Copyright © 2020 Myungsup. All rights reserved.
//

import Foundation

public class KittyDoc_Ext_Interface_Data_Type {
    var d : Array<KittyDoc_10_Min_Data_Type> = [KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type()]
//    var d = [KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type(), KittyDoc_10_Min_Data_Type()]
    var time_zone : Int32 = 0   // Time Zone
    var reset_num : Int16 = 0   // Reset 횟수 ( 나중에 tick 보정에 사용할 예정)
    var remainings : Int32 = 0  // 남아있는 데이터 개수
    //    sleepdoc_10_min_data_type d[SDATA_SIZE];
    //    int32_t time_zone;      // Time Zone
    //    int16_t reset_num;      // Reset 횟수 ( 나중에 tick 보정에 사용할 예정)
    //    int32_t remainings;     // 남아있는 데이터 개수
    init() {
        for i in 0..<6 {
            d[i] = KittyDoc_10_Min_Data_Type()
        }
        self.time_zone = 0
        self.reset_num = 0
        self.remainings = 0
    }
    
    init(data: Data) {
        //print("d.count : \(d.count)")
        for i in 0..<6 {
//            print("\tAttempt \(i)")
            let temp: Data = data.subdata(in: Range(24*(i)...24*(i+1)-1))
            d[i] = KittyDoc_10_Min_Data_Type(data: temp)
        } // 0 ~ 143 바이트 소비
        self.time_zone = Int32(convertUInt32(bytes: [UInt8](data.subdata(in: Range(144...147))), isLittleEndian: true))
        self.reset_num = Int16(convertUInt16(bytes: [UInt8](data.subdata(in: Range(148...149))), isLittleEndian: true))
        self.remainings = Int32(convertUInt32(bytes: [UInt8](data.subdata(in: Range(150...153))), isLittleEndian: true))
        // 144 ~ 153 바이트 소비
        print("====== Assigning SleepDoc_10_Min_Data_Type Done ======");
        print("\ttime_zone : \(self.time_zone)");
        print("\treset_num : \(self.reset_num)");
        print("\tremainings : \(self.remainings)");
    }
    
    public func size() -> Int {
        return 154
    }
}

//typedef struct {
//    uint32_t s_tick;      // 이 정보의 시작 시간
//    uint32_t e_tick;      // 이 정보의 마지막 시간
//    uint16_t steps;     // 걸음수
//    uint32_t t_lux;     // 이 기간 동안 누적 조도량
//    uint16_t avg_lux;   // 평균 조도량 (누적 조도량/걸음수) : 걸음수는 로깅 정보의 갯수임.
//    uint16_t avg_k;     // 평균 색온도 in kelvin
//    struct {            // 평균 운동량 (11/26 아침 master부터 적용되어 있음)
//        uint16_t x;
//        uint16_t y;
//        uint16_t z;
//    } vector;
//} __attribute__ ((packed))sleepdoc_10_min_data_type; // 총 24 bytes
//
//typedef struct {
//    sleepdoc_10_min_data_type d[SDATA_SIZE];
//    int32_t time_zone;  // Time Zone
//    uint32_t n_addr;
//} __attribute__ ((packed))sleepdoc_data_type;
//
//// 실제 동기화시 들어오는 데이터 형태
//typedef struct {
//    sleepdoc_10_min_data_type d[SDATA_SIZE];
//    int32_t time_zone;      // Time Zone
//    int16_t reset_num;      // Reset 횟수 ( 나중에 tick 보정에 사용할 예정)
//    int32_t remainings;     // 남아있는 데이터 개수
//} __attribute__ ((packed))sleepdoc_ext_interface_data_type;
