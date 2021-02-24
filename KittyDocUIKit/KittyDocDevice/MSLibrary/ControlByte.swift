//
//  ControlByte.swift
//  KittyDocBLETest
//
//  Created by 곽명섭 on 2020/08/31.
//  Copyright © 2020 Myungsup. All rights reserved.
//

import Foundation

public func convertUInt16(bytes: [UInt8], isLittleEndian: Bool) -> UInt16 {
    var data: UInt16 = 0
    if isLittleEndian {
        data = bytes.reversed().reduce(0) { soFar, byte in
            return soFar << 8 | UInt16(byte) // reversed() -> littleEndian
        }
    } else {
        data = bytes.reduce(0) { soFar, byte in
            return soFar << 8 | UInt16(byte) // bigEndian
        }
    }
    //print("result : ", String(data, radix: 16))
    return UInt16(data)
}

public func convertUInt32(bytes: [UInt8], isLittleEndian: Bool) -> UInt32 {
    var data: UInt32 = 0
    if isLittleEndian {
        data = bytes.reversed().reduce(0) { soFar, byte in
            return soFar << 8 | UInt32(byte) // reversed() -> littleEndian
        }
    } else {
        data = bytes.reduce(0) { soFar, byte in
            return soFar << 8 | UInt32(byte) // bigEndian
        }
    }
    //print("result : ", String(data, radix: 16))
    return UInt32(data)
}

// unixtime 값을 문자열로 변환하여 반환
func unixtimeToString(unixtime: time_t) -> String { // SleepDoc_Ext_Interface_Data_Type.time_zone 고려 추가?
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = String("yyyy-MM-dd HH:mm:ss") //String("yyyy-MM-dd HH:mm:ss.SSS")
//    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    let current_date_string = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(unixtime)))
    //print("unixtime : \(unixtime), result : \(current_date_string)")

    return current_date_string // dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(unixtime)))
}


//void delay(clock_t n) {
//    clock_t start = clock();
//    while (clock() - start < n);
//}
//
//int8_t S8BitConvert(UCHAR * src, int index) {    // Converts bit for Signed 8bit data
//    int8_t result = 0;
//    if (src[index] >= 128) { // Negative Number
//        result = -(~src[index] + 1);
//    }
//    else {
//        result = src[index];
//    }
//    return result;
//}
//
//int16_t S16BitConvert(UCHAR * src, int index) {    // Converts bit for Signed 16bit data
//    int16_t result = 0;
//    if (src[index + 1] >= 128) { // Negative Number
//        result = -(~(src[index] + (src[index + 1] * 256)) + 1);
//    }
//    else {
//        result = src[index] + src[index + 1] * 256;
//    }
//    return result;
//}
//
//int32_t S32BitConvert(UCHAR * src, int index) {    // Converts bit for Signed 32bit data
//    int32_t result = 0;
//    if (src[index + 3] >= 128) { // Negative Number
//        result = -(~(src[index] + (src[index + 1] << 8) + (src[index + 2] << 16) + (src[index + 3] << 24)) + 1);
//    }
//    else {
//        result = src[index] + (src[index + 1] << 8) + (src[index + 2] << 16) + (src[index + 3] << 24);
//    }
//    return result;
//}
//
//uint8_t U8BitConvert(UCHAR * src, int index) {    // Converts bit for Unsigned 8bit data
//    return src[index];
//}
//
//uint16_t U16BitConvert(UCHAR * src, int index) {    // Converts bit for Unsigned 16bit data
//    return (src[index] + src[index + 1] << 8);
//}
//
//uint32_t U32BitConvert(UCHAR * src, int index) {    // Converts bit for Unsigned 32bit data
//    return (src[index] + (src[index + 1] << 8) + (src[index + 2] << 16) + (src[index + 3] << 24));
//}
