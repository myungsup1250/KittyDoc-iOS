//
//  ModifyData_Pwd.swift
//  KittyDocUIKit
//
//  Created by ImHyunWoo on 2021/04/08.
//

import Foundation

class ModifyData_Pwd:ServerData{
    var userEmail: String
    var userPwd: String
    
    init(_userEmail: String, _userPwd: String){
        self.userEmail = _userEmail
        self.userPwd = _userPwd
    }
    
    func data() -> Data{
        let data:String = "userEmail" + "=" + userEmail
            + "&" + "userPwd" + "=" + userPwd
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
