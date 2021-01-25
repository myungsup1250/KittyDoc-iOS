//
//  SignUpData_Pet.swift
//  KittyDocUIKit
//
//  Created by 임현진 on 2021/01/25.
//

import Foundation

class SignUpData_Pet:ServerData{
    var petName:String
    var ownerId:String
    var petKG:String
    var petLB:String
    var petSex:String
    var petBirth:String
    var device:String
    
    init(_petName:String, _ownerId:String, _petKG:String, _petLB:String, _petSex:String,
         _petBirth:String, _device:String){
        self.petName = _petName
        self.ownerId = _ownerId
        self.petKG = _petKG
        self.petLB = _petLB
        self.petSex = _petSex
        self.petBirth = _petBirth
        self.device = _device
    }
    
    func data() -> Data{
        let data:String = "petName" + "=" + petName
            + "&" + "ownerId" + "=" + ownerId
            + "&" + "petKG" + "=" + petKG
            + "&" + "petLB" + "=" + petLB
            + "&" + "petSex" + "=" + petSex
            + "&" + "petBirth" + "=" + petBirth
            + "&" + "device" + "=" + device
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
