//
//  HomeViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/16.
//

import UIKit

class HomeViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    override func viewDidLoad() {
        
        //홈에서 먼저 정보를 가져와야 배열이 생기기 때문에 일단은 복붙해두었음... 이건 고민해봅시당
        let findData:FindData_Pet = FindData_Pet(_ownerId: UserInfo.shared.UserID)
        let server:KittyDocServer = KittyDocServer()
        let findResponse:ServerResponse = server.petFind(data: findData)
        
        if(findResponse.getCode() as! Int == ServerResponse.FIND_SUCCESS) {
            let jsonString:String = findResponse.getMessage() as! String
            if let arrData = jsonString.data(using: .utf8){
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: arrData, options: .allowFragments) as? [AnyObject]{
                        for i in 0..<jsonArray.count{
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
                            
                            if !PetInfo.shared.petArray.contains(where: { (original: PetInfo) -> Bool in
                                return original.PetName == petInfo.PetName
                            }) {
                                PetInfo.shared.petArray.append(petInfo)
                            }
                        }
                    }
                } catch {
                    print("JSON 파싱 에러")
                }
            }
        } else if(findResponse.getCode() as! Int == ServerResponse.FIND_FAILURE) {
            //alertWithMessage(message: findResponse.getMessage())
            print("Error")
        }
        ////json parsing
        
    
        super.viewDidLoad()
        self.title = "Home"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(petNameSelectTF)
        petNameSelectTF.inputView = pickerView
        if !PetInfo.shared.petArray.isEmpty {
            petNameSelectTF.text = PetInfo.shared.petArray[0].PetName
        }
        
        view.addSubview(petSunEx)
        view.addSubview(petVitaD)
        view.addSubview(petExe)
        view.addSubview(petBreak)
        view.addSubview(petCal)
        view.addSubview(petWalk)
        view.addSubview(petLight)
        view.addSubview(petWater)
        view.addSubview(WaterBtn)
        
        PetChange(index: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PetInfo.shared.petArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PetInfo.shared.petArray[row].PetName
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        petNameSelectTF.text = PetInfo.shared.petArray[row].PetName //텍스트 필드 이름 변경
        PetChange(index: row) //표시되는 데이터들 변경
    } //펫이 선택되었을 때 호출되는 함수!!!
    
    
    func PetChange(index: Int) {
        //이 함수는 위의 pickerView(....didSelectRow...) 함수안에 있는 메소드야! (didSelectRow 저 함수는 피커뷰로 펫을 선택했을 때 호출되는 함수이고!) 보이는 데이터들을 변경해주려고 만든 함수임!!
        //PetInfo.shared.petArray[index] 이것이 펫 배열에서 펫 가져오기!
       
        //주석 풀고 괄호 사이에 펫 정보를 넣어주면됨! 햇빛 노출량 같은거??
//        petSunEx.text = "햇빛 노출량 : \()"
//        petVitaD.text = "비타민 D : \()"
//        petExe.text = "운동량 : \()"
//        petBreak.text = "휴식량 : \()"
//        petCal.text = "칼로리 : \()"
//        petWalk.text = "걸음수 : \()"
//        petLight.text = "빛 공해량: \()"
//        petWater.text = "수분량: \()"
        
    }
    
    
    lazy var pickerView: UIPickerView = {
       let picker = UIPickerView()
        picker.frame = CGRect(x: 0, y: 250, width: self.view.bounds.width, height: 180)
        picker.backgroundColor = .white
        picker.delegate = self
        picker.dataSource = self
        
        let doneBtn = UIBarButtonItem()
        doneBtn.title = "Done"
        doneBtn.target = self
        doneBtn.action = #selector(doneBtnPressed)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        toolBar.setItems([flexSpace, doneBtn], animated: true)
        petNameSelectTF.inputAccessoryView = toolBar
        
        return picker
    }()
    
    @objc func doneBtnPressed() {
        self.view.endEditing(true)
    }
    
    
    let petNameSelectTF: UITextField = {
        let petNameSelectTF = UITextField()
        petNameSelectTF.frame = CGRect(x: 150, y: 160, width: 100, height: 50)
        petNameSelectTF.placeholder = "냥냥"
        
        return petNameSelectTF
    }()
    
    
    let petSunEx: UILabel = {
        let sunex = UILabel()
        sunex.frame = CGRect(x: 100, y: 200, width: 300, height: 50)
        sunex.text = "햇빛 노출량 : "
        
        return sunex
    }()
    
    let petVitaD: UILabel = {
        let vitaD = UILabel()
        vitaD.frame = CGRect(x: 100, y: 250, width: 300, height: 50)
        vitaD.text = "비타민 D : "
        
        return vitaD
    }()
    
    let petExe: UILabel = {
        let exercise = UILabel()
        exercise.frame = CGRect(x: 100, y: 300, width: 300, height: 50)
        exercise.text = "산책량 : "
        
        return exercise
    }()
    
    let petBreak: UILabel = {
        let Break = UILabel()
        Break.frame = CGRect(x: 100, y: 350, width: 300, height: 50)
        Break.text = "운동량 : "
        
        return Break
    }()
    
    let petCal: UILabel = {
        let cal = UILabel()
        cal.frame = CGRect(x: 100, y: 400, width: 300, height: 50)
        cal.text = "칼로리 : "
        
        return cal
    }()
    
    let petWalk: UILabel = {
        let walk = UILabel()
        walk.frame = CGRect(x: 100, y: 450, width: 300, height: 50)
        walk.text = "걸음 수 : "
        
        return walk
    }()
    
    let petLight: UILabel = {
        let light = UILabel()
        light.frame = CGRect(x: 100, y: 500, width: 300, height: 50)
        light.text = "빛 공해량 : "
        
        return light
    }()
    
    let petWater: UILabel = {
        let water = UILabel()
        water.frame = CGRect(x: 100, y: 550, width: 300, height: 50)
        water.text = "수분량 : "
        
        return water
    }()
    
    let WaterBtn: UIButton = {
       let waterBtn = UIButton()
        waterBtn.frame = CGRect(x: 100, y: 600, width: 100, height: 50)
        waterBtn.setTitle("물", for: .normal)
        waterBtn.backgroundColor = .systemBlue
        waterBtn.addTarget(self, action: #selector(didTapWaterBtn), for: .touchUpInside)
        
        return waterBtn
    }()
    
    @objc func didTapWaterBtn() {
        let addWaterVC = self.storyboard!.instantiateViewController(identifier: "AddWater")
        present(addWaterVC, animated: true)
    }
    
    
    
   
    
   

}

