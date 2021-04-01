//
//  AnalysisData_Year.swift
//  KittyDocUIKit
//
//  Created by ImHyunWoo on 2021/03/18.
//

import Foundation

class AnalysisData_Year:ServerData{
    var petID: Int
    var year: Int
    var offset: Int
    
    init(_petID: Int, _year: Int){
        self.petID = _petID
        self.year = _year
        //android와 offset부호가 반대인 관계로 -1 곱함.
        self.offset = TimeZone.current.secondsFromGMT() / 60 * (-1)
    }
    
    func data() -> Data{
        let data:String = "petID" + "=" + String(petID)
            + "&" + "year" + "=" + String(year)
            + "&" + "offset" + "=" + String(offset)
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
