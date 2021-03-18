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
    
    init(_petID: Int, _year: Int, _offset: Int){
        self.petID = _petID
        self.year = _year
        self.offset = _offset
    }
    
    func data() -> Data{
        let data:String = "petID" + "=" + String(petID)
            + "&" + "year" + "=" + String(year)
            + "&" + "offset" + "=" + String(offset)
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
