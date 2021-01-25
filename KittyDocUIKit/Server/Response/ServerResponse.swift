//
//  ServerResponse.swift
//  KittyDocUIKit
//
//  Created by 임현진 on 2021/01/17.
//

import Foundation

class ServerResponse{
    public static let JOIN_SUCCESS:Int = 100
    public static let JOIN_FAILURE:Int = 101
    public static let LOGIN_SUCCESS:Int = 200
    public static let LOGIN_FAILURE:Int = 201
    public static let LOGIN_WRONG_EMAIL:Int = 203
    public static let LOGIN_WRONG_PWD:Int = 204
    public static let EXIST_IS_EXIST:Int = 300
    public static let EXIST_NOT_EXIST:Int = 301
    public static let EDIT_SUCCESS:Int = 400
    public static let EDIT_FAILURE:Int = 401
    
    public var code:Any
    public var message:Any
    
    init(){
        self.code=0
        self.message=""
    }
    
    init(_data:[String:Any]){
        self.code = _data["code"] as! Int
        self.message = _data["message"] as! String
    }
    
    func getCode() -> Any {
        return self.code
    }
    
    func getMessage() -> Any {
        return self.message
    }
    
    func setCode(_code:Any){
        self.code = _code
    }
    
    func setMessage(_message:Any){
        self.message = _message
    }
}