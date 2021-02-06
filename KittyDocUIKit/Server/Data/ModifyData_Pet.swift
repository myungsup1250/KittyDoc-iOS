//
//  ModifyData_Pet.swift
//  KittyDocUIKit
//
//  Created by 임현진 on 2021/02/04.
//

import Foundation

class ModifyData_Pet:ServerData{
    var ownerId: Int
    var petId: Int
    var petName: String
    var petKG: String
    var petLB: String
    var petSex: String
    var petBirth: String
    var device: String
    
    init( _ownerId: Int, _petId: Int, _petName: String, _petKG: String, _petLB: String, _petSex: String, _petBirth: String, _device: String){
        self.ownerId = _ownerId
        self.petId = _petId
        self.petName = _petName
        self.petKG = _petKG
        self.petLB = _petLB
        self.petSex = _petSex
        self.petBirth = _petBirth
        self.device = _device
    }

    func data() -> Data{
        let data: String = "ownerId" + "=" + String(ownerId)
            + "&" + "petId" + "=" + String(petId)
            + "&" + "petName" + "=" + petName
            + "&" + "petKG" + "=" + String(petKG)
            + "&" + "petLB" + "=" + String(petLB)
            + "&" + "petSex" + "=" + petSex
            + "&" + "petBirth" + "=" + petBirth
            + "&" + "device" + "=" + device
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
