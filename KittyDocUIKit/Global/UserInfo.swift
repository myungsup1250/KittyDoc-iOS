//
//  UserInfo.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/16.
//

import Foundation

class UserInfo {
    static let shared: UserInfo = UserInfo()
    
    var loggedInPrev: Bool// = false // 여기서 관리?
    var wantsRememberEmail: Bool// = false
    var wantsAutoLogin: Bool// = false
    var wantsDarkTheme: Bool// = false
    var massUnit: String// = "Kg"

    var UserID: Int
    var UserPhone: String
    var UserBirth: String
    var Email: String
    var Pw: String
    var Name: String
    var gender: String// male / female / none

    private init() {
        //print("UserInfo.init()")
//        let plist = UserDefaults.standard
//        let userDict: [String : Any]? = plist.dictionary(forKey: "UserInfo") // Dictionary
//        var temp: UserInfo? = plist.object(forKey: "UserInfo") as? UserInfo // UserInfo 객체를 통채로?
        
        // Support multiple Accounts?
        // Saves One Account Only (Now)
//        if userDict != nil {
//            loggedInPrev = userDict!["LogginInPrev"] as! Bool
//            wantsRememberEmail = userDict!["WantsRememberEmail"] as! Bool
//            wantsAutoLogin = userDict!["WantsAutoLogIn"] as! Bool
//            wantsDarkTheme = userDict!["WantsDarkTheme"] as! Bool
//            massUnit = userDict!["MassUnit"] as! String
//            uniqueId = userDict!["uniqueId"] as! Int
//            Email = userDict!["Email"] as! String
//            Pw = userDict!["Pw"] as! String
//            firstName = userDict!["FirstName"] as! String
//            lastName = userDict!["LastName"] as! String
//            address = userDict!["Address"] as! String
//            gender = userDict!["Gender"] as! String
//            UserID = -1
//            UserPhone = ""
//            UserBirth = ""
//        } else {
            loggedInPrev = false
            wantsRememberEmail = false
            wantsAutoLogin = false
            wantsDarkTheme = false
            massUnit = ""
            Email = ""
            Pw = ""
            Name = ""
            gender = ""
            UserID = -1
            UserPhone = ""
            UserBirth = ""
 //       }
        
//        if temp != nil {
//            self.loggedInPrev = temp!.loggedInPrev
//        }
    }
}
