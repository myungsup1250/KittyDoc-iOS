//
//  KittyDoc_10_Min_Data.swift
//  KittyDocBLETest
//
//  Created by 곽명섭 on 2020/08/11.
//  Copyright © 2020 Myungsup. All rights reserved.
//

//let bytes: [UInt8] = [0x01, 02, 03, 04]
//print(bytes)
//let u64le: UInt64 = Data(bytes).toInteger(endian: .little)
//print(String(u64le, radix: 16))
//let u64be: UInt64 = Data(bytes).toInteger(endian: .big)
//print(String(u64be, radix: 16))
//
//let words: [UInt16] = [0xffff, 0xfffe, 1, 0]
//let u64be2: UInt64 = words.toInteger(endian: .big)
//print(String(u64be2, radix: 16))


import Foundation

public enum Endian {
    case big, little
}

protocol IntegerTransform: Sequence where Element: FixedWidthInteger {
    func toInteger<I: FixedWidthInteger>(endian: Endian) -> I
}

extension IntegerTransform {
    func toInteger<I: FixedWidthInteger>(endian: Endian) -> I {
        let f = { (accum: I, next: Element) in accum &<< next.bitWidth | I(next) }
        return endian == .big ? reduce(0, f) : reversed().reduce(0, f)
    }
}

extension Data: IntegerTransform {}
extension Array: IntegerTransform where Element: FixedWidthInteger {}

public class KittyDoc_10_Min_Data_Type {
    public var s_tick : UInt32 = 0   // 이 정보의 시작 시간
    public var e_tick : UInt32 = 0   // 이 정보의 마지막 시간
    public var steps : UInt16 = 0    // 걸음수 (JAVA short steps;)
    public var t_lux : UInt32 = 0    // 이 기간 동안 누적 조도량
    public var avg_lux : UInt16 = 0  // 평균 조도량 (누적 조도량/걸음수) : 걸음수는 로깅 정보의 갯수 (JAVA short avg_lux;)
    public var avg_k : UInt16 = 0    // 평균 색온도 in kelvin (JAVA short avg_k;)
    public var vector_x : UInt16 = 0 // (JAVA short vector_x;)
    public var vector_y : UInt16 = 0 // (JAVA short vector_y;)
    public var vector_z : UInt16 = 0 // (JAVA short vector_z;)
    
    init() {
        self.s_tick = 0
        self.e_tick = 0
        self.steps = 0
        self.t_lux = 0
        self.avg_lux = 0
        self.avg_k = 0
        self.vector_x = 0
        self.vector_y = 0
        self.vector_z = 0
    }

    init(s_tick: UInt32, e_tick: UInt32, steps: UInt16, t_lux: UInt32, avg_lux: UInt16, avg_k: UInt16, vector_x: UInt16, vector_y: UInt16, vector_z: UInt16) {
        self.s_tick = s_tick     // 4 Bytes
        self.e_tick = e_tick     // 4 Bytes
        self.steps = steps       // 2 Bytes
        self.t_lux = t_lux       // 4 Bytes
        self.avg_lux = avg_lux   // 2 Bytes
        self.avg_k = avg_k       // 2 Bytes
        self.vector_x = vector_x // 2 Bytes
        self.vector_y = vector_y // 2 Bytes
        self.vector_z = vector_z // 2 Bytes
    }
    
    init(data: Data) {
//        print("SleepDoc_10_Min_Data_Type Constructor data length : \(data.count)")
        guard data.count == 24 else {
            print("SleepDoc_10_Min_Data_Type data should be 154, length : \(data.count)")
            return
        }
        var offset : Int = 0

        setS_tick(s_tick_in_byte: [UInt8](data.subdata(in: Range(offset...offset+3))))
        offset += MemoryLayout<UInt32>.size // 4

        setE_tick(e_tick_in_byte: [UInt8](data.subdata(in: Range(offset...offset+3))))
        offset += MemoryLayout<UInt32>.size // 4

        setSteps(steps_in_byte: [UInt8](data.subdata(in: Range(offset...offset+1))))
        offset += MemoryLayout<UInt16>.size // 2

        setT_lux(t_lux_in_byte: [UInt8](data.subdata(in: Range(offset...offset+3))))
        offset += MemoryLayout<UInt32>.size // 4

        setAvg_lux(avg_lux_in_byte: [UInt8](data.subdata(in: Range(offset...offset+1))))
        offset += MemoryLayout<UInt16>.size // 2

        setAvg_k(avg_k_in_byte: [UInt8](data.subdata(in: Range(offset...offset+1))))
        offset += MemoryLayout<UInt16>.size // 2

        setVector_x(vector_x_in_byte: [UInt8](data.subdata(in: Range(offset...offset+1))))
        offset += MemoryLayout<UInt16>.size // 2

        setVector_y(vector_y_in_byte: [UInt8](data.subdata(in: Range(offset...offset+1))))
        offset += MemoryLayout<UInt16>.size // 2

        setVector_z(vector_z_in_byte: [UInt8](data.subdata(in: Range(offset...offset+1))))
        offset += MemoryLayout<UInt16>.size // 2
        
        print("s_tick : \(self.s_tick)")
        print("s_tick_date : " + unixtimeToString(unixtime: time_t(self.s_tick)))
        print("e_tick : \(self.e_tick)")
        print("e_tick_date : " + unixtimeToString(unixtime: time_t(self.e_tick)))
        print("steps : \(self.steps)")
        print("t_lux : \(self.t_lux)")
        print("avg_lux : \(self.avg_lux)")
        print("avg_k : \(self.avg_k)")
        print("vector_x : \(self.vector_x)")
        print("vector_y : \(self.vector_y)")
        print("vector_z : \(self.vector_z)")
    }
    
    public func setS_tick(s_tick_in_byte: [UInt8]) {
        self.s_tick = convertUInt32(bytes: s_tick_in_byte, isLittleEndian: true)
//        print("s_tick : \(self.s_tick)")
    }

    public func setE_tick(e_tick_in_byte: [UInt8]) {
        self.e_tick = convertUInt32(bytes: e_tick_in_byte, isLittleEndian: true)
//        print("e_tick : \(self.e_tick)")
    }

    public func setSteps(steps_in_byte: [UInt8]) {
        self.steps = convertUInt16(bytes: steps_in_byte, isLittleEndian: true)
//        print("steps : \(self.steps)")
    }

    public func setT_lux(t_lux_in_byte: [UInt8]) {
        self.t_lux = convertUInt32(bytes: t_lux_in_byte, isLittleEndian: true)
//        print("t_lux : \(self.t_lux)")
    }

    public func setAvg_lux(avg_lux_in_byte: [UInt8]) {
        self.avg_lux = convertUInt16(bytes: avg_lux_in_byte, isLittleEndian: true)
//        print("avg_lux : \(self.avg_lux)")
    }

    public func setAvg_k(avg_k_in_byte: [UInt8]) {
        self.avg_k = convertUInt16(bytes: avg_k_in_byte, isLittleEndian: true)
//        print("avg_k : \(self.avg_k)")
    }

    public func setVector_x(vector_x_in_byte: [UInt8]) {
        self.vector_x = convertUInt16(bytes: vector_x_in_byte, isLittleEndian: true)
//        print("vector_x : \(self.vector_x)")
    }

    public func setVector_y(vector_y_in_byte: [UInt8]) {
        self.vector_y = convertUInt16(bytes: vector_y_in_byte, isLittleEndian: true)
//        print("vector_y : \(self.vector_y)")
    }

    public func setVector_z(vector_z_in_byte: [UInt8]) {
        self.vector_z = convertUInt16(bytes: vector_z_in_byte, isLittleEndian: true)
//        print("vector_z : \(self.vector_z)")
    }

    public func size() -> Int {
        return 24
    }
}

//public class KittyDoc_10_Min_Data {
//    public int s_tick;      // 이 정보의 시작 시간
//    public int e_tick;      // 이 정보의 마지막 시간
//    public short steps;     // 걸음수
//    public int t_lux;     // 이 기간 동안 누적 조도량
//    public short avg_lux;   // 평균 조도량 (누적 조도량/걸음수) : 걸음수는 로깅 정보의 갯수임.
//    public short avg_k;     // 평균 색온도 in kelvin
//    public short vector_x;
//    public short vector_y;
//    public short vector_z;
//
//    public Sleepdoc_10_min_data_type() {
//    }
//
//    public Sleepdoc_10_min_data_type(int s_tick, int e_tick, short steps, int t_lux, short avg_lux, short avg_k, short vector_x, short vector_y, short vector_z) {
//        this.s_tick = s_tick; //4
//        this.e_tick = e_tick;  //4
//        this.steps = steps;  //2
//        this.t_lux = t_lux;  //4
//        this.avg_lux = avg_lux;  //2
//        this.avg_k = avg_k; //2
//        this.vector_x = vector_x; //2
//        this.vector_y = vector_y; //2
//        this.vector_z = vector_z; //2
//    }
//
//    public Sleepdoc_10_min_data_type(byte[] data) {
//        Log.i("data", "length : " + data.length);
//        int offset = 0;
//        byte[] s_tick = new byte[4];
//        System.arraycopy(data, offset, s_tick, 0, s_tick.length);
//        setS_tick(s_tick);
//        offset += s_tick.length;
//        Date now = new Date( this.s_tick);
//        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
//        Log.i("data", "s_tick : " + this.s_tick);
//        Log.i("data", "s_tick_date : " + sdf.format(now));
//
//        byte[] e_tick = new byte[4];
//        System.arraycopy(data, offset, e_tick, 0, e_tick.length);
//        setE_tick(e_tick);
//        offset += e_tick.length;
//        Log.i("data", "e_tick : " + this.e_tick);
//
//        byte[] steps = new byte[2];
//        System.arraycopy(data, offset, steps, 0, steps.length);
//        setSteps(steps);
//        offset += steps.length;
//        Log.i("data", "steps : " + this.steps);
//
//        byte[] t_lux = new byte[4];
//        System.arraycopy(data, offset, t_lux, 0, t_lux.length);
//        setT_lux(t_lux);
//        offset += t_lux.length;
//        Log.i("data", "t_lux : " + this.t_lux);
//
//        byte[] avg_lux = new byte[2];
//        System.arraycopy(data, offset, avg_lux, 0, avg_lux.length);
//        setAvg_lux(avg_lux);
//        offset += avg_lux.length;
//        Log.i("data", "avg_lux : " + this.avg_lux);
//
//        byte[] avg_k = new byte[2];
//        System.arraycopy(data, offset, avg_k, 0, avg_k.length);
//        setAvg_k(avg_k);
//        offset += avg_k.length;
//        Log.i("data", "avg_k : " + this.avg_k);
//
//        byte[] vector_x = new byte[2];
//        System.arraycopy(data, offset, vector_x, 0, vector_x.length);
//        setVector_x(vector_x);
//        offset += vector_x.length;
//        Log.i("data", "vector_x : " + this.vector_x);
//
//
//        byte[] vector_y = new byte[2];
//        System.arraycopy(data, offset, vector_y, 0, vector_y.length);
//        setVector_y(vector_y);
//        offset += vector_y.length;
//        Log.i("data", "vector_y : " + this.vector_y);
//
//        byte[] vector_z = new byte[2];
//        System.arraycopy(data, offset, vector_z, 0, vector_z.length);
//        setVector_z(vector_z);
//        Log.i("data", "vector_z : " + this.vector_z);
//    }
//

//
//    public static int size() {
//        return 24;
//    }
//
//    @Override
//    public String toString() {
//        return "Sleepdoc_10_min_data_type{" +
//                "s_tick=" + s_tick +
//                ", e_tick=" + e_tick +
//                ", steps=" + steps +
//                ", t_lux=" + t_lux +
//                ", avg_lux=" + avg_lux +
//                ", avg_k=" + avg_k +
//                '}';
//    }
//}
