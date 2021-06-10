//
//  ModifyData_Weight.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/06/10.
//

import Foundation

class ModifyData_Weight:ServerData{
    var petId: Int
    var petKG: String
    var petLB: String
    
    init( _petId: Int, _petKG: String, _petLB: String){
        self.petId = _petId
        self.petKG = _petKG
        self.petLB = _petLB
    }

    func data() -> Data{
        let data: String = "petId" + "=" + String(petId)
            + "&" + "petKG" + "=" + String(petKG)
            + "&" + "petLB" + "=" + String(petLB)
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
