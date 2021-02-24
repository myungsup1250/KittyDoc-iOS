//
//  WaterData.swift
//  KittyDocUIKit
//
//  Created by ImHyunWoo on 2021/02/22.
//

import Foundation

class WaterData:ServerData{
    var petID: Int
    var tick: Int
    var waterVal: Int
    
    init(_petID: Int, _tick: Int, _waterVal: Int){
        self.petID = _petID
        self.tick = _tick
        self.waterVal = _waterVal
    }
    
    func data() -> Data{
        let data:String = "petID" + "=" + String(petID)
            + "&" + "tick" + "=" + String(tick)
            + "&" + "waterVal" + "=" + String(waterVal)
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
