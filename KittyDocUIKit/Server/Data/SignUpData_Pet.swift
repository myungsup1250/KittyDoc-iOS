//
//  SignUpData_Pet.swift
//  KittyDocUIKit
//
//  Created by 임현진 on 2021/01/25.
//

import Foundation

class SignUpData_Pet:ServerData{
    var petName: String
    var ownerId: Int
    var petKG: String
    var petLB: String
    var petSex: String
    var petBirth: String
    var device: String
    
    init(_petName: String, _ownerId: Int, _petKG: String, _petLB: String, _petSex: String,
         _petBirth: String, _device: String){
        self.petName = _petName
        self.ownerId = _ownerId
        self.petKG = _petKG
        self.petLB = _petLB
        self.petSex = _petSex
        self.petBirth = _petBirth
        self.device = _device
    }
    
    // // // // // // // // // // // // // // // // // // // //
    func data() -> Data{
        let data: String = "petName" + "=" + petName
            + "&" + "ownerId" + "=" + String(ownerId)
            + "&" + "petKG" + "=" + petKG
            + "&" + "petLB" + "=" + petLB
            + "&" + "petSex" + "=" + petSex
            + "&" + "petBirth" + "=" + petBirth
            + "&" + "device" + "=" + device
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
    //Mappable, Codable 적용 가능 여부 확인 필요... 21.02.04
    // // // // // // // // // // // // // // // // // // // //
}
