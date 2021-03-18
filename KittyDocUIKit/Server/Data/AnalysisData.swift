//
//  AnalysisData.swift
//  KittyDocUIKit
//
//  Created by ImHyunWoo on 2021/02/23.
//

import Foundation

class AnalysisData:ServerData{
    var petID: Int
    var startMilliSec: Int  //탐색 시작 시점
    var endMilliSec: Int    //탐색 종료 시점
    //startMilliSec가 endMilliSec보다 작아야 함!
    
    init(_petID: Int, _startMilliSec: Int, _endMilliSec: Int){
        self.petID = _petID
        self.startMilliSec = _startMilliSec
        self.endMilliSec = _endMilliSec
    }
    
    func data() -> Data{
        let data:String = "petID" + "=" + String(petID)
            + "&" + "startMilliSec" + "=" + String(startMilliSec)
            + "&" + "endMilliSec" + "=" + String(endMilliSec)
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
