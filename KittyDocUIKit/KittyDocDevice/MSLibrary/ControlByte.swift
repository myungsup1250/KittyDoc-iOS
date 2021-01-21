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

// func myMemcpy(Byte[] &dst, Byte[] src, Int dstStart, Int srcStart, Int len);
// src[srcStart]부터 len만큼 dst[dstStart] 배열 위치에 복사. C/C++ memcpy()와 유사
func myMemcpy(dst: inout [UInt8], src: [UInt8], dstStart: Int, srcStart: Int, len: Int) -> Int {
    //print("[+] mycpyarr(dstStart: \(dstStart), srcStart: \(srcStart), len: \(len))")
    if src.count < srcStart+len { // 배열을 복사할 만큼 데이터가 없으면 리턴
        return 0
    }
    //print("dst.count : \(dst.count), src.count : \(src.count)")
    var index: Int = dstStart
    for i in srcStart..<srcStart+len {
        //print("i : \(i), index : \(index), ", terminator: "")
        //print("src[\(i)] = \(src[i]), dst[\(index)] = \(dst[index])")
        dst[index] = src[i]
        index += 1
    }
    
    return len
}

// func String unixtimeToString(time_t unixtime);
// unixtime 값을 문자열로 변환하여 반환
func unixtimeToString(unixtime: time_t) -> String { // SleepDoc_Ext_Interface_Data_Type.time_zone 고려 추가?
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = String("yyyy-MM-dd HH:mm:ss") //String("yyyy-MM-dd HH:mm:ss.SSS")
//    dateFormatter.setLocalizedDateFormatFromTemplate(Locale.current.languageCode!)
//    dateFormatter.locale = Locale.current
//    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    let current_date_string = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(unixtime)))
    //print("unixtime : \(unixtime), result : \(current_date_string)")

    return current_date_string // dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(unixtime)))
}

//- (NSString*)unixtimeToString:(time_t)unixtime
//{
//    NSTimeInterval _interval=unixtime;
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
//    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
//    [formatter setLocale:[NSLocale currentLocale]];
//    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
//    NSString *dateString = [formatter stringFromDate:date];
//    return dateString;
//}

// Delete if not necessary
//    private func writeToCharacteristic(withCharacteristic characteristic: CBCharacteristic, withValue value: Data) {
//        // Check if is has the write property
//        if peripheral != nil && characteristic.properties.contains(.write) {
//            peripheral.writeValue(value, for: characteristic, type: .withResponse)
//        } else if peripheral != nil && characteristic.properties.contains(.writeWithoutResponse) {
//            peripheral.writeValue(value, for: characteristic, type: .withoutResponse)
//        }
//        print("Tx Characteristic: \(characteristic.uuid)")
//
//    }
//
//    private func readFromCharacteristic(withCharacteristic characteristic: CBCharacteristic, withValue value: Data) {
//        // Check if is has the read property
//        if peripheral != nil && characteristic.properties.contains(.read) {
//            //readCharacteristic = characteristic
//            peripheral.readValue(for: characteristic)
//            peripheral.setNotifyValue(true, for: characteristic)
//            print("Rx Characteristic: \(characteristic.uuid)")
//        }
//    }

//protocol UIntToBytesConvertable {
//    var toBytes: [UInt8] { get }
//}
//
//extension UIntToBytesConvertable {
//    func toByteArr<T: Integer>(endian: T, count: Int) -> [UInt8] {
//        var _endian = endian
//        let bytePtr = withUnsafePointer(to: &_endian) {
//            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
//                UnsafeBufferPointer(start: $0, count: count)
//            }
//        }
//        return [UInt8](bytePtr)
//    }
//}
//
//extension UInt16: UIntToBytesConvertable {
//    var toBytes: [UInt8] {
//        return toByteArr(endian: self.littleEndian,
//                         count: MemoryLayout<UInt16>.size)
//    }
//}
//
//extension UInt32: UIntToBytesConvertable {
//    var toBytes: [UInt8] {
//        return toByteArr(endian: self.littleEndian,
//                         count: MemoryLayout<UInt32>.size)
//    }
//}
//
//extension UInt64: UIntToBytesConvertable {
//    var toBytes: [UInt8] {
//        return toByteArr(endian: self.littleEndian,
//                         count: MemoryLayout<UInt64>.size)
//    }
//}

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
