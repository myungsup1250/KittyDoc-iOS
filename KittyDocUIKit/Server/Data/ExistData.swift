//
//  ExistData.swift
//  KittyDocUIKit
//
//  Created by 임현진 on 2021/01/22.
//

import Foundation

class ExistData:ServerData{
    var userEmail:String
    
    init(_userEmail:String){
        self.userEmail = _userEmail
    }
    
    func data() -> Data{
        let data:String = "userEmail" + "=" + userEmail
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
