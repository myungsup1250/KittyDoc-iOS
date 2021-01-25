//
//  SignUpViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/15.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    var emailInput: UITextField!
    var pwdInput: UITextField!
    var nameInput: UITextField!
    var phoneNumberInput: UITextField!
    var birthInput: String?
    var didDupEx: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _: UITextField = {
            emailInput = UITextField()
            emailInput.frame = CGRect(x: 0, y: 30, width: signUpView.frame.size.width, height: 30)
            emailInput.placeholder = "kittydoc@jmsmart.co.kr"
            emailInput.keyboardType = .emailAddress
            emailInput.delegate = self
            emailInput.autocapitalizationType = .none
            emailInput.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
            return emailInput
        }()
        
        let _: UITextField = {
            pwdInput = UITextField()
            pwdInput.frame = CGRect(x: 0, y: 100, width: signUpView.frame.size.width, height: 30)
            pwdInput.placeholder = "password"
            pwdInput.isSecureTextEntry = true
            pwdInput.delegate = self
            pwdInput.autocapitalizationType = .none
            pwdInput.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
            return pwdInput
        }()
        
        let _: UITextField = {
            nameInput = UITextField()
            nameInput.frame = CGRect(x: 0, y: 170, width: signUpView.frame.size.width, height: 30)
            nameInput.placeholder = "이복덩"
            nameInput.delegate = self
            nameInput.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
            return nameInput
        }()
        
        let _: UITextField = {
            phoneNumberInput = UITextField()
            phoneNumberInput.frame = CGRect(x: 0, y: 230, width: view.frame.size.width, height: 50)
            phoneNumberInput.placeholder = "01037757666"
            phoneNumberInput.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
            return phoneNumberInput
        }()
        
           
        view.addSubview(welcomeLabel)
        view.addSubview(plz)
        
        view.addSubview(signUpView)
        signUpView.addSubview(emailLabel)
        signUpView.addSubview(emailInput)
        signUpView.addSubview(duplicateBtn)
        signUpView.addSubview(pwdLabel)
        signUpView.addSubview(pwdInput)
        signUpView.addSubview(nameLabel)
        signUpView.addSubview(nameInput)
        signUpView.addSubview(phoneNumberLabel)
        signUpView.addSubview(phoneNumberInput)
        signUpView.addSubview(genderSelect)
        signUpView.addSubview(DateOfBirthLabel)
        signUpView.addSubview(birthDataField)
        
        view.addSubview(signInView)
        signInView.addSubview(signInBtn)
        signInView.addSubview(askLabel)

        
        view.addSubview(doneBtn)
        view.addSubview(signInView)


        _ = setUpdatePicker()
        
        
    }
    
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        if emailInput.hasText && pwdInput.hasText && nameInput.hasText && phoneNumberInput.hasText && birthInput != nil && genderSelect.selectedSegmentIndex != -1 {
            doneBtn.isOn = .On
        }
        
        else {
            doneBtn.isOn = .Off
        }
    }
    
    @objc func segmentDidEndEditing(_ segment: UISegmentedControl) {
        if emailInput.hasText && pwdInput.hasText && nameInput.hasText && phoneNumberInput.hasText && birthInput != nil && genderSelect.selectedSegmentIndex != -1 {
            doneBtn.alpha = 1.0
        }
        else {
            doneBtn.alpha = 0.5
        }
    }
    
    
    let welcomeLabel: UILabel = {
        let welcomeLabel = UILabel()
        welcomeLabel.frame = CGRect(x: 40, y: 80, width: 350, height: 80)
        welcomeLabel.text = "Create Account"
        welcomeLabel.font = welcomeLabel.font.withSize(40)
        return welcomeLabel
    }()
    
    let plz: UILabel = {
        let plz = UILabel()
        plz.frame = CGRect(x: 40, y: 130, width: 200, height: 40)
        plz.text = "Sign up to get Started!"
        plz.textColor = .systemGray
        return plz
    }()
    
    let signUpView: UIView = {
        let signUpView = UIView()
        signUpView.frame = CGRect(x: 40, y: 210, width: 300, height: 300)
        
        return signUpView
    }()
    
    
    let emailLabel: UILabel = {
        let emailLabel = UILabel()
        emailLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        emailLabel.text = "Email"
        return emailLabel
    }()
    
    
    let duplicateBtn: UIButton = {
        let duBtn = UIButton()
        duBtn.frame = CGRect(x: 160, y: 0, width: 100, height: 20)
        duBtn.setTitle("중복 확인", for: .normal)
        duBtn.setTitleColor(.white, for: .highlighted)
        duBtn.backgroundColor = .systemBlue
        duBtn.layer.cornerRadius = 8
        duBtn.addTarget(self, action: #selector(didTapDuplicate), for: .touchUpInside)
        
        return duBtn
    }()
           
    

    let pwdLabel: UILabel = {
        let pwdLabel = UILabel()
        pwdLabel.frame = CGRect(x: 0, y: 70, width: 200, height: 30)
        pwdLabel.text = "Password"
        return pwdLabel
    }()
       

    
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 0, y: 140, width: 200, height: 30)
        nameLabel.text = "Name"
        return nameLabel
    }()
    

    let phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 200, width: 200, height: 50)
        label.text = "Phone number"
        return label
    }()
    
    let genderSelect: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.frame = CGRect(x: 120, y: 170, width: 180, height: 30)
        segment.insertSegment(withTitle: "Male", at: 0, animated: true)
        segment.insertSegment(withTitle: "Female", at: 1, animated: true)
        segment.insertSegment(withTitle: "None", at: 2, animated: true)
        segment.addTarget(self, action: #selector(segmentDidEndEditing), for: .editingDidEnd)
        return segment
    }()



    let DateOfBirthLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 270, width: 200, height: 50)
        label.text = "Date of Birth"
        return label
    }()

    let birthDataField: UITextField = {
        let birthDataField = UITextField()
        birthDataField.frame = CGRect(x: 0, y: 280, width: 300, height: 80)
        birthDataField.placeholder = "여기를 클릭해서 생년월일을 입력해주세요"
        birthDataField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)

        return birthDataField
    }()
    
    
    func setUpdatePicker() -> UIDatePicker {
        let picker: UIDatePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
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
        dateFormatter.dateStyle = .medium
        
        self.birthDataField.text = dateFormatter.string(from: picker.date)
        print(dateFormatter.string(from: picker.date))
        
        let writedateFormatter = DateFormatter()
        writedateFormatter.dateFormat = "yyyyMMdd"
        birthInput = writedateFormatter.string(from: picker.date)
    }

    @objc func tapOnDoneBtn(_ picker: UIDatePicker) {
        birthDataField.resignFirstResponder()
        
    }
    
    let doneBtn: onOffButton = {
        let doneBtn = onOffButton()
        doneBtn.frame = CGRect(x: 40, y: 610, width: 300, height: 50)
        doneBtn.setTitle("Register", for: .normal)
        doneBtn.setTitleColor(.white, for: .highlighted)
        doneBtn.backgroundColor = .systemBlue
        doneBtn.layer.cornerRadius = 8
        doneBtn.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        doneBtn.isOn = .Off
        return doneBtn
    }()

    
    let signInView: UIView = {
        let signInView = UIView()
        signInView.frame = CGRect(x: 50, y: 680, width: 350, height: 50)
        
        return signInView
    }()
    
    let askLabel: UILabel = {
        let askLabel = UILabel()
        askLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        askLabel.text = "Already have an Account?"
        
        return askLabel
    }()

    let signInBtn: UIButton = {
        let signInBtn = UIButton()
        signInBtn.frame = CGRect(x: 190, y: 0, width: 100, height: 50)
        signInBtn.setTitle("Sign In", for: .normal)
        signInBtn.setTitleColor(.systemIndigo, for: .normal)
        signInBtn.addTarget(self, action: #selector((didTapSignIn)), for: .touchUpInside)
        
        return signInBtn
    }()
    
    
    @objc private func didTapSignIn() {
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapDuplicate() {
        if(!isEmailForm(_email:emailInput.text!)){
            alertWithMessage(message: "올바른 이메일 형식이 아닙니다")
            return
        }
        
        //중복 확인 버튼 눌렀을 때
        let existData:ExistData = ExistData(_userEmail:emailInput.text!)
        let server:KittyDocServer = KittyDocServer()
        let existResponse:ServerResponse = server.userExist(data: existData)
        
        //아이디 중복여부 분기. 여기서 중복과 관련된 동작을 처리하면됨!
        //중복확인 하기 전에는 레지스터 버튼이 회색, 중복확인 버튼은 파란색
        //중복확인 하고난 후에는 레지스터 버튼이 파란색, 중복확인 버튼은 회색 이었으면 좋겠다고 생각!
        //근데 기능은 색에 상관없이 적용되었슴다
        
        //RE: 사용자가 칸 다 채워놓고 중복확인 안했을 경우 잉 왜 버튼 투명이야 띠용 이런 경우가 많을 거 같아서
        //    register 버튼 눌렀을 때 중복확인 하세요! 팝업을 띄우는 걸로 해봤는데 어때?!
        if(existResponse.getCode() as! Int == ServerResponse.EXIST_IS_EXIST){
            alertWithMessage(message: existResponse.getMessage())
            
        }else if(existResponse.getCode() as! Int == ServerResponse.EXIST_NOT_EXIST){
            alertWithMessage(message: existResponse.getMessage())
            didDupEx = true
            doneBtn.isEnabled = true
            emailInput.isEnabled = false
            duplicateBtn.isEnabled = false
            emailInput.textColor = .systemGray
            duplicateBtn.backgroundColor = .systemGray
        }else{
            alertWithMessage(message: existResponse.getMessage())
        }
    }
    
    @objc private func didTapRegister() {
        print(genderSelect.selectedSegmentIndex) //성별 @@@ -1 = 선택안함, 0 = 남성, 1 = 여성, 2 = None
        var gender:String="None"
        if(genderSelect.selectedSegmentIndex == 0){
            gender="Male"
        }else if(genderSelect.selectedSegmentIndex == 1){
            gender="FeMale"
        }else{
            gender="None"
        }
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let birth:String = birthInput ?? dateFormatter.string(from: date)
        
        if(!isPwdForm(_pwd:pwdInput.text!)){
            alertWithMessage(message: "비밀번호는 1글자 이상이어야 합니다.")
            print(birth)
            return
        }
        if(!isPhoneForm(_phone:phoneNumberInput.text!)){
            alertWithMessage(message: "올바른 전화번호 형식이 아닙니다.")
            return
        }
        if(nameInput.text!.count < 1){
            alertWithMessage(message: "이름을 입력하세요.")
            return
        }
        //생일에 대해서만 너가 조건문을 작성해주면좋겠어... 아래 작성한 함수 제대로 동작못한당... TEST
    
        if(birthInput == nil){
            alertWithMessage(message: "생일을 입력하세요.")
            return
        }
        
        if(didDupEx == false){
            alertWithMessage(message: "이메일 중복확인을 해주세요.")
            return
        }
        
        
        let signUpData:SignUpData = SignUpData(_userEmail:emailInput.text!, _userPwd:pwdInput.text!, _userName:nameInput.text!, _userPhone:phoneNumberInput.text!, _userSex:gender, _userBirth:birth)
        let server:KittyDocServer = KittyDocServer()
        let signUpResponse:ServerResponse = server.userSignUp(data: signUpData)

        if(signUpResponse.getCode() as! Int == ServerResponse.JOIN_SUCCESS){
            alertWithMessage(message: signUpResponse.getMessage())
            print(signUpResponse.getMessage())
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
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
    func isEmailForm(_email:String) -> Bool{
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,50}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailReg)
        return emailTest.evaluate(with: _email)
    }
    
    //비밀번호 형식에 대한 검사함수. 지금은 길이가 1이상만 되면 되는 것으로 했지만 추후에 특수문자포함여부, 길이제한 추가
    //하게 될지도?
    func isPwdForm(_pwd:String) -> Bool{
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

