//
//  UserInfoSettingViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/02/02.
//

import UIKit
import LocalAuthentication

class UserInfoSettingViewController: UIViewController, UITextFieldDelegate {
    
    let authContext = LAContext()
    
    var userInterfaceStyle: UIUserInterfaceStyle = .unspecified
    var deviceManager = DeviceManager.shared
    var safeArea: UILayoutGuide!

    var titleLabel: UILabel!
    var guideLabel: UILabel!
    
    var userInfoView: UIView!
    
    var emailLabel: UILabel!
    var emailTF: UITextField!
    var nameLabel: UILabel!
    var genderLabel: UILabel!
    var phoneNumberLabel: UILabel!
    var genderSelect: UISegmentedControl!
    var dateOfBirthLabel: UILabel!
    var birthDataField: UITextField!
    var signUpBtn: onOffButton!
    var askLabel: UILabel!
    var signInBtn: UIButton!
    
    var nameTF: UITextField!
    var phoneNumberInput: UITextField!
    var datePicker: UIDatePicker!
    var birthInput: String = "19700101"

    override func viewDidLoad() {
        super.viewDidLoad()
        userInterfaceStyle = self.traitCollection.userInterfaceStyle
        
        print("AnalysisViewController.viewDidLoad()")
        safeArea = view.layoutMarginsGuide
        initUIViews()
        addSubviews()
        prepareForAutoLayout()
        setConstraints()
        
        birthInput = UserInfo.shared.UserBirth
        
        var error: NSError?
        
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
        }
        
        switch authContext.biometryType {
        case .faceID:
            print("계정 정보를 열람하기 위해서 Face ID로 인증 합니다.")
        case .touchID:
            print("계정 정보를 열람하기 위해서 Touch ID로 인증 합니다.")
        case .none:
            print("계정 정보를 열람하기 위해서는 로그인하십시오. ")
        @unknown default:
            fatalError("생체 인증 오류!!!(UserInfoSettingViewController)")
        }
        
        let reason = "Log in to your account"
        
        authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (sucess, error) in
            
            if sucess {
                print("인증 성공")
            } else {
                print("인증 실패")
                if let error = error {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        let alert: UIAlertController = UIAlertController(title: "Failed!", message: "Failed to get Authorization!", preferredStyle: .alert)
                        let confirm = UIAlertAction(title: "Dismiss", style: .destructive) { _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(confirm)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//    }
    
    @objc func dataChanged(_ picker: UIDatePicker) {
        manageDateFormatter(date: picker.date)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//
//        self.birthDataField.text = dateFormatter.string(from: picker.date)
//        print(dateFormatter.string(from: picker.date))
//
//        let writedateFormatter = DateFormatter()
//        writedateFormatter.dateFormat = "yyyyMMdd"
//        birthInput = writedateFormatter.string(from: picker.date)
    }
    
    func manageDateFormatter(date: Date?) { // date가 nil일 경우 picker.date 사용
        if date != nil {
            datePicker.date = date!
        }
        let dateFormatter = DateFormatter()
        //dateFormatter.dateStyle = .long
        dateFormatter.dateFormat = "yyyy-MM-dd"
        birthDataField.text = dateFormatter.string(from: datePicker.date)

        dateFormatter.dateFormat = "yyyyMMdd"
        birthInput = dateFormatter.string(from: datePicker.date)
        print("birthDataField.text : \(birthDataField.text ?? "0000-00-00"), birthInput : \(birthInput)")
    }

    @objc func tapOnDoneBtn(_ picker: UIDatePicker) {
        birthDataField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }
    
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        if nameTF.hasText && phoneNumberInput.hasText && birthInput != nil && genderSelect.selectedSegmentIndex != -1 {
            signUpBtn.isOn = .On
        }
        
        else {
            signUpBtn.isOn = .On
        }
    }
    
    @objc private func didTapRegister() {
        print("didTapRegister(genderSelect : \(genderSelect.selectedSegmentIndex)")//성별 @@@ -1 = 선택안함, 0 = 남성, 1 = 여성, 2 = None
        var gender: String = "None"
        if(genderSelect.selectedSegmentIndex == 0) {
            gender = "Male"
        } else if(genderSelect.selectedSegmentIndex == 1) {
            gender = "FeMale"
        } else {
            gender = "None"
        }
        
        if (nameTF.text!.count < 1) {
            alertWithMessage(message: "이름을 입력하세요.")
            return
        }
        //생일에 대해서만 너가 조건문을 작성해주면좋겠어... 아래 작성한 함수 제대로 동작못한당... TEST
    
        UserInfo.shared.UserBirth = birthInput
        print("birthInput : \(birthInput)")
        
        if (!isPhoneForm(_phone:phoneNumberInput.text!)) {
            alertWithMessage(message: "올바른 전화번호 형식이 아닙니다.")
            return
        }
        
        let modifyData:ModifyData = ModifyData(_userId: UserInfo.shared.UserID, _userName: nameTF.text!, _userPhone: phoneNumberInput.text!, _userSex: gender, _userBirth: birthInput)
        let server:KittyDocServer = KittyDocServer()
        let modifyResponse:ServerResponse = server.userModify(data: modifyData)
                    
        if(modifyResponse.getCode() as! Int == ServerResponse.EDIT_SUCCESS){
            print(modifyResponse.getMessage() as! String)
            //정보 수정했으므로 VC에서 나가기
            DispatchQueue.main.async {
                //let alert: UIAlertController = UIAlertController(title: "Service Found!", message: "Found all required Service!", preferredStyle: .alert)
                let alert: UIAlertController = UIAlertController(title: "Success!", message: "Successfully modified your Info!", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "OK", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)
            }
        } else if(modifyResponse.getCode() as! Int == ServerResponse.EDIT_FAILURE) {
            print(modifyResponse.getMessage() as! String)
            alertWithMessage(message: modifyResponse.getMessage() as! String)
        }
    }
    
    func alertWithMessage(message input: Any) {
        let alert = UIAlertController(title: "", message: input as? String, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        self.present(alert, animated: false)
    }

}

func isPhoneForm(_phone:String) -> Bool {
    let phoneReg = "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$"
    return NSPredicate(format: "SELF MATCHES %@", phoneReg).evaluate(with:_phone)
}

extension UserInfoSettingViewController { // Auto Layout
    fileprivate func initUIViews() {
        initTitleLabel()
        initGuideLabel()
        initSignUpView()
        initEmailLabel()
        initEmailTF()
        initNameLabel()
        initNameTF()
        initGenderSelect()
        initGenderLabel()
        initDateOfBirthLabel()
        initBirthDataField()
        initUpdatePicker()
        initPhoneNumberLabel()
        initPhoneNumberInput()
        initSignUpBtn()
    }
    
    fileprivate func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(guideLabel)
        
        view.addSubview(userInfoView)
        userInfoView.addSubview(emailLabel)
        userInfoView.addSubview(emailTF)
        userInfoView.addSubview(nameLabel)
        userInfoView.addSubview(nameTF)
        userInfoView.addSubview(genderLabel)
        userInfoView.addSubview(genderSelect)
        userInfoView.addSubview(dateOfBirthLabel)
        userInfoView.addSubview(birthDataField)
        userInfoView.addSubview(phoneNumberLabel)
        userInfoView.addSubview(phoneNumberInput)
        
        view.addSubview(signUpBtn)
    }
    
    fileprivate func prepareForAutoLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        
        userInfoView.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTF.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTF.translatesAutoresizingMaskIntoConstraints = false
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        genderSelect.translatesAutoresizingMaskIntoConstraints = false
        dateOfBirthLabel.translatesAutoresizingMaskIntoConstraints = false
        birthDataField.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberInput.translatesAutoresizingMaskIntoConstraints = false
        
        signUpBtn.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setConstraints() {
        let userInfoViewConstraints = [
            userInfoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userInfoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            userInfoView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            userInfoView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
            userInfoView.heightAnchor.constraint(equalToConstant: 250)
        ]

        let emailLabelConstraints = [
            emailLabel.topAnchor.constraint(equalTo: userInfoView.topAnchor, constant: 15),
            emailLabel.leftAnchor.constraint(equalTo: userInfoView.leftAnchor, constant: 10),
//            emailLabel.heightAnchor.constraint(equalToConstant: 20),
            emailLabel.widthAnchor.constraint(equalToConstant: 120)
        ]

        let emailTFConstraints = [
            emailTF.centerYAnchor.constraint(equalTo: emailLabel.centerYAnchor),
//            emailTF.topAnchor.constraint(equalTo: emailLabel.topAnchor),
            emailTF.leftAnchor.constraint(equalTo: emailLabel.rightAnchor, constant: 10),
            emailTF.rightAnchor.constraint(equalTo: userInfoView.rightAnchor, constant: -10),
//            emailLabel.heightAnchor.constraint(equalToConstant: 20)
        ]

        let nameLabelConstraints = [
            nameLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 30),
            nameLabel.leftAnchor.constraint(equalTo: emailLabel.leftAnchor),
//            nameLabel.heightAnchor.constraint(equalToConstant: 20),
            nameLabel.widthAnchor.constraint(equalToConstant: 120)
        ]

        let nameTFConstraints = [
            nameTF.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
//            nameTF.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            nameTF.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 10),
            nameTF.rightAnchor.constraint(equalTo: emailTF.rightAnchor),
//            nameTF.heightAnchor.constraint(equalToConstant: 20)
        ]

        let genderLabelConstraints = [
            genderLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30),
            genderLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            genderLabel.widthAnchor.constraint(equalToConstant: 120)
        ]

        let genderSelectConstraints = [
            genderSelect.centerYAnchor.constraint(equalTo: genderLabel.centerYAnchor),
//            genderSelect.topAnchor.constraint(equalTo: genderLabel.topAnchor),
            genderSelect.leftAnchor.constraint(equalTo: genderLabel.rightAnchor, constant: 10),
            genderSelect.rightAnchor.constraint(equalTo: userInfoView.rightAnchor, constant: -10),
//            genderSelect.heightAnchor.constraint(equalToConstant: 20)
        ]
        
        let dateOfBirthLabelConstraints = [
            dateOfBirthLabel.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 30),
            dateOfBirthLabel.leftAnchor.constraint(equalTo: genderLabel.leftAnchor),
//            dateOfBirthLabel.heightAnchor.constraint(equalToConstant: 20),
            dateOfBirthLabel.widthAnchor.constraint(equalToConstant: 120)
        ]
        
        let birthDataFieldConstraints = [
            birthDataField.centerYAnchor.constraint(equalTo: dateOfBirthLabel.centerYAnchor),
//            birthDataField.topAnchor.constraint(equalTo: dateOfBirthLabel.topAnchor),
            birthDataField.leftAnchor.constraint(equalTo: dateOfBirthLabel.rightAnchor, constant: 10),
            birthDataField.rightAnchor.constraint(equalTo: userInfoView.rightAnchor, constant: -10),
//            phoneNumberInput.heightAnchor.constraint(equalToConstant: 20)
        ]
        
        let phoneNumberLabelConstraints = [
            phoneNumberLabel.topAnchor.constraint(equalTo: dateOfBirthLabel.bottomAnchor, constant: 30),
            phoneNumberLabel.leftAnchor.constraint(equalTo: dateOfBirthLabel.leftAnchor),
//            phoneNumberLabel.heightAnchor.constraint(equalToConstant: 20),
            phoneNumberLabel.widthAnchor.constraint(equalToConstant: 120)
        ]
        
        let phoneNumberInputConstraints = [
            phoneNumberInput.centerYAnchor.constraint(equalTo: phoneNumberLabel.centerYAnchor),
//            phoneNumberInput.topAnchor.constraint(equalTo: phoneNumberLabel.topAnchor),
            phoneNumberInput.leftAnchor.constraint(equalTo: phoneNumberLabel.rightAnchor, constant: 10),
            phoneNumberInput.rightAnchor.constraint(equalTo: userInfoView.rightAnchor, constant: -10),
//            phoneNumberInput.heightAnchor.constraint(equalToConstant: 20)
        ]
        
        let guideLabelConstraints = [
            guideLabel.bottomAnchor.constraint(equalTo: userInfoView.topAnchor, constant: -50),
            guideLabel.leftAnchor.constraint(equalTo: userInfoView.leftAnchor, constant: 10)
        ]
        
        let titleLabelConstraints = [
            titleLabel.bottomAnchor.constraint(equalTo: guideLabel.topAnchor, constant: -10),
            titleLabel.leftAnchor.constraint(equalTo: guideLabel.leftAnchor, constant: -5)
        ]
        
        let signUpBtnConstraints = [
            signUpBtn.topAnchor.constraint(equalTo: userInfoView.bottomAnchor, constant: 50),
            signUpBtn.leftAnchor.constraint(equalTo: userInfoView.leftAnchor, constant: 20),
            signUpBtn.rightAnchor.constraint(equalTo: userInfoView.rightAnchor, constant: -20),
            signUpBtn.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        
        [userInfoViewConstraints, emailLabelConstraints, emailTFConstraints, nameLabelConstraints, nameTFConstraints, genderLabelConstraints, genderSelectConstraints, dateOfBirthLabelConstraints, birthDataFieldConstraints, phoneNumberLabelConstraints, phoneNumberInputConstraints, guideLabelConstraints, titleLabelConstraints, signUpBtnConstraints]
            .forEach(NSLayoutConstraint.activate(_:))
    }
}

extension UserInfoSettingViewController {
    func initTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = "Manage Your Info"
        titleLabel.font = titleLabel.font.withSize(40)
    }
    
    func initGuideLabel() {
        guideLabel = UILabel()
        guideLabel.text = "Manage your Information"
        guideLabel.textColor = .systemGray
    }
    
    func initSignUpView() {
        userInfoView = UIView()
    }
    
    func initEmailLabel() {
        emailLabel = UILabel()
        //emailLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        emailLabel.text = "Email"
    }
    
    func initEmailTF() {
        emailTF = UITextField()
        emailTF.text = UserInfo.shared.Email
        emailTF.textColor = .systemGray
        emailTF.keyboardType = .emailAddress
        emailTF.delegate = self
        emailTF.autocapitalizationType = .none
        emailTF.borderStyle = .roundedRect
        emailTF.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        emailTF.isEnabled = false
    }

    func initNameLabel() {
        nameLabel = UILabel()
        nameLabel.text = "Name"
    }
    
    func initNameTF() {
        nameTF = UITextField()
        nameTF.text = UserInfo.shared.Name
        nameTF.delegate = self
        nameTF.borderStyle = .roundedRect
        //nameTF.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }
    
    func initPhoneNumberLabel() {
        phoneNumberLabel = UILabel()
        phoneNumberLabel.text = "Phone number"
    }
    
    func initPhoneNumberInput() {
        phoneNumberInput = UITextField()
        phoneNumberInput.text = UserInfo.shared.UserPhone
        phoneNumberInput.borderStyle = .roundedRect
        //phoneNumberInput.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }
    
    func initDateOfBirthLabel() {
        dateOfBirthLabel = UILabel()
        dateOfBirthLabel.text = "Date of Birth"
    }

    func initBirthDataField() {
        birthDataField = UITextField()
        var birthString = UserInfo.shared.UserBirth
        birthString.insert("-", at: birthString.index(birthString.startIndex, offsetBy: 6))
        birthString.insert("-", at: birthString.index(birthString.startIndex, offsetBy: 4))
        birthDataField.text = birthString
        birthDataField.borderStyle = .roundedRect
        //birthDataField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }
    
    func initUpdatePicker() {
        datePicker = UIDatePicker()//UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
        //datePicker.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200)
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.dataChanged), for: .allEvents)
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        self.birthDataField.inputView = datePicker
        
        let toolBar: UIToolbar = UIToolbar()//UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44)
        let space: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.tapOnDoneBtn))
        
        toolBar.setItems([space, done], animated: true)
        
        self.birthDataField.inputAccessoryView = toolBar
    }

    func initGenderSelect() {
        genderSelect = UISegmentedControl()
        genderSelect.insertSegment(withTitle: "Male", at: 0, animated: true)
        genderSelect.insertSegment(withTitle: "Female", at: 1, animated: true)
        genderSelect.insertSegment(withTitle: "None", at: 2, animated: true)
        
        switch UserInfo.shared.gender {
        case "male":
            genderSelect.selectedSegmentIndex = 0
        case "female":
            genderSelect.selectedSegmentIndex = 1
        case "none":
            genderSelect.selectedSegmentIndex = 2
        default:
            genderSelect.selectedSegmentIndex = 2
        }
        
    }
    
    func initGenderLabel() {
        genderLabel = UILabel()
        genderLabel.text = "Gender"
    }
    
    func initSignUpBtn() {
        signUpBtn = onOffButton()
        //signUpBtn.frame = CGRect(x: 40, y: 610, width: 300, height: 50)
        signUpBtn.setTitle("Submit", for: .normal)
        signUpBtn.setTitleColor(.white, for: .highlighted)
        signUpBtn.backgroundColor = .systemBlue
        signUpBtn.layer.cornerRadius = 8
        signUpBtn.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        signUpBtn.isOn = .On
    }

}
