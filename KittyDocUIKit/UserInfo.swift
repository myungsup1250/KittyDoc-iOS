//
//  UserInfo.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/16.
//

import Foundation

enum GenderType: String, CaseIterable {//, Codable {
    case male
    case female
    case none
}

struct UserInfo {
    static let shared = UserInfo() // let Email = UserInfo.shared.Email
    
    var loggedInPrev: Bool// = false // 여기서 관리?
    var wantsRememberEmail: Bool// = false
    var wantsAutoLogin: Bool// = false
    var wantsDarkTheme: Bool// = false
    var massUnit: String// = "Kg"

    var uniqueId: Int = -1//String = "-1"
    
    var userEmail: String
    var userPw: String
    var userName:String
    var userPhone:String
    var userGender:String
    var userBirth:String
    var userID:String
}

extension UserInfo {
    init() {
        userEmail = ""
        userPw = ""
        userName = ""
        userPhone = ""
        userGender = ""
        userID = ""
//        let plist = UserDefaults.standard
//        let userDict: [String : Any]? = plist.dictionary(forKey: "UserInfo") // Dictionary
////        var temp: UserInfo? = plist.object(forKey: "UserInfo") as? UserInfo // UserInfo 객체를 통채로?
//
//        // Support multiple Accounts?
//        // Saves One Account Only (Now)
//        if userDict != nil {
//            loggedInPrev = userDict!["LogginInPrev"] as! Bool
//            wantsRememberEmail = userDict!["WantsRememberEmail"] as! Bool
//            wantsAutoLogin = userDict!["WantsAutoLogIn"] as! Bool
//            wantsDarkTheme = userDict!["WantsDarkTheme"] as! Bool
//            massUnit = userDict!["MassUnit"] as! String
//            uniqueId = userDict!["uniqueId"] as! Int
//            userEmail = userDict!["Email"] as! String
//            userPw = userDict!["Pw"] as! String
//            userName = userDict!["FirstName"] as! String
//            userPhone = userDict!["LastName"] as! String
//            userGender = userDict!["Address"] as! String
//            userBirth = userDict!["Gender"] as! String
//            userID = userDict!["Gender"] as! String
//        } else {
//            loggedInPrev = false
//            wantsRememberEmail = false
//            wantsAutoLogin = false
//            wantsDarkTheme = false
//            massUnit = ""//"Kg"
//            uniqueId = -1
//
//            userEmail = ""
//            userPw = ""
//            userName = ""
//            userPhone = ""
//            userGender = ""
//            userID = ""
//        }
//
////        if temp != nil {
////            self.loggedInPrev = temp!.loggedInPrev
////        }
    }
}
