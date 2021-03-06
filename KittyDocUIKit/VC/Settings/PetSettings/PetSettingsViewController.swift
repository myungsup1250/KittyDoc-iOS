//
//  PetSettingsViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/20.
//

import UIKit

class PetSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "냥이 설정"
        self.navigationItem.prompt = "냥이를 등록해주세요!"
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //viewWillAppear에다가 해놓으면 이 뷰가 나타나려고 할 때마다 호출됨!
        let findData:FindData_Pet = FindData_Pet(_ownerId: UserInfo.shared.UserID)
        let server:KittyDocServer = KittyDocServer()
        let findResponse:ServerResponse = server.petFind(data: findData)
        
        if(findResponse.getCode() as! Int == ServerResponse.FIND_SUCCESS) {
            let jsonString:String = findResponse.getMessage() as! String
            if let arrData = jsonString.data(using: .utf8){
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: arrData, options: .allowFragments) as? [AnyObject]{
                        PetInfo.shared.petArray.removeAll()
                        for i in 0..<jsonArray.count {
                            let petInfo:PetInfo = PetInfo()
                            petInfo.PetID = jsonArray[i]["PetID"] as! Int
                            petInfo.PetName = jsonArray[i]["PetName"] as! String
                            petInfo.OwnerID = jsonArray[i]["OwnerID"] as! Int
                            //petkg과 petlb를 서버에서 string으로 다루고 있는 오류가 있어서, 추후에 그부분이 수정되면
                            //이곳도 수정필요!
                            petInfo.PetKG = jsonArray[i]["PetKG"] as! Double
                            petInfo.PetLB = jsonArray[i]["PetLB"] as! Double
                            petInfo.PetSex = jsonArray[i]["PetSex"] as! String
                            petInfo.PetBirth = jsonArray[i]["PetBirth"] as! String
                            petInfo.Device = jsonArray[i]["Device"] as! String
                            
                            PetInfo.shared.petArray.append(petInfo)
                        }
                    }
                } catch {
                    print("JSON 파싱 에러")
                }
            }
        } else if(findResponse.getCode() as! Int == ServerResponse.FIND_FAILURE) {
            PetInfo.shared.petArray.removeAll() // 다른 계정의 펫정보가 남아있는 경우를 방지하기 위해 배열을 비운다.
            alertWithMessage(message: findResponse.getMessage())
        }
        self.tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(PetTableViewCell.self, forCellReuseIdentifier: PetTableViewCell.identifier)
        return table
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PetInfo.shared.petArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = PetInfo.shared.petArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PetTableViewCell.identifier, for: indexPath) as! PetTableViewCell
        
        //cell.imageView?.image = retrieveImage(forKey: row.PetName)
        print("\(row.PetName) 이미지 가져옴")
        
        print("이게 이미지 데이터")
        print(UserDefaults.standard.data(forKey: row.PetName))
        
        
        if let imageData = UserDefaults.standard.data(forKey: row.PetName)
        {
            print("이미지 데이터 까지는 받아오는데 성공")
            if let imageFromData = UIImage(data: imageData)
            {
                cell.imageView?.image = imageFromData
                print("이미지 설정 성공!!!")
            }
        }
        
        //cell.imageView?.image = UIImage(systemName: "person")

        

        cell.petNameLabel.text = row.PetName
        cell.petDetailLabel.text = "\(row.PetSex)   \(row.PetKG)kg    \(row.PetBirth) 생"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let edit = editAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let deleteData:DeleteData_Pet = DeleteData_Pet(_petID: PetInfo.shared.petArray[indexPath.row].PetID, _ownerID: PetInfo.shared.petArray[indexPath.row].OwnerID)
            let server:KittyDocServer = KittyDocServer()
            let deleteResponse:ServerResponse = server.petDelete(data: deleteData)
            
            if(deleteResponse.getCode() as! Int == ServerResponse.PET_DELETE_SUCCESS){
                print(deleteResponse.getMessage())
                PetInfo.shared.petArray.remove(at: indexPath.row) //배열에서 지우고
                self.tableView.deleteRows(at: [indexPath], with: .automatic) //UI에서 지움!
                completion(true)
            } else {
                print(deleteResponse.getMessage())
            }
        }
        action.image = UIImage(systemName: "trash")
        action.backgroundColor = .systemRed
        return action
    }
    
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Edit") { (action, view, completion) in
            guard let vc = self.storyboard?.instantiateViewController(identifier: "PetSetting") as? AddPetViewController else {
                return
            }

            vc.editName = PetInfo.shared.petArray[indexPath.row].PetName
            vc.editWeight = PetInfo.shared.petArray[indexPath.row].PetKG
            vc.editBirth = PetInfo.shared.petArray[indexPath.row].PetBirth
            vc.editIsKg = PetInfo.shared.petArray[indexPath.row].IsKG
            vc.editGender = PetInfo.shared.petArray[indexPath.row].PetSex
            vc.editingPetID = indexPath.row
            vc.isEditMode = true
            vc.doneBtn.setTitle("수정", for: .normal)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        action.image = UIImage(systemName: "square.and.pencil")
        action.backgroundColor = .systemBlue
        return action
    }
    
    func alertWithMessage(message input: Any) {
        let alert = UIAlertController(title: "", message: input as? String, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        self.present(alert, animated: false)
    }
    
    func retrieveImage(forKey key: String) -> UIImage {

        if let imageData = UserDefaults.standard.data(forKey: "\(key)")
        {
            if let imageFromData = UIImage(data: imageData)
            {
                return imageFromData
            }
        }
        
        return UIImage(systemName: "person")!
        
    }
    
    
    
}
