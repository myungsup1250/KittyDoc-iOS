//
//  SensorData.swift
//  KittyDocUIKit
//
//  Created by 임현진 on 2021/02/03.
//

import Foundation

class SensorData:ServerData{
    var petID:Int
    var petLB:Double
    var s_tick:Int
    var e_tick:Int
    var steps:CShort
    var t_lux:Int
    var avg_lux:CShort
    var avg_k:CShort
    var vector_x:CShort
    var vector_y:CShort
    var vector_z:CShort
    
    init(_petID:Int, _petLB:Double, _s_tick:Int, _e_tick:Int, _steps:CShort, _t_lux:Int, _avg_lux:CShort, _avg_k:CShort, _vector_x:CShort, _vector_y:CShort, _vector_z:CShort){
        self.petID = _petID
        self.petLB = _petLB
        self.s_tick = _s_tick
        self.e_tick = _e_tick
        self.steps = _steps
        self.t_lux = _t_lux
        self.avg_lux = _avg_lux
        self.avg_k = _avg_k
        self.vector_x = _vector_x
        self.vector_y = _vector_y
        self.vector_z = _vector_z
    }
    
    init(_object:KittyDoc_10_Min_Data_Type, _petID:Int, _petLB:Double){
        self.petID = _petID
        self.petLB = _petLB
        self.s_tick = Int(_object.s_tick)
        self.e_tick = Int(_object.e_tick)
        self.steps = CShort(_object.steps)
        self.t_lux = Int(_object.t_lux)
        self.avg_lux = CShort(_object.avg_lux)
        self.avg_k = CShort(_object.avg_k)
        self.vector_x = CShort(_object.vector_x)
        self.vector_y = CShort(_object.vector_y)
        self.vector_z = CShort(_object.vector_z)
    }
    
    
    
    func data() -> Data{
        let data:String = "petID" + "=" + String(petID)
            + "&" + "petLB" + "=" + String(petLB)
            + "&" + "s_tick" + "=" + String(s_tick)
            + "&" + "e_tick" + "=" + String(e_tick)
            + "&" + "steps" + "=" + String(steps)
            + "&" + "t_lux" + "=" + String(t_lux)
            + "&" + "avg_lux" + "=" + String(avg_lux)
            + "&" + "avg_k" + "=" + String(avg_k)
            + "&" + "vector_x" + "=" + String(vector_x)
            + "&" + "vector_y" + "=" + String(vector_y)
            + "&" + "vector_z" + "=" + String(vector_z)
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
