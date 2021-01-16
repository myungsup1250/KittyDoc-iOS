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
    var Email: String// = "myungsup1250@gmail.com"
    var Pw: String// = "ms5892"
    var firstName: String// = "Myungsup"
    var lastName: String// = "Kwak"
    var address: String// = "서울특별시 노원구 광운로 광운대학교"
    var gender: String// = GenderType.male //"male" // male / female / none

}

extension UserInfo {
    init() {
        let plist = UserDefaults.standard
        let userDict: [String : Any]? = plist.dictionary(forKey: "UserInfo") // Dictionary
        
        // Support multiple Accounts?
        // Saves One Account Only (Now)
        if userDict != nil {
            loggedInPrev = userDict!["LogginInPrev"] as! Bool
            wantsRememberEmail = userDict!["WantsRememberEmail"] as! Bool
            wantsAutoLogin = userDict!["WantsAutoLogIn"] as! Bool
            wantsDarkTheme = userDict!["WantsDarkTheme"] as! Bool
            massUnit = userDict!["MassUnit"] as! String
            uniqueId = userDict!["uniqueId"] as! Int
            Email = userDict!["Email"] as! String
            Pw = userDict!["Pw"] as! String
            firstName = userDict!["FirstName"] as! String
            lastName = userDict!["LastName"] as! String
            address = userDict!["Address"] as! String
            gender = userDict!["Gender"] as! String
        } else {
            loggedInPrev = false
            wantsRememberEmail = false
            wantsAutoLogin = false
            wantsDarkTheme = false
            massUnit = ""//"Kg"
            uniqueId = -1
            Email = ""
            Pw = ""
            firstName = ""
            lastName = ""
            address = ""
            gender = ""
        }
    }
}
