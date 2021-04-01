//
//  SignUpViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/15.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    var userInterfaceStyle: UIUserInterfaceStyle = .unspecified
    var deviceManager = DeviceManager.shared
    var safeArea: UILayoutGuide!

    var welcomeLabel: UILabel!
    var guideLabel: UILabel!
    var signUpView: UIView!
    var emailLabel: UILabel!
    var duplicateBtn: UIButton!
    var pwdLabel: UILabel!
    var pwdConfirmLabel: UILabel!
    var nameLabel: UILabel!
    var phoneNumberLabel: UILabel!
    var genderSelect: UISegmentedControl!
    var dateOfBirthLabel: UILabel!
    var birthDataField: UITextField!
    var signUpBtn: onOffButton!
    var askLabel: UILabel!
    var signInBtn: UIButton!
    
    var emailTF: UITextField!
    var pwdTF: UITextField!
    var pwdConfirmTF: UITextField!
    var nameTF: UITextField!
    var phoneNumberInput: UITextField!
    var datePicker: UIDatePicker!
    var birthInput: String?
    var didDupEx: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        print("SignUpViewController.viewDidLoad()")
        
        if self.traitCollection.userInterfaceStyle == .light {
            userInterfaceStyle = .light
        } else if self.traitCollection.userInterfaceStyle == .dark {
            userInterfaceStyle = .dark
        } else {
            userInterfaceStyle = .unspecified
        }
        
        print("AnalysisViewController.viewDidLoad()")
        safeArea = view.layoutMarginsGuide
        initUIViews()
        addSubviews()
        prepareForAutoLayout()
        setConstraints()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }
    
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        if emailTF.hasText && pwdTF.hasText && pwdConfirmTF.hasText && nameTF.hasText && phoneNumberInput.hasText && birthInput != nil && genderSelect.selectedSegmentIndex != -1 {
            signUpBtn.isOn = .On
        }
        
        else {
            signUpBtn.isOn = .Off
        }
    }
    
    @objc func segmentDidEndEditing(_ segment: UISegmentedControl) {
        if emailTF.hasText && pwdTF.hasText && pwdConfirmTF.hasText && nameTF.hasText && phoneNumberInput.hasText && birthInput != nil && genderSelect.selectedSegmentIndex != -1 {
            signUpBtn.alpha = 1.0
        }
        else {
            signUpBtn.alpha = 0.5
        }
    }
    
    @objc func dataChanged(_ picker: UIDatePicker) {
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//
//        self.birthDataField.text = dateFormatter.string(from: picker.date)
//        print(dateFormatter.string(from: picker.date))
//
//        let writedateFormatter = DateFormatter()
//        writedateFormatter.dateFormat = "yyyyMMdd"
//        birthInput = writedateFormatter.string(from: picker.date)
//
//        print("[dataChanged] birthDataField.text : \(birthDataField.text ?? "0000-00-00"), birthInput : \(birthInput)")
        
        
        // 21.04.01 birthDataField에 Apr 1, 2021 등으로 언어 별로 헛갈리게 저장하지 않고 숫자로 통일!
        manageDateFormatter(date: picker.date)
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
        print("[manageDateFormatter] birthDataField.text : \(birthDataField.text ?? "0000-00-00"), birthInput : \(birthInput ?? "19700101")")
    }
    
    @objc func tapOnDoneBtn(_ picker: UIDatePicker) {
        birthDataField.resignFirstResponder()
    }
    
    @objc private func didTapSignIn() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapDuplicate() {
        if(!isEmailForm(_email:emailTF.text!)){
            alertWithMessage(message: "올바른 이메일 형식이 아닙니다")
            return
        }
        
        //중복 확인 버튼 눌렀을 때
        let existData:ExistData = ExistData(_userEmail:emailTF.text!)
        let server:KittyDocServer = KittyDocServer()
        let existResponse:ServerResponse = server.userExist(data: existData)
        
        //아이디 중복여부 분기. 여기서 중복과 관련된 동작을 처리하면됨!
        //중복확인 하기 전에는 레지스터 버튼이 회색, 중복확인 버튼은 파란색
        //중복확인 하고난 후에는 레지스터 버튼이 파란색, 중복확인 버튼은 회색 이었으면 좋겠다고 생각!
        //근데 기능은 색에 상관없이 적용되었슴다
        
        //RE: 사용자가 칸 다 채워놓고 중복확인 안했을 경우 잉 왜 버튼 투명이야 띠용 이런 경우가 많을 거 같아서
        //    register 버튼 눌렀을 때 중복확인 하세요! 팝업을 띄우는 걸로 해봤는데 어때?!
        if (existResponse.getCode() as! Int == ServerResponse.EXIST_IS_EXIST) {
            alertWithMessage(message: existResponse.getMessage())
            
        } else if(existResponse.getCode() as! Int == ServerResponse.EXIST_NOT_EXIST) {
            alertWithMessage(message: existResponse.getMessage())
            didDupEx = true
            signUpBtn.isEnabled = true
            emailTF.isEnabled = false
            duplicateBtn.isEnabled = false
            emailTF.textColor = .systemGray
            duplicateBtn.backgroundColor = .systemGray
        } else {
            alertWithMessage(message: existResponse.getMessage())
        }
    }
    
    @objc private func onShowPwdBtn(_ sender: UIButton) {
        print("onShowPwdBtn()")
        pwdTF.isSecureTextEntry.toggle()
    }
    
    @objc private func onShowPwdConfirmBtn(_ sender: UIButton) {
        print("onShowPwdConfirmBtn()")
        pwdConfirmTF.isSecureTextEntry.toggle()
    }
            
    @objc private func didTapRegister() {
        print(genderSelect.selectedSegmentIndex) //성별 @@@ -1 = 선택안함, 0 = 남성, 1 = 여성, 2 = None
        var gender:String="None"
        if(genderSelect.selectedSegmentIndex == 0) {
            gender="Male"
        } else if(genderSelect.selectedSegmentIndex == 1) {
            gender="FeMale"
        } else {
            gender="None"
        }
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let birth:String = birthInput ?? dateFormatter.string(from: date)
        
        if (!isPwdForm(_pwd:pwdTF.text!)) {
            alertWithMessage(message: "비밀번호는 1글자 이상이어야 합니다.")
            print(pwdTF.text!)
            return
        }
        if (!isPwdForm(_pwd:pwdConfirmTF.text!)) {
            alertWithMessage(message: "비밀번호는 1글자 이상이어야 합니다.")
            print(pwdConfirmTF.text!)
            return
        }
        if (pwdTF.text! != pwdConfirmTF.text!) {
            alertWithMessage(message: "비밀번호가 서로 다릅니다!")
            print("pwdTF.text :", pwdTF.text!, "pwdConfirmTF.text :", pwdConfirmTF.text!)
            return
        }
        if (!isPhoneForm(_phone:phoneNumberInput.text!)) {
            alertWithMessage(message: "올바른 전화번호 형식이 아닙니다.")
            return
        }
        if (nameTF.text!.count < 1) {
            alertWithMessage(message: "이름을 입력하세요.")
            return
        }
        //생일에 대해서만 너가 조건문을 작성해주면좋겠어... 아래 작성한 함수 제대로 동작못한당... TEST
    
        if (birthInput == nil) {
            alertWithMessage(message: "생일을 입력하세요.")
            return
        }
        
        if (didDupEx == false) {
            alertWithMessage(message: "이메일 중복확인을 해주세요.")
            return
        }
        
        let signUpData:SignUpData = SignUpData(_userEmail:emailTF.text!, _userPwd:pwdTF.text!, _userName:nameTF.text!, _userPhone:phoneNumberInput.text!, _userSex:gender, _userBirth:birth)
        let server:KittyDocServer = KittyDocServer()
        let signUpResponse:ServerResponse = server.userSignUp(data: signUpData)

        if (signUpResponse.getCode() as! Int == ServerResponse.JOIN_SUCCESS) {
            alertWithMessage(message: signUpResponse.getMessage())
            print(signUpResponse.getMessage())
            
            //MARK: TEST
//            let preVC = self.presentingViewController
//            guard let vc = preVC as? LogInViewController else {
//                return
//            }
//            vc.email = self.emailInput.text
            ///
            
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            alertWithMessage(message: signUpResponse.getMessage())
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func alertWithMessage(message input: Any) {
        let alert = UIAlertController(title: "", message: input as? String, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        self.present(alert, animated: false)
    }

    //이메일 형식인지에 대한 정규표현식. 인터넷에 검색하면 쉽게 나오니 바꾸고 싶은게 있으면 바꾸셈
    func isEmailForm(_email:String) -> Bool {
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,50}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailReg)
        return emailTest.evaluate(with: _email)
    }
    
    //비밀번호 형식에 대한 검사함수. 지금은 길이가 1이상만 되면 되는 것으로 했지만 추후에 특수문자포함여부, 길이제한 추가
    //하게 될지도?
    func isPwdForm(_pwd:String) -> Bool {
        if(_pwd.count > 0){
            return true
        }else{
            return false
        }
    }
    
    func isPhoneForm(_phone:String) -> Bool {
        let phoneReg = "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$"
        return NSPredicate(format: "SELF MATCHES %@", phoneReg).evaluate(with:_phone)
    }
}

extension SignUpViewController { // Auto Layout 코드 분리
    fileprivate func initUIViews() {
        initWelcomeLabel()
        initGuideLabel()
        
        initSignUpView()
        initEmailLabel()
        initEmailTF()
        initDuplicateBtn()
        initPwdLabel()
        initPwdTF()
        initPwdConfirmLabel()
        initPwdConfirmTF()
        initNameLabel()
        initNameTF()
        initGenderSelect()
        initPhoneNumberLabel()
        initPhoneNumberInput()
        initDateOfBirthLabel()
        initBirthDataField()
        initUpdatePicker()

        initSignUpBtn()
        initAskLabel()
        initSignInBtn()
        
    }
    
    fileprivate func addSubviews() {
        view.addSubview(welcomeLabel)
        view.addSubview(guideLabel)
        
        view.addSubview(signUpView)
        signUpView.addSubview(emailLabel)
        signUpView.addSubview(emailTF)
        signUpView.addSubview(duplicateBtn)
        signUpView.addSubview(pwdLabel)
        signUpView.addSubview(pwdTF)
        signUpView.addSubview(pwdConfirmLabel)
        signUpView.addSubview(pwdConfirmTF)
        signUpView.addSubview(nameLabel)
        signUpView.addSubview(nameTF)
        signUpView.addSubview(genderSelect)
        signUpView.addSubview(phoneNumberLabel)
        signUpView.addSubview(phoneNumberInput)
        signUpView.addSubview(dateOfBirthLabel)
        signUpView.addSubview(birthDataField)
        
        view.addSubview(signUpBtn)
        view.addSubview(askLabel)
        view.addSubview(signInBtn)
    }
    
    fileprivate func prepareForAutoLayout() {
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        signUpView.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTF.translatesAutoresizingMaskIntoConstraints = false
        duplicateBtn.translatesAutoresizingMaskIntoConstraints = false
        pwdLabel.translatesAutoresizingMaskIntoConstraints = false
        pwdTF.translatesAutoresizingMaskIntoConstraints = false
        pwdConfirmLabel.translatesAutoresizingMaskIntoConstraints = false
        pwdConfirmTF.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTF.translatesAutoresizingMaskIntoConstraints = false
        genderSelect.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberInput.translatesAutoresizingMaskIntoConstraints = false
        dateOfBirthLabel.translatesAutoresizingMaskIntoConstraints = false
        birthDataField.translatesAutoresizingMaskIntoConstraints = false
        signUpBtn.translatesAutoresizingMaskIntoConstraints = false
        askLabel.translatesAutoresizingMaskIntoConstraints = false
        signInBtn.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setConstraints() {
        let signUpViewConstraints = [
            signUpView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signUpView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            signUpView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
            signUpView.heightAnchor.constraint(equalToConstant: 385)
        ]

        let emailLabelConstraints = [
            emailLabel.topAnchor.constraint(equalTo: signUpView.topAnchor, constant: 15),
            emailLabel.leftAnchor.constraint(equalTo: signUpView.leftAnchor, constant: 10),
//            emailLabel.heightAnchor.constraint(equalToConstant: 20),
            //emailLabel.widthAnchor.constraint(equalToConstant: 80)
        ]
        
        let duplicateBtnConstraints = [
            duplicateBtn.topAnchor.constraint(equalTo: emailLabel.topAnchor),
            duplicateBtn.bottomAnchor.constraint(equalTo: emailLabel.bottomAnchor),
            duplicateBtn.rightAnchor.constraint(equalTo: signUpView.rightAnchor, constant: -10),
            duplicateBtn.heightAnchor.constraint(equalToConstant: 25),
            duplicateBtn.widthAnchor.constraint(equalToConstant: 100)
        ]

        let emailTFConstraints = [
            emailTF.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            emailTF.leftAnchor.constraint(equalTo: emailLabel.leftAnchor),
            emailTF.rightAnchor.constraint(equalTo: signUpView.rightAnchor, constant: -10),
//            emailTF.heightAnchor.constraint(equalToConstant: 20)
        ]

        let pwdLabelConstraints = [
            pwdLabel.topAnchor.constraint(equalTo: emailTF.bottomAnchor, constant: 10),
            pwdLabel.leftAnchor.constraint(equalTo: emailTF.leftAnchor),
//            pwdLabel.heightAnchor.constraint(equalToConstant: 20),
            //pwdLabel.widthAnchor.constraint(equalToConstant: 80)
        ]

        let pwdTFConstraints = [
            pwdTF.topAnchor.constraint(equalTo: pwdLabel.bottomAnchor, constant: 10),
            pwdTF.leftAnchor.constraint(equalTo: pwdLabel.leftAnchor),
            pwdTF.rightAnchor.constraint(equalTo: signUpView.centerXAnchor, constant: -10),
//            pwdTF.heightAnchor.constraint(equalToConstant: 20)
        ]
        
        let pwdConfirmLabelConstraints = [
            pwdConfirmLabel.topAnchor.constraint(equalTo: pwdLabel.topAnchor),
            pwdConfirmLabel.leftAnchor.constraint(equalTo: signUpView.centerXAnchor, constant: 10),
//            pwdConfirmLabel.heightAnchor.constraint(equalToConstant: 20),
            //pwdConfirmLabel.widthAnchor.constraint(equalToConstant: 150)
        ]

        let pwdConfirmTFConstraints = [
            pwdConfirmTF.topAnchor.constraint(equalTo: pwdTF.topAnchor),
            pwdConfirmTF.leftAnchor.constraint(equalTo: pwdConfirmLabel.leftAnchor),
            pwdConfirmTF.rightAnchor.constraint(equalTo: emailTF.rightAnchor),
//            pwdTF.heightAnchor.constraint(equalToConstant: 20)
        ]
                
        let nameLabelConstraints = [
            nameLabel.topAnchor.constraint(equalTo: pwdTF.bottomAnchor, constant: 10),
            nameLabel.leftAnchor.constraint(equalTo: pwdTF.leftAnchor),
            //nameLabel.heightAnchor.constraint(equalToConstant: 20),
            //nameLabel.widthAnchor.constraint(equalToConstant: 80)
        ]
        
        let nameTFConstraints = [
            nameTF.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            nameTF.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            nameTF.rightAnchor.constraint(equalTo: signUpView.centerXAnchor, constant: -5),
//            nameTF.heightAnchor.constraint(equalToConstant: 20)
        ]
        
        let genderSelectConstraints = [
            genderSelect.topAnchor.constraint(equalTo: nameTF.topAnchor),
            genderSelect.rightAnchor.constraint(equalTo: signUpView.rightAnchor, constant: -10),
            genderSelect.leftAnchor.constraint(equalTo: signUpView.centerXAnchor),
//            genderSelect.heightAnchor.constraint(equalToConstant: 20)
        ]

        let phoneNumberLabelConstraints = [
            phoneNumberLabel.topAnchor.constraint(equalTo: nameTF.bottomAnchor, constant: 10),
            phoneNumberLabel.leftAnchor.constraint(equalTo: nameTF.leftAnchor),
            //phoneNumberLabel.widthAnchor.constraint(equalToConstant: 160),
//            phoneNumberLabel.heightAnchor.constraint(equalToConstant: 20)
        ]
        
        let phoneNumberInputConstraints = [
            phoneNumberInput.topAnchor.constraint(equalTo: phoneNumberLabel.bottomAnchor, constant: 10),
            phoneNumberInput.leftAnchor.constraint(equalTo: phoneNumberLabel.leftAnchor),
            phoneNumberInput.rightAnchor.constraint(equalTo: emailTF.rightAnchor),
//            phoneNumberInput.heightAnchor.constraint(equalToConstant: 20)
        ]

        let dateOfBirthLabelConstraints = [
            dateOfBirthLabel.topAnchor.constraint(equalTo: phoneNumberInput.bottomAnchor, constant: 10),
            dateOfBirthLabel.leftAnchor.constraint(equalTo: phoneNumberInput.leftAnchor),
//            dateOfBirthLabel.heightAnchor.constraint(equalToConstant: 20),
            //dateOfBirthLabel.widthAnchor.constraint(equalToConstant: 160)
        ]
        
        let birthDataFieldConstraints = [
            birthDataField.topAnchor.constraint(equalTo: dateOfBirthLabel.bottomAnchor, constant: 10),
            birthDataField.leftAnchor.constraint(equalTo: dateOfBirthLabel.leftAnchor),
            birthDataField.rightAnchor.constraint(equalTo: emailTF.rightAnchor),
//            birthDataField.heightAnchor.constraint(equalToConstant: 20)
        ]

        let guideLabelConstraints = [
            guideLabel.bottomAnchor.constraint(equalTo: signUpView.topAnchor, constant: -20),
            guideLabel.leftAnchor.constraint(equalTo: signUpView.leftAnchor, constant: 10)
        ]
        
        let welcomeLabelConstraints = [
            welcomeLabel.bottomAnchor.constraint(equalTo: guideLabel.topAnchor, constant: -10),
            welcomeLabel.leftAnchor.constraint(equalTo: guideLabel.leftAnchor, constant: -5)
        ]

        let signUpBtnConstraints = [
//            signUpBtn.topAnchor.constraint(equalTo: signUpView.bottomAnchor, constant: 20),
            signUpBtn.topAnchor.constraint(equalTo: signUpView.bottomAnchor, constant: 20),
            signUpBtn.leftAnchor.constraint(equalTo: signUpView.leftAnchor, constant: 25),
            signUpBtn.rightAnchor.constraint(equalTo: signUpView.rightAnchor, constant: -25),
            signUpBtn.heightAnchor.constraint(equalToConstant: 50)
        ]

        let askLabelConstraints = [
            askLabel.topAnchor.constraint(equalTo: signUpBtn.bottomAnchor, constant: 10),
            askLabel.leftAnchor.constraint(equalTo: signUpBtn.leftAnchor, constant: 10)
        ]
        
        let signInBtnConstraints = [
            signInBtn.topAnchor.constraint(equalTo: askLabel.topAnchor),
            signInBtn.centerYAnchor.constraint(equalTo: askLabel.centerYAnchor),
            signInBtn.rightAnchor.constraint(equalTo: signUpBtn.rightAnchor, constant: -10)
        ]
        
        [signUpViewConstraints, emailLabelConstraints, duplicateBtnConstraints, emailTFConstraints, pwdLabelConstraints, pwdTFConstraints, pwdConfirmLabelConstraints, pwdConfirmTFConstraints, nameLabelConstraints, nameTFConstraints, genderSelectConstraints, phoneNumberLabelConstraints, phoneNumberInputConstraints, dateOfBirthLabelConstraints, birthDataFieldConstraints, guideLabelConstraints, welcomeLabelConstraints, signUpBtnConstraints, askLabelConstraints, signInBtnConstraints]
            .forEach(NSLayoutConstraint.activate(_:))
    }
}

extension SignUpViewController {
    func initWelcomeLabel() {
        welcomeLabel = UILabel()
        welcomeLabel.text = "Create Account"
        welcomeLabel.font = welcomeLabel.font.withSize(40)
    }
    
    func initGuideLabel() {
        guideLabel = UILabel()
        guideLabel.text = "Sign up to get Started!"
        guideLabel.textColor = .systemGray
    }
    
    func initSignUpView() {
        signUpView = UIView()
    }
    
    func initEmailLabel() {
        emailLabel = UILabel()
        emailLabel.text = "Email"
    }
    
    func initDuplicateBtn() {
        duplicateBtn = UIButton()
        duplicateBtn.setTitle("중복 확인", for: .normal)
        duplicateBtn.setTitleColor(.white, for: .highlighted)
        duplicateBtn.backgroundColor = .systemBlue
        duplicateBtn.layer.cornerRadius = 8
        duplicateBtn.addTarget(self, action: #selector(didTapDuplicate), for: .touchUpInside)
    }

    func initPwdLabel() {
        pwdLabel = UILabel()
        pwdLabel.text = "Password"
    }
    
    func initPwdTF() {
        pwdTF = UITextField()
        pwdTF.placeholder = "Password"
        pwdTF.isSecureTextEntry = true
        pwdTF.delegate = self
        pwdTF.autocapitalizationType = .none
        pwdTF.borderStyle = .roundedRect
        pwdTF.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        let rightViewBtn = UIButton()
        rightViewBtn.setBackgroundImage(UIImage(systemName: "eye"), for: UIControl.State())
        rightViewBtn.addTarget(self, action: #selector(onShowPwdBtn(_:)), for: .touchUpInside)
        rightViewBtn.tintColor = .gray

        pwdTF.rightView = rightViewBtn
        pwdTF.rightViewMode = .always
        pwdTF.enablesReturnKeyAutomatically = true
    }

    func initPwdConfirmLabel() {
        pwdConfirmLabel = UILabel()
        pwdConfirmLabel.text = "Confirm Password"
    }
    
    func initPwdConfirmTF() {
        pwdConfirmTF = UITextField()
        pwdConfirmTF.placeholder = "Confirm Password"
        pwdConfirmTF.isSecureTextEntry = true
        pwdConfirmTF.delegate = self
        pwdConfirmTF.autocapitalizationType = .none
        pwdConfirmTF.borderStyle = .roundedRect
        pwdConfirmTF.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        let rightViewBtn = UIButton()
        rightViewBtn.setBackgroundImage(UIImage(systemName: "eye"), for: UIControl.State())
        rightViewBtn.addTarget(self, action: #selector(onShowPwdConfirmBtn(_:)), for: .touchUpInside)
        rightViewBtn.tintColor = .gray

        pwdConfirmTF.rightView = rightViewBtn
        pwdConfirmTF.rightViewMode = .always
        pwdConfirmTF.enablesReturnKeyAutomatically = true
    }

    func initNameLabel() {
        nameLabel = UILabel()
        nameLabel.text = "Name"
    }
    
    func initPhoneNumberLabel() {
        phoneNumberLabel = UILabel()
        phoneNumberLabel.text = "Phone number"
    }
    
    func initGenderSelect() {
        genderSelect = UISegmentedControl()
        genderSelect.insertSegment(withTitle: "Male", at: 0, animated: true)
        genderSelect.insertSegment(withTitle: "Female", at: 1, animated: true)
        genderSelect.insertSegment(withTitle: "None", at: 2, animated: true)
        genderSelect.addTarget(self, action: #selector(segmentDidEndEditing), for: .editingDidEnd)
    }

    func initDateOfBirthLabel() {
        dateOfBirthLabel = UILabel()
        dateOfBirthLabel.text = "Date of Birth"
    }

    func initBirthDataField() {
        birthDataField = UITextField()
        birthDataField.placeholder = "여기를 클릭해서 생년월일을 입력해주세요"
//        birthDataField.text = ""
        birthDataField.borderStyle = .roundedRect
        birthDataField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }
    
    func initEmailTF() {
        emailTF = UITextField()
        emailTF.placeholder = "kittydoc@jmsmart.co.kr"
        emailTF.keyboardType = .emailAddress
        emailTF.delegate = self
        emailTF.autocapitalizationType = .none
        emailTF.borderStyle = .roundedRect
        emailTF.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }

    func initNameTF() {
        nameTF = UITextField()
        nameTF.placeholder = "이복덩"
        nameTF.delegate = self
        nameTF.borderStyle = .roundedRect
        nameTF.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }
    
    func initPhoneNumberInput() {
        phoneNumberInput = UITextField()
        phoneNumberInput.placeholder = "01037757666"
        phoneNumberInput.borderStyle = .roundedRect
        phoneNumberInput.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }
    
    func initUpdatePicker() {
        datePicker = UIDatePicker()//UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.dataChanged), for: .allEvents)
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        self.birthDataField.inputView = datePicker
        
        let toolBar: UIToolbar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44)
        let space: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.tapOnDoneBtn))
        
        toolBar.setItems([space, done], animated: true)
        
        self.birthDataField.inputAccessoryView = toolBar
    }

    func initSignUpBtn() {
        signUpBtn = onOffButton()
        signUpBtn.setTitle("Sign Up", for: .normal)
        signUpBtn.setTitleColor(.white, for: .highlighted)
        signUpBtn.backgroundColor = .systemBlue
        signUpBtn.layer.cornerRadius = 8
        signUpBtn.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        signUpBtn.isOn = .Off
    }
        
    func initAskLabel() {
        askLabel = UILabel()
        askLabel.text = "Already have an Account?"
        
    }
    
    func initSignInBtn() {
        signInBtn = UIButton()
        signInBtn.setTitle("Sign In", for: .normal)
        signInBtn.setTitleColor(.systemIndigo, for: .normal)
        signInBtn.addTarget(self, action: #selector((didTapSignIn)), for: .touchUpInside)
        
    }
}

