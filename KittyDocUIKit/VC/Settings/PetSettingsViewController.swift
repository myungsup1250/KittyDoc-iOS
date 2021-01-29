//
//  PetSettingsViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/20.
//

import UIKit

class PetSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var PetArray:[PetInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "냥이 설정"
        self.navigationItem.prompt = "냥이를 등록해주세요!"
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        
        ////////
        let findData:FindData_Pet = FindData_Pet(_ownerId: UserInfo.shared.UserID)
        let server:KittyDocServer = KittyDocServer()
        let findResponse:ServerResponse = server.petFind(data: findData)
        
        if(findResponse.getCode() as! Int == ServerResponse.FIND_SUCCESS){
            let jsonString:String = findResponse.getMessage() as! String
            if let arrData = jsonString.data(using: .utf8){
                do{
                    if let jsonArray = try JSONSerialization.jsonObject(with: arrData, options: .allowFragments) as? [AnyObject]{
                        for i in 0..<jsonArray.count{
                            let petInfo:PetInfo = PetInfo()
                            petInfo.PetID = jsonArray[i]["PetID"] as! Int
                            petInfo.PetName = jsonArray[i]["PetName"] as! String
                            petInfo.OwnerID = jsonArray[i]["OwnerID"] as! Int
                            //petkg과 petlb를 서버에서 string으로 다루고 있는 오류가 있어서, 추후에 그부분이 수정되면
                            //이곳도 수정필요!
                            //petInfo.PetKG = jsonArray[i]["PetKG"] as! Double
                            //petInfo.PetLB = jsonArray[i]["PetLB"] as! Double
                            petInfo.PetKG = 0
                            petInfo.PetLB = 0
                            petInfo.PetSex = jsonArray[i]["PetSex"] as! String
                            petInfo.PetBirth = jsonArray[i]["PetBirth"] as! String
                            petInfo.Device = jsonArray[i]["Device"] as! String
                            PetArray.append(petInfo)
                        }
                    }
                } catch{
                    print("JSON 파싱 에러")
                }
            }
        }else if(findResponse.getCode() as! Int == ServerResponse.FIND_FAILURE){
            alertWithMessage(message: findResponse.getMessage())
        }
    }
    
    
    private let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //MARK: count
        return 10
    }
    
    func alertWithMessage(message input: Any) {
        let alert = UIAlertController(title: "", message: input as? String, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        self.present(alert, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //MARK: 배열 넘기고가~!!~
        //RE: 펫 등록 화면 실행될때 이 함수는 되게 여러번 호출이 되어서 한번 호출되는 viewDidLoad에서 진행할게!
        let cell = UITableViewCell()
        return cell
    }
    
}
