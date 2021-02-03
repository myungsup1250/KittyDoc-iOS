//
//  ServerApi.swift
//  KittyDoc
//
//  Created by 임현진 on 2021/01/11.
//  Copyright © 2021 Myungsup. All rights reserved.
//

import Foundation

protocol ServerApi{
    var baseUrl: String {get set}
    var port: String {get set}
    func userLogin(data:LoginData) -> ServerResponse;
    func userSignUp(data:SignUpData) -> ServerResponse;
    func userExist(data:ExistData) -> ServerResponse;
    func petSignUp(data:SignUpData_Pet) -> ServerResponse;
    func petFind(data:FindData_Pet) -> ServerResponse;
    func sensorSend(data:SensorData) -> ServerResponse;
}
