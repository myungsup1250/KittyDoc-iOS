//
//  AddPetViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/25.
//

import UIKit

class AddPetViewController: UIViewController {
    
    let deviceManager = DeviceManager.shared
    var birthInput: String = "19700101"
    var isEditMode: Bool = false
    var editingPetID: Int? //맘대로 바꿔도 됨
    var datePicker: UIDatePicker!
    //var newDeviceConnected: Bool!
    
    var editName = ""
    var editWeight = 0.0
    var editIsKg = true
    var editGender = ""
    var editBirth = ""
    var editDevice = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("AddPetViewController.viewDidLoad()")
        
        datePicker = setUpdatePicker()
        //newDeviceConnected = false
        
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

        if !isEditMode {
            deviceManager.disconnect()
        } else {
            nameInput.text = editName
            weightInput.text = String(editWeight)
//            print("editBirth.insert(1)")
//            editBirth.insert("-", at: editBirth.index(editBirth.startIndex, offsetBy: 6))
//            print("editBirth.insert(2)")
//            editBirth.insert("-", at: editBirth.index(editBirth.startIndex, offsetBy: 4))
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
        print("AddPetViewController.viewWillAppear()")

        // KittyDoc 기기 등록 여부, 기기 연결 여부 등에 따른 처리가 잘 되는지 확인 필요! 21.02.24 -ms
        if editingPetID != nil {
            print("\tEdit Pet Info Mode(editingPetID: \(editingPetID!))")
            let petInfo: PetInfo? = PetInfo.shared.petArray[editingPetID!]
            print("petInfo.Device :", petInfo!.Device)
            if petInfo != nil { // petInfo 존재함 : 수정 모드
                print("\t\tpetInfo != nil")
                if (petInfo!.Device.isEmpty || petInfo!.Device == "NULL") {
                    print("\t\t\tpetInfo.Device.is Empty")
                    petInfo!.Device = "No device"
                    deviceInput.text = "Plz Connect to Device!"
                } else {
                    if deviceManager.isConnected && deviceManager.peripheral != nil {
                        print("\t\t\t\tdeviceManager.isConnected")
                        let connected = deviceManager.peripheral!.identifier.uuidString
                        if petInfo!.Device == "No device" { // Connected to New Device
                            deviceInput.text = connected
                            petInfo!.Device = connected
                        } else { // Already got its own device
                            deviceInput.text = petInfo!.Device
                            if petInfo!.Device != connected {
                                DispatchQueue.main.async {
                                    let alert: UIAlertController = UIAlertController(title: "Change Device?", message: "Do you want to change \(petInfo!.PetName)'s Device to currently connected Device?", preferredStyle: .alert)
                                    let confirm = UIAlertAction(title: "Yes", style: .default) { [self] _ in
                                        deviceInput.text = connected
                                        petInfo!.Device = connected
                                    }
                                    let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
                                    alert.addAction(confirm)
                                    alert.addAction(cancel)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    } else {
                        deviceInput.text = petInfo!.Device
                    }
                }
            } else {
                print("\t\tpetInfo is nil! ERROR!")
            }
        } else { // petInfo 없음 : 새로 등록할 때
            print("\tNew Pet Info Mode(editingPetID: \(editingPetID ?? -1))")// -1 means Error

            if deviceInput.text!.isEmpty {
                deviceInput.text = "Plz Connect to Device!"
            } else {
                if deviceManager.isConnected {
                    deviceInput.text = deviceManager.peripheral!.identifier.uuidString
                }
            }
        }
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
        //birthDataField.addTarget(self, action: #selector(initBirth), for: .editingDidBegin)
        // 21.04.01 텍스트필드 건드릴때마다 내용이 바뀌는 불편함이 있어 주석 처리
        return birthDataField
    }()
    
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
        
        let today: UIBarButtonItem = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(setToday))
        let space: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.tapOnDoneBtn))
        
        toolBar.setItems([today, space, done], animated: true)
        
        self.birthDataField.inputAccessoryView = toolBar
        return picker
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

    @objc func setToday(_ picker: UIDatePicker) {
        print("setToday()")
        
        manageDateFormatter(date: Date())
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

extension AddPetViewController {
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
    
}

extension AddPetViewController {
    @objc func didTapImageAddBtn() {
        print("didTapImageAddBtn()")
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: false)
    }
    
    @objc func initBirth() {
        print("initBirth()")
       //text 오늘 날짜로 바꿔주기
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        birthDataField.text = dateFormatter.string(from: date)
    }
    
    @objc func dataChanged(_ picker: UIDatePicker) {
        print("dataChanged()")
        manageDateFormatter(date: picker.date)
//        let dateFormatter = DateFormatter()
//        //dateFormatter.dateStyle = .long
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        self.birthDataField.text = dateFormatter.string(from: picker.date)
//
//        let writedateFormatter = DateFormatter()
//        writedateFormatter.dateFormat = "yyyyMMdd"
//        birthInput = writedateFormatter.string(from: picker.date)
//        print("birthDataField.text : \(birthDataField.text ?? "0000-00-00"), birthInput : \(birthInput)")
    }
    
    func manageDateFormatter(date: Date?) { // date가 nil일 경우 picker.date 사용
        if date != nil {
            datePicker.date = date!
        }
        let dateFormatter = DateFormatter()
        //dateFormatter.dateStyle = .long
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        birthDataField.text = dateFormatter.string(from: datePicker.date)

//        dateFormatter.dateFormat = "yyyyMMdd"
//        birthInput = dateFormatter.string(from: datePicker.date)
        dateFormatter.dateFormat = "yyyyMMdd"
        birthDataField.text = dateFormatter.string(from: datePicker.date)
        birthInput = dateFormatter.string(from: datePicker.date)
        // 21.04.26 by ms
        print("birthDataField.text : \(birthDataField.text ?? "00000000"), birthInput : \(birthInput)")
    }

    @objc func tapOnDoneBtn(_ picker: UIDatePicker) {
        print("tapOnDoneBtn()")
        birthDataField.resignFirstResponder()
    }
 
    @objc func didTapScanBtn() {
//        let petInfo: PetInfo? = PetInfo.shared.petArray[editingPetID!]
//        print("didTapScanBtn(pet's device : \(petInfo?.Device)")
//        if !(petInfo?.Device.isEmpty ?? false) {
//
//        }
        self.performSegue(withIdentifier: "BTListViewSegue", sender: self)// 필요 시 새로운 ListViewController 생성 필요
        // 기기 연결 이후 싱크 데이터 받아오거나, 기존 화면에 특화된 기능 수정 필요 -ms
    }
    
    @objc func didTapDoneBtn() {
        print("didTapDoneBtn(weightInput : \(weightInput.text!))")
        
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
        if (weightSelect.selectedSegmentIndex == 0){
            let kg:Double = floor(Double(weightInput.text!)!*100)/100
            let lb:Double = floor((kg * 2.20462)*100)/100
            weightKG = String(kg)
            weightLB = String(lb)
        } else {
            let lb:Double = floor(Double(weightInput.text!)!*100)/100
            let kg:Double = floor((lb * 0.45359)*100)/100
            weightKG = String(kg)
            weightLB = String(lb)
        }
        
        var gender = "None"
        if (genderSelect.selectedSegmentIndex == 0) {
            gender = "Male"
        } else if(genderSelect.selectedSegmentIndex == 1) {
            gender = "FeMale"
        } else {
            gender = "None"
        }

        // KittyDoc Device 연결하지 않고 펫 등록 및 수정할 경우 처리 21.02.24 -ms
        // 빈 문자열 대신 안드로이드처럼 NULL을 넣어서 서버에 등록하도록 수정 21.05.06 -ms
        if deviceInput.text == "Plz Connect to Device!" {
            deviceInput.text = "NULL"
        }//

        if isEditMode == true {
            let modifyData = ModifyData_Pet(_ownerId: UserInfo.shared.UserID, _petId: PetInfo.shared.petArray[editingPetID!].PetID, _petName: nameInput.text!, _petKG: weightKG, _petLB: weightLB, _petSex: gender, _petBirth: birthDataField.text!, _device: deviceInput.text!)
            let server = KittyDocServer()
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
            let singUpData_Pet:SignUpData_Pet = SignUpData_Pet(_petName: nameInput.text!, _ownerId: UserInfo.shared.UserID, _petKG: weightKG, _petLB: weightLB, _petSex: gender, _petBirth: birthInput, _device: deviceInput.text!)
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
    
}
