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
    
    func doRequestTask(url: URL, data: ServerData) -> ServerResponse{
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data.data()
        
        let serverResponse:ServerResponse = ServerResponse()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with:data, options:[])
            if let responseJSON = responseJSON as? [String: Any] {
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
        let url = URL(string:(baseUrl + port + "/user/login"))!
        return doRequestTask(url: url, data: data)
    }
    
    func userSignUp(data:SignUpData) -> ServerResponse {
        let url = URL(string:(baseUrl + port + "/user/join"))!
        return doRequestTask(url: url, data: data)
    }
    
    func userExist(data:ExistData) -> ServerResponse {
        let url = URL(string:(baseUrl + port + "/user/existEmail"))!
        return doRequestTask(url: url, data: data)
    }
    
    func petSignUp(data: SignUpData_Pet) -> ServerResponse {
        let url = URL(string:(baseUrl + port + "/pet/join"))!
        return doRequestTask(url: url, data: data)
    }
    
    func petFind(data: FindData_Pet) -> ServerResponse {
        let url = URL(string:(baseUrl + port + "/pet/find"))!
        return doRequestTask(url: url, data: data)
    }
    
    func petDelete(data: DeleteData_Pet) -> ServerResponse {
        let url = URL(string:(baseUrl + port + "/pet/delete"))!
        return doRequestTask(url: url, data: data)
    }
    
    func petModify(data: ModifyData_Pet) -> ServerResponse {
        let url = URL(string:(baseUrl + port + "/pet/modify"))!
        return doRequestTask(url: url, data: data)
    }
    
    func sensorSend(data: SensorData) -> ServerResponse {
        let url = URL(string:(baseUrl + port + "/sensor/send"))!
        return doRequestTask(url: url, data: data)
    }
    
    func waterSend(data: WaterData) -> ServerResponse {
        let url = URL(string:(baseUrl + port + "/water/send"))!
        return doRequestTask(url: url, data: data)
    }
    
    func sensorRequestYear(data: AnalysisData_Year) -> ServerResponse {
        let url = URL(string:(baseUrl + port + "/pet/analysis/year"))!
        return doRequestTask(url: url, data: data)
    }
    
    func sensorRequestDay(data: AnalysisData) -> ServerResponse {
        let url = URL(string:(baseUrl + port + "/pet/analysis/day"))!
        return doRequestTask(url: url, data: data)
    }
    
    func sensorRequestHour(data: AnalysisData) -> ServerResponse {
        let url = URL(string:(baseUrl + port + "/pet/analysis/hour"))!
        return doRequestTask(url: url, data: data)
    }
    
    func userModify(data: ModifyData) -> ServerResponse {
        let url = URL(string:(baseUrl + port + "/user/edit"))!
        return doRequestTask(url: url, data: data)
    }
    init(){}
}
