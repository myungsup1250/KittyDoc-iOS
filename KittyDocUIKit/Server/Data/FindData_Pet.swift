//
//  FindData_Pet.swift
//  KittyDocUIKit
//
//  Created by 임현진 on 2021/01/29.
//

import Foundation

class FindData_Pet:ServerData{
    var ownerId:Int
    
    init(_ownerId:Int){
        self.ownerId = _ownerId
    }
    
    func data() -> Data{
        let data:String = "ownerId" + "=" + String(ownerId);
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
