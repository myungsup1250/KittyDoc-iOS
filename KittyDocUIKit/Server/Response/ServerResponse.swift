//
//  ServerResponse.swift
//  KittyDocUIKit
//
//  Created by 임현진 on 2021/01/17.
//

import Foundation

class ServerResponse{
    public static let JOIN_SUCCESS: Int = 100
    public static let JOIN_FAILURE: Int = 101
    public static let LOGIN_SUCCESS: Int = 200
    public static let LOGIN_FAILURE: Int = 201
    public static let LOGIN_WRONG_EMAIL: Int = 203
    public static let LOGIN_WRONG_PWD: Int = 204
    public static let EXIST_IS_EXIST: Int = 300
    public static let EXIST_NOT_EXIST: Int = 301
    public static let EDIT_SUCCESS: Int = 400
    public static let EDIT_FAILURE: Int = 401
    public static let FIND_SUCCESS: Int = 500
    public static let FIND_FAILURE: Int = 501
    public static let SENSOR_SUCCESS: Int = 600
    public static let SENSOR_FAILURE: Int = 601
    public static let PET_DELETE_SUCCESS: Int = 800
    public static let PET_DELETE_FAILURE: Int = 801
    public static let PET_MODIFY_SUCCESS: Int = 900
    public static let PET_MODIFY_FAILURE: Int = 901
    
    public var code: Any
    public var message: Any
    
    init() {
        self.code = 0
        self.message = ""
    }
    
    init(_data:[String:Any]) {
        self.code = _data["code"] as! Int
        self.message = _data["message"] as! String
    }
    
    func getCode() -> Any {
        return self.code
    }
    
    func getMessage() -> Any {
        return self.message
    }
    
    func setCode(_code:Any) {
        self.code = _code
    }
    
    func setMessage(_message:Any) {
        self.message = _message
    }
}
