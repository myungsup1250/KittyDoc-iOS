//
//  ModifyData.swift
//  KittyDocUIKit
//
//  Created by ImHyunWoo on 2021/03/07.
//

import Foundation

class ModifyData:ServerData{
    var userId: Int
    var userName: String
    var userPhone: String
    var userSex: String
    var userBirth: String
    
    init(_userId: Int, _userName: String, _userPhone: String, _userSex: String, _userBirth:String){
        self.userId = _userId
        self.userName = _userName
        self.userPhone = _userPhone
        self.userSex = _userSex
        self.userBirth = _userBirth
    }
    
    func data() -> Data{
        let data:String = "userId" + "=" + String(userId)
            + "&" + "userName" + "=" + String(userName)
            + "&" + "userPhone" + "=" + String(userPhone)
            + "&" + "userSex" + "=" + String(userSex)
            + "&" + "userBirth" + "=" + String(userBirth)
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
