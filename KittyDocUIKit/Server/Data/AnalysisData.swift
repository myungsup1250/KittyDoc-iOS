//
//  AnalysisData.swift
//  KittyDocUIKit
//
//  Created by ImHyunWoo on 2021/02/23.
//

import Foundation

class AnalysisData:ServerData{
    var petID: Int
    var frontTime: Int
    var rearTime: Int
    
    init(_petID: Int, _frontTime: Int, _rearTime: Int){
        self.petID = _petID
        self.frontTime = _frontTime
        self.rearTime = _rearTime
    }
    
    func data() -> Data{
        let data:String = "petID" + "=" + String(petID)
            + "&" + "frontTime" + "=" + String(frontTime)
            + "&" + "rearTime" + "=" + String(rearTime)
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
