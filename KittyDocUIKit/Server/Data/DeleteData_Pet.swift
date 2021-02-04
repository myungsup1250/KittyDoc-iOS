//
//  SensorData.swift
//  KittyDocUIKit
//
//  Created by 임현진 on 2021/02/04.
//

import Foundation

class DeleteData_Pet:ServerData{
    var petID:Int
    var ownerID:Int
    
    init(_petID: Int, _ownerID: Int){
        self.petID = _petID
        self.ownerID = _ownerID
    }
    
    func data() -> Data{
        let data:String = "petID" + "=" + String(petID)
            + "&" + "ownerID" + "=" + String(ownerID)
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
