//
//  AddPetViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/25.
//

import UIKit

class AddPetViewController: UIViewController {
    
    let deviceManager = DeviceManager.shared
    var birthInput: String?
    var isEditMode: Bool?
    var editingPetID: Int? //맘대로 바꿔도 됨
    
    var editName = ""
    var editWeight = 0.0
    var editIsKg = true
    var editGender = ""
    var editBirth = ""
    var editDevice = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        _ = setUpdatePicker()
        
        view.addSubview(image)
        view.addSubview(imageAddBtn)
        
        view.addSubview(stackView)
        
        weightStackView.addArrangedSubview(weightInput)
        weightStackView.addArrangedSubview(weightSelect)
        
        stackView.addArrangedSubview(nameInput)
        stackView.addArrangedSubview(weightStackView)
        stackView.addArrangedSubview(genderSelect)
        stackView.addArrangedSubview(birthDataField)
        stackView.addArrangedSubview(deviceInput)
        stackView.addArrangedSubview(scanBtn)
        
        view.addSubview(doneBtn)

        if isEditMode == true {
            nameInput.text = editName
            weightInput.text = String(editWeight)
            birthDataField.text = editBirth
            deviceInput.text = editDevice
            print(editGender)
            print(editIsKg)
            
            if editIsKg == true {
                weightSelect.selectedSegmentIndex = 0
            } else {
                weightSelect.selectedSegmentIndex = 1
            }
            
            switch editGender {
            case "Male":
                genderSelect.selectedSegmentIndex = 0
            case "FeMale":
                genderSelect.selectedSegmentIndex = 1
            default:
                genderSelect.selectedSegmentIndex = 2
            }
        }
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // KittyDoc 기기 등록 여부, 기기 연결 여부 등에 따른 처리가 잘 되는지 확인 필요! 21.02.24 -ms
        // 기존 등록된 펫에 기기 등록되지 않은 상태 && 수정할 때 기기를 새로 연결해도 반영이 안된다..
        if editingPetID != nil {
            print("editingPetID != nil")
            let petInfo: PetInfo? = PetInfo.shared.petArray[editingPetID!]
            
            if petInfo != nil {
                print("petInfo != nil")
                if petInfo!.Device.isEmpty {
                    print("petInfo!.Device.isEmpty == true")
                    deviceInput.text = "Plz Connect to Device!"
                } else {
                    print("petInfo!.Device.isEmpty == false")
                    if deviceInput.text == "Plz Connect to Device!" {
                        print("deviceInput.text == Plz Connect to Device!")
                        if deviceManager.isConnected {
                            print("\tpetInfo!.Device.isEmpty == true && deviceManager.isConnected == true")
                            deviceInput.text = deviceManager.peripheral!.identifier.uuidString
                        } else {
                            print("\tpetInfo!.Device.isEmpty == true && deviceManager.isConnected == false")
                        }
                    } else {
                        print("\tpetInfo!.Device.isEmpty == false (\(petInfo!.Device)")
                        deviceInput.text = petInfo!.Device
                    }
                }
            } else {
                print("\tpetInfo == nil")
            }
        } else {
            print("editingPetID == nil(Adding New Pet)")
            
            if deviceInput.text!.isEmpty {
                deviceInput.text = "Plz Connect to Device!"
            } else {
                if deviceManager.isConnected {
                    deviceInput.text = deviceManager.peripheral!.identifier.uuidString
                }
            }
        }
    }
    
    private func setConstraints() {
        
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -30),
            image.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            image.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            image.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3)
        ])
        
        NSLayoutConstraint.activate([
            imageAddBtn.topAnchor.constraint(equalTo: image.bottomAnchor, constant: -13),
            imageAddBtn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 30),
            imageAddBtn.widthAnchor.constraint(equalTo: image.widthAnchor, multiplier: 0.3),
            imageAddBtn.heightAnchor.constraint(equalTo: image.heightAnchor, multiplier: 0.2)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: imageAddBtn.bottomAnchor, constant: 30),
            stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            doneBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90),
            doneBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneBtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            doneBtn.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.06)
        ])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }
    
    let nameInput: UITextField = {
        let nameInput = UITextField()
        nameInput.translatesAutoresizingMaskIntoConstraints = false
        nameInput.placeholder = "이름"
        return nameInput
    }()
    
    let weightInput: UITextField = {
        let weightInput = UITextField()
        weightInput.translatesAutoresizingMaskIntoConstraints = false
        weightInput.placeholder = "몸무게"
        weightInput.keyboardType = .numberPad
        return weightInput
    }()
    
    

    let image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "person.circle")
        image.layer.cornerRadius = image.frame.height/2
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.clear.cgColor
        image.clipsToBounds = true
        return image
    }()
    
    let imageAddBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setBackgroundImage(UIImage(systemName: "pencil"), for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector((didTapImageAddBtn)), for: .touchUpInside)
        
        return btn
    }()
    
    @objc func didTapImageAddBtn() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: false)
    }
    
    let stackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        
        return stackView
    }()


    let weightStackView: UIStackView = {
        let stackView = UIStackView()
         stackView.translatesAutoresizingMaskIntoConstraints = false
         stackView.axis = .horizontal
         stackView.distribution = .fillEqually
         stackView.spacing = 20
        
         return stackView
    }()
    
    let weightSelect: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.insertSegment(withTitle: "kg", at: 0, animated: true)
        segment.insertSegment(withTitle: "lb", at: 1, animated: true)
        //kg단위를 디폴트로 사용
        segment.selectedSegmentIndex = 0
        return segment
    }()
    
    let genderSelect: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.insertSegment(withTitle: "Male", at: 0, animated: true)
        segment.insertSegment(withTitle: "Female", at: 1, animated: true)
        segment.insertSegment(withTitle: "None", at: 2, animated: true)
        //None을 디폴트로 사용
        segment.selectedSegmentIndex = 2
        return segment
    }()
    
    
    let birthDataField: UITextField = {
        let birthDataField = UITextField()
        birthDataField.translatesAutoresizingMaskIntoConstraints = false
        birthDataField.placeholder = "여기를 클릭해서 생년월일을 입력해주세요"
        birthDataField.addTarget(self, action: #selector(initBirth), for: .editingDidBegin)
        return birthDataField
    }()
    
    @objc func initBirth() {
       //text 오늘 날짜로 바꿔주기
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        birthDataField.text = dateFormatter.string(from: date)
        // 그냥 Date()로 생성자 호출 시 현재 시간으로 생성하는 것으로 기억... ms
    }
    
    func setUpdatePicker() -> UIDatePicker {
        let picker: UIDatePicker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(self.dataChanged), for: .allEvents)
        
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        
        self.birthDataField.inputView = picker
        
        let toolBar: UIToolbar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        
        let space: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.tapOnDoneBtn))
        
        toolBar.setItems([space, done], animated: true)
        
        self.birthDataField.inputAccessoryView = toolBar
        return picker
    }
    
    @objc func dataChanged(_ picker: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        self.birthDataField.text = dateFormatter.string(from: picker.date)
        
        let writedateFormatter = DateFormatter()
        writedateFormatter.dateFormat = "yyyy년 MM월 dd일"
        birthInput = writedateFormatter.string(from: picker.date)
    }
    
    @objc func tapOnDoneBtn(_ picker: UIDatePicker) {
        birthDataField.resignFirstResponder()
    }
    
    
    let deviceInput: UILabel = {
        let device = UILabel()
        device.translatesAutoresizingMaskIntoConstraints = false
        device.text = ""
        return device
    }()
    
    let scanBtn: UIButton = {
        let scanBtn = UIButton()
        scanBtn.translatesAutoresizingMaskIntoConstraints = false
        scanBtn.setTitle("스캔", for: .normal)
        scanBtn.backgroundColor = .orange
        scanBtn.layer.cornerRadius = 8
        scanBtn.addTarget(self, action: #selector(didTapScanBtn), for: .touchUpInside)
        return scanBtn
    }()
    
    let doneBtn: UIButton = {
        let doneBtn = UIButton()
        doneBtn.translatesAutoresizingMaskIntoConstraints = false
        doneBtn.setTitle("등록", for: .normal)
        doneBtn.backgroundColor = .systemBlue
        doneBtn.layer.cornerRadius = 8
        doneBtn.addTarget(self, action: #selector(didTapDoneBtn), for: .touchUpInside)
        return doneBtn
    }()
    
    @objc func didTapScanBtn() {
        self.performSegue(withIdentifier: "BTListViewSegue", sender: self)// 필요 시 새로운 ListViewController 생성 필요
        // 기기 연결 이후 싱크 데이터 받아오거나, 기존 화면에 특화된 기능 수정 필요 -ms
    }
    
    @objc func didTapDoneBtn() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let birth:String = birthInput ?? dateFormatter.string(from: date)
        
        print(weightInput.text!)
        
        if(!isNameForm(_name: nameInput.text!)){
            alertWithMessage(message: "이름을 입력해주세요")
            return
        }
        
        if(!isWeightForm(_weight:weightInput.text!)){
            alertWithMessage(message: "몸무게를 올바르게 입력해주세요")
            return
        }
        
        var weightKG:String
        var weightLB:String
        if(weightSelect.selectedSegmentIndex == 0){
            let kg:Double = floor(Double(weightInput.text!)!*100)/100
            let lb:Double = floor((kg * 2.20462)*100)/100
            weightKG = String(kg)
            weightLB = String(lb)
        }else{
            let lb:Double = floor(Double(weightInput.text!)!*100)/100
            let kg:Double = floor((lb * 0.45359)*100)/100
            weightKG = String(kg)
            weightLB = String(lb)
        }
        
        var gender:String = "None"
        if(genderSelect.selectedSegmentIndex == 0){
            gender = "Male"
        }else if(genderSelect.selectedSegmentIndex == 1){
            gender = "FeMale"
        }else{
            gender = "None"
        }

        // KittyDoc Device 연결하지 않고 펫 등록 및 수정할 경우 처리 21.02.24 -ms
        if deviceInput.text == "Plz Connect to Device!" {
            deviceInput.text = ""
        }
        // // // // // // // // // // // // // // // // // // // //

        if isEditMode == true {
            let modifyData:ModifyData_Pet = ModifyData_Pet(_ownerId: UserInfo.shared.UserID, _petId: PetInfo.shared.petArray[editingPetID!].PetID, _petName: nameInput.text!, _petKG: weightKG, _petLB: weightLB, _petSex: gender, _petBirth: birthDataField.text!, _device: deviceInput.text!)
            let server:KittyDocServer = KittyDocServer()
            let modifyResponse:ServerResponse = server.petModify(data: modifyData)
            if(modifyResponse.getCode() as! Int == ServerResponse.PET_MODIFY_SUCCESS){
                
                PetInfo.shared.petArray[editingPetID!].PetName = nameInput.text!
                PetInfo.shared.petArray[editingPetID!].PetKG = Double(weightKG) ?? 0
                PetInfo.shared.petArray[editingPetID!].PetSex = gender
                PetInfo.shared.petArray[editingPetID!].PetBirth = birthDataField.text!
                
                if weightSelect.selectedSegmentIndex == 0 {
                    PetInfo.shared.petArray[editingPetID!].IsKG = true
                } else {
                    PetInfo.shared.petArray[editingPetID!].IsKG = false
                }
                
                alertWithMessage(message: modifyResponse.getMessage())
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.navigationController?.popViewController(animated: true)
                }
                
            } else {
                alertWithMessage(message: modifyResponse.getMessage())
            }
            
        } else {
            let singUpData_Pet:SignUpData_Pet = SignUpData_Pet(_petName: nameInput.text!, _ownerId: UserInfo.shared.UserID, _petKG: weightKG, _petLB: weightLB, _petSex: gender, _petBirth: birth, _device: deviceInput.text!)
            let server:KittyDocServer = KittyDocServer()
            let signUpResponse_Pet:ServerResponse = server.petSignUp(data: singUpData_Pet)
            
            if(signUpResponse_Pet.getCode() as! Int == ServerResponse.JOIN_SUCCESS){
                self.navigationController?.popViewController(animated: true)
                alertWithMessage(message: signUpResponse_Pet.getMessage())
            } else if(signUpResponse_Pet.getCode() as! Int == ServerResponse.JOIN_FAILURE){
                alertWithMessage(message: signUpResponse_Pet.getMessage())
            } else {
                print(signUpResponse_Pet.getMessage())
            }
        }
    }
    
    func alertWithMessage(message input: Any) {
        let alert = UIAlertController(title: "", message: input as? String, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        self.present(alert, animated: false)
    }
    
    //isWeightForm은 입력받을때 키보드 타입이 number타입 키보드임을 가정
    func isWeightForm(_weight:String) -> Bool{
        if(_weight.count > 0){
            let tok:[String] = _weight.components(separatedBy: ".")
            if(tok.count > 2){
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func isEmailForm(_email:String) -> Bool{
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,50}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailReg)
        return emailTest.evaluate(with: _email)
    }
    
    func isNameForm(_name:String) -> Bool{
        if(_name.count > 0) {
            return true
        } else {
            return false
        }
    }
}

extension AddPetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension AddPetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) { () in
            let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            self.image.image = img
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: false) { () in
            let alert = UIAlertController(title: "", message: "이미지 선택이 취소되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel))
            self.present(alert, animated: false)
            
        }
    }
    
}
