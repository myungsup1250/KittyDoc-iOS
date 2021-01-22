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
}
