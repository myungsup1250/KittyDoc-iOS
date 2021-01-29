//
//  PetInfo.swift
//  KittyDocUIKit
//
//  Created by 임현진 on 2021/01/29.
//

import Foundation
class PetInfo{
    var PetID:Int
    var PetName:String
    var OwnerID:Int
    var PetKG:Double
    var PetLB:Double
    var PetSex:String
    var PetBirth:String
    var Device:String
    
    init(){
        self.PetID = -1
        self.PetName = ""
        self.OwnerID = -1
        self.PetKG = 0
        self.PetLB = 0
        self.PetSex = ""
        self.PetBirth = ""
        self.Device = ""
    }
}
