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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emailInput: UITextField = {
            let emailInput = UITextField()
            emailInput.frame = CGRect(x: 0, y: 30, width: signUpView.frame.size.width, height: 30)
            emailInput.placeholder = "kittydoc@jmsmart.co.kr"
            emailInput.keyboardType = .emailAddress
            emailInput.delegate = self
            return emailInput
        }()
        
        let pwdInput: UITextField = {
            let pwdInput = UITextField()
            pwdInput.frame = CGRect(x: 0, y: 100, width: signUpView.frame.size.width, height: 30)
            pwdInput.placeholder = "password"
            pwdInput.isSecureTextEntry = true
            pwdInput.delegate = self
            return pwdInput
        }()
        
        let nameInput: UITextField = {
            let nameInput = UITextField()
            nameInput.frame = CGRect(x: 0, y: 170, width: signUpView.frame.size.width, height: 30)
            nameInput.placeholder = "이복덩"
            nameInput.delegate = self
            return nameInput
        }()
        
        let phoneNumberInput: UITextField = {
            let phoneNumberInput = UITextField()
            phoneNumberInput.frame = CGRect(x: 0, y: 230, width: view.frame.size.width, height: 50)
            phoneNumberInput.placeholder = "01037757666"
            return phoneNumberInput
        }()
        
           
        view.addSubview(welcomeLabel)
        view.addSubview(plz)
        
        view.addSubview(signUpView)
        signUpView.addSubview(emailLabel)
        signUpView.addSubview(emailInput)
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


        setUpdatePicker()
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
        let done: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapOnDoneBtn))
        
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
        print(birthInput ?? "00000000")
    }

    @objc func tapOnDoneBtn() {
        birthDataField.resignFirstResponder()
    }
    
    let doneBtn: UIButton = {
        let doneBtn = UIButton()
        doneBtn.frame = CGRect(x: 40, y: 610, width: 300, height: 50)
        doneBtn.setTitle("Register", for: .normal)
        doneBtn.setTitleColor(.white, for: .highlighted)
        doneBtn.backgroundColor = .systemBlue
        doneBtn.layer.cornerRadius = 8
        doneBtn.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        
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
        //이미 아이디 있는 경우
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    @objc private func didTapRegister() {
        //여기서 UITextField에 대한 접근이 불가능한듯 모두 ViewDidLoad함수 안의 로컬 변수들로 추정!
        print(emailInput.text!) //이메일
        print(pwdInput.text!)  //비번
        print(nameInput.text!) //이름
        print(phoneNumberInput.text!) //뽄넘버
        print(genderSelect.selectedSegmentIndex) //성별 @@@ -1 = 선택안함, 0 = 남성, 1 = 여성, 2 = None
        print(birthInput ?? 00000000) //생년월일!
        
        
        //만약 회원가입 성공하면 현재창 없어지게 만들기
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

   

}

