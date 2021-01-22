//
//  LoginData.swift
//  KittyDoc
//
//  Created by 임현진 on 2021/01/11.
//  Copyright © 2021 Myungsup. All rights reserved.
//

import Foundation

class LoginData:ServerData{
    var userEmail:String
    var userPwd:String
    
    init(_userEmail:String, _userPwd:String){
        self.userEmail = _userEmail
        self.userPwd = _userPwd
    }
    
    func data() -> Data{
        let data:String = "userEmail" + "=" + userEmail + "&" + "userPwd" + "=" + userPwd
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
