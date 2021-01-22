//
//  KittyDocServer.swift
//  KittyDoc
//
//  Created by 임현진 on 2021/01/11.
//  Copyright © 2021 Myungsup. All rights reserved.
//

import Foundation

class KittyDocServer:ServerApi{
    var baseUrl: String = "http://52.78.116.210"
    var port: String =  ":3000"
    let semaphore = DispatchSemaphore(value: 0)
    
    func doRequestTask(url:URL, data:ServerData) -> ServerResponse{
        var request = URLRequest(url:url)
        request.httpMethod="POST"
        request.httpBody=data.data()
        
        var serverResponse:ServerResponse = ServerResponse()
        
        let task = URLSession.shared.dataTask(with: request){data, response, error in guard let data = data, error == nil else{
                    print(error?.localizedDescription ?? "No data")
                    return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with:data, options:[])
            if let responseJSON = responseJSON as? [String: Any]{
                serverResponse.setCode(_code: responseJSON["code"] as! Int)
                serverResponse.setMessage(_message: responseJSON["message"] as! String)
                self.semaphore.signal()
            }
        }
        task.resume()
        semaphore.wait()
        
        return serverResponse
    }
    
    func userLogin(data:LoginData) -> ServerResponse {
        //URL setting
        let url = URL(string:(baseUrl + port + "/user/login"))!
        return doRequestTask(url: url, data: data)
    }
    
    init(){}
}
