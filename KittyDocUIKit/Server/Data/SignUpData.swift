//
//  SignUpData.swift
//  KittyDocUIKit
//
//  Created by 임현진 on 2021/01/22.
//

import Foundation

class SignUpData:ServerData{
    var userEmail:String
    var userPwd:String
    var userName:String
    var userPhone:String
    var userSex:String
    var userBirth:String
    
    init(_userEmail:String, _userPwd:String, _userName:String, _userPhone:String, _userSex:String, _userBirth:String){
        self.userEmail = _userEmail
        self.userPwd = _userPwd
        self.userName = _userName
        self.userPhone = _userPhone
        self.userSex = _userSex
        self.userBirth = _userPhone
    }
    
    func data() -> Data{
        let data:String = "userEmail" + "=" + userEmail
            + "&" + "userPwd" + "=" + userPwd
            + "&" + "userName" + "=" + userName
            + "&" + "userPhone" + "=" + userPhone
            + "&" + "userSex" + "=" + userSex
            + "&" + "userBirth" + "=" + userBirth
        return data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
