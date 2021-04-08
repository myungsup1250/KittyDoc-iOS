//
//  SetPasswordViewController.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/03/18.
//

import UIKit

class SetPasswordViewController: UIViewController, UITextFieldDelegate {
    var userInterfaceStyle: UIUserInterfaceStyle = .unspecified
    var safeArea: UILayoutGuide!

    var titleLabel: UILabel!
    var guideLabel: UILabel!
    var userInfoView: UIView!
    var emailLabel: UILabel!
    var emailTF: UITextField!
    var curPwdLabel: UILabel!
    var curPwdTF: UITextField!
    var newPwdLabel: UILabel!
    var newPwdTF: UITextField!
    var newPwdConfirmLabel: UILabel!
    var newPwdConfirmTF: UITextField!

    var submitBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userInterfaceStyle = self.traitCollection.userInterfaceStyle
        
        print("AnalysisViewController.viewDidLoad()")
        safeArea = view.layoutMarginsGuide
        initUIViews()
        addSubviews()
        prepareForAutoLayout()
        setConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }

    @objc private func onShowCurPwdBtn(_ sender: UIButton) {//onClickSwitch(_ sender: UISwitch)
        //print("onClickSwitch(UISwitch : \(showPwdSwitch.isOn))")
        print("onShowCurPwdBtn()")
        curPwdTF.isSecureTextEntry.toggle()
        let eyeButton = curPwdTF.rightView as! UIButton
        if curPwdTF.isSecureTextEntry {
            eyeButton.setBackgroundImage(UIImage(systemName: "eye.slash"), for: UIControl.State())
        } else {
            eyeButton.setBackgroundImage(UIImage(systemName: "eye"), for: UIControl.State())
        }
    }

    @objc private func onShowNewPwdBtn(_ sender: UIButton) {//onClickSwitch(_ sender: UISwitch)
        //print("onClickSwitch(UISwitch : \(showPwdSwitch.isOn))")
        print("onShowNewPwdBtn()")
        newPwdTF.isSecureTextEntry.toggle()
        let eyeButton = newPwdTF.rightView as! UIButton
        if newPwdTF.isSecureTextEntry {
            eyeButton.setBackgroundImage(UIImage(systemName: "eye.slash"), for: UIControl.State())
        } else {
            eyeButton.setBackgroundImage(UIImage(systemName: "eye"), for: UIControl.State())
        }
    }
    
    @objc private func onShowNewPwdConfirmBtn(_ sender: UIButton) {//onClickSwitch(_ sender: UISwitch)
        //print("onClickSwitch(UISwitch : \(showPwdSwitch.isOn))")
        print("onShowNewPwdConfirmBtn()")
        newPwdConfirmTF.isSecureTextEntry.toggle()
        let eyeButton = newPwdConfirmTF.rightView as! UIButton
        if newPwdConfirmTF.isSecureTextEntry {
            eyeButton.setBackgroundImage(UIImage(systemName: "eye.slash"), for: UIControl.State())
        } else {
            eyeButton.setBackgroundImage(UIImage(systemName: "eye"), for: UIControl.State())
        }
    }
}

extension SetPasswordViewController {
    
    fileprivate func initUIViews() {
        initLabels()
        initUserInfoView()
        initEmailTF()
        initCurPwdTF()
        initNewPwdTF()
        initNewPwdConfirmTF()
        initSubmitBtn()
    }

    fileprivate func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(guideLabel)
        view.addSubview(userInfoView)
        userInfoView.addSubview(emailLabel)
        userInfoView.addSubview(emailTF)
        userInfoView.addSubview(curPwdLabel)
        userInfoView.addSubview(curPwdTF)
        userInfoView.addSubview(newPwdLabel)
        userInfoView.addSubview(newPwdTF)
        userInfoView.addSubview(newPwdConfirmLabel)
        userInfoView.addSubview(newPwdConfirmTF)
        view.addSubview(submitBtn)
    }
    
    fileprivate func prepareForAutoLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        userInfoView.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTF.translatesAutoresizingMaskIntoConstraints = false
        curPwdLabel.translatesAutoresizingMaskIntoConstraints = false
        curPwdTF.translatesAutoresizingMaskIntoConstraints = false
        newPwdLabel.translatesAutoresizingMaskIntoConstraints = false
        newPwdTF.translatesAutoresizingMaskIntoConstraints = false
        newPwdConfirmLabel.translatesAutoresizingMaskIntoConstraints = false
        newPwdConfirmTF.translatesAutoresizingMaskIntoConstraints = false
        submitBtn.translatesAutoresizingMaskIntoConstraints = false
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

        let curPwdLabelConstraints = [
            curPwdLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 30),
            curPwdLabel.leftAnchor.constraint(equalTo: emailLabel.leftAnchor),
//            curPwdLabel.heightAnchor.constraint(equalToConstant: 20),
            curPwdLabel.widthAnchor.constraint(equalToConstant: 120)
        ]

        let curPwdTFConstraints = [
            curPwdTF.centerYAnchor.constraint(equalTo: curPwdLabel.centerYAnchor),
//            curPwdTF.topAnchor.constraint(equalTo: curPwdLabel.topAnchor),
            curPwdTF.leftAnchor.constraint(equalTo: curPwdLabel.rightAnchor, constant: 10),
            curPwdTF.rightAnchor.constraint(equalTo: emailTF.rightAnchor),
//            pwdTF.heightAnchor.constraint(equalToConstant: 20)
        ]

        let newPwdLabelConstraints = [
            newPwdLabel.topAnchor.constraint(equalTo: curPwdLabel.bottomAnchor, constant: 30),
            newPwdLabel.leftAnchor.constraint(equalTo: curPwdLabel.leftAnchor),
//            newPwdLabel.heightAnchor.constraint(equalToConstant: 20),
            newPwdLabel.widthAnchor.constraint(equalToConstant: 120)
        ]

        let newPwdTFConstraints = [
            newPwdTF.centerYAnchor.constraint(equalTo: newPwdLabel.centerYAnchor),
//            newPwdTF.topAnchor.constraint(equalTo: newPwdLabel.topAnchor),
            newPwdTF.leftAnchor.constraint(equalTo: newPwdLabel.rightAnchor, constant: 10),
            newPwdTF.rightAnchor.constraint(equalTo: emailTF.rightAnchor),
//            newPwdTF.heightAnchor.constraint(equalToConstant: 20)
        ]

        let newPwdConfirmLabelConstraints = [
            newPwdConfirmLabel.topAnchor.constraint(equalTo: newPwdLabel.bottomAnchor, constant: 30),
            newPwdConfirmLabel.leftAnchor.constraint(equalTo: newPwdLabel.leftAnchor),
//            newPwdConfirmLabel.heightAnchor.constraint(equalToConstant: 20),
            newPwdConfirmLabel.widthAnchor.constraint(equalToConstant: 120)
        ]

        let newPwdConfirmTFConstraints = [
            newPwdConfirmTF.centerYAnchor.constraint(equalTo: newPwdConfirmLabel.centerYAnchor),
//            newPwdConfirmTF.topAnchor.constraint(equalTo: newPwdConfirmLabel.topAnchor),
            newPwdConfirmTF.leftAnchor.constraint(equalTo: newPwdConfirmLabel.rightAnchor, constant: 10),
            newPwdConfirmTF.rightAnchor.constraint(equalTo: emailTF.rightAnchor),
//            pwdConfirmTF.heightAnchor.constraint(equalToConstant: 20)
        ]

        let guideLabelConstraints = [
            guideLabel.bottomAnchor.constraint(equalTo: userInfoView.topAnchor, constant: -50),
            guideLabel.leftAnchor.constraint(equalTo: userInfoView.leftAnchor, constant: 10)
        ]

        let titleLabelConstraints = [
            titleLabel.bottomAnchor.constraint(equalTo: guideLabel.topAnchor, constant: -10),
            titleLabel.leftAnchor.constraint(equalTo: guideLabel.leftAnchor, constant: -5)
        ]

        let submitBtnConstraints = [
            submitBtn.topAnchor.constraint(equalTo: userInfoView.bottomAnchor, constant: 50),
            submitBtn.leftAnchor.constraint(equalTo: userInfoView.leftAnchor, constant: 20),
            submitBtn.rightAnchor.constraint(equalTo: userInfoView.rightAnchor, constant: -20),
            submitBtn.heightAnchor.constraint(equalToConstant: 50)
        ]
        

        [userInfoViewConstraints, emailLabelConstraints, emailTFConstraints, curPwdLabelConstraints, curPwdTFConstraints, newPwdLabelConstraints, newPwdTFConstraints, newPwdConfirmLabelConstraints, newPwdConfirmTFConstraints, guideLabelConstraints, titleLabelConstraints, submitBtnConstraints]
            .forEach(NSLayoutConstraint.activate(_:))
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SetPasswordViewController {
    func initLabels() {
        titleLabel = UILabel()
        titleLabel.text = "Change Password"
        titleLabel.font = titleLabel.font.withSize(40)

        guideLabel = UILabel()
        guideLabel.text = "Modify Your Password"
        guideLabel.textColor = .systemGray

        emailLabel = UILabel()
        emailLabel.text = "Email"

        curPwdLabel = UILabel()
        curPwdLabel.text = "Current PW"

        newPwdLabel = UILabel()
        newPwdLabel.text = "New PW"

        newPwdConfirmLabel = UILabel()
        newPwdConfirmLabel.text = "Confirm PW"
    }

    func initUserInfoView() {
        userInfoView = UIView()
    }

    func initEmailTF() {
        emailTF = UITextField()
        emailTF.text = UserInfo.shared.Email
        emailTF.isEnabled = false // 수정 못하도록 비활성화
        emailTF.textColor = .systemGray
        emailTF.keyboardType = .emailAddress
        emailTF.delegate = self
        emailTF.autocapitalizationType = .none
        emailTF.borderStyle = .roundedRect
        //emailTF.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }

    func initCurPwdTF() {
        curPwdTF = UITextField()
        //curPwdTF.text = ""
        curPwdTF.delegate = self
        curPwdTF.borderStyle = .roundedRect
        let rightViewBtn = UIButton()
        rightViewBtn.setBackgroundImage(UIImage(systemName: "eye.slash"), for: UIControl.State())
        rightViewBtn.addTarget(self, action: #selector(onShowCurPwdBtn(_:)), for: .touchUpInside)
        rightViewBtn.tintColor = .gray
        
        curPwdTF.rightView = rightViewBtn
        curPwdTF.rightViewMode = .always
        curPwdTF.isSecureTextEntry = true
        curPwdTF.enablesReturnKeyAutomatically = true
    }

    func initNewPwdTF() {
        newPwdTF = UITextField()
        //newPwdTF.text = ""
        newPwdTF.delegate = self
        newPwdTF.borderStyle = .roundedRect
        let rightViewBtn = UIButton()
        rightViewBtn.setBackgroundImage(UIImage(systemName: "eye.slash"), for: UIControl.State())
        rightViewBtn.addTarget(self, action: #selector(onShowNewPwdBtn(_:)), for: .touchUpInside)
        rightViewBtn.tintColor = .gray
        
        newPwdTF.rightView = rightViewBtn
        newPwdTF.rightViewMode = .always
        newPwdTF.isSecureTextEntry = true
        newPwdTF.enablesReturnKeyAutomatically = true
    }

    func initNewPwdConfirmTF() {
        newPwdConfirmTF = UITextField()
        //newPwdConfirmTF.text = ""
        newPwdConfirmTF.delegate = self
        newPwdConfirmTF.borderStyle = .roundedRect
        let rightViewBtn = UIButton()
        rightViewBtn.setBackgroundImage(UIImage(systemName: "eye.slash"), for: UIControl.State())
        rightViewBtn.addTarget(self, action: #selector(onShowNewPwdConfirmBtn(_:)), for: .touchUpInside)
        rightViewBtn.tintColor = .gray
        
        newPwdConfirmTF.rightView = rightViewBtn
        newPwdConfirmTF.rightViewMode = .always
        newPwdConfirmTF.isSecureTextEntry = true
        newPwdConfirmTF.enablesReturnKeyAutomatically = true
    }

    func initSubmitBtn() {
        submitBtn = onOffButton()
        submitBtn.setTitle("Submit", for: .normal)
        submitBtn.setTitleColor(.white, for: .highlighted)
        submitBtn.backgroundColor = .systemBlue
        submitBtn.layer.cornerRadius = 8
        submitBtn.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        //submitBtn.isOn = .On
    }
    
    @objc func didTapSubmit() {
        print("didTapSubmit")
        let loginData:LoginData = LoginData(_userEmail: emailTF.text!, _userPwd: curPwdTF.text!)
        let server:KittyDocServer = KittyDocServer()
        let loginResponse:ServerResponse = server.userLogin(data: loginData)
        
        print(loginResponse.getCode())
        
        if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_WRONG_PWD){
            alertWithMessage(message: "현재 비밀번호를 올바르게 입력하세요")
            return
        }else if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_FAILURE){
            alertWithMessage(message: "unknown error")
            return
        }else if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_WRONG_EMAIL){
            alertWithMessage(message: "unknown error")
            return
        }
        
        if(!isPwdForm(_pwd: newPwdTF.text ?? "")){
            alertWithMessage(message: "패스워드를 입력하지 않으셨거나 올바른 패스워드 형식이 아닙니다.")
            return
        }
        if(!(newPwdTF.text == newPwdConfirmTF.text)){
            alertWithMessage(message: "새로운 비밀번호와 비밀번호 확인은 동일해야 합니다.")
            return
        }
        
        let modifyData:ModifyData_Pwd = ModifyData_Pwd(_userEmail: emailTF.text!, _userPwd: newPwdConfirmTF.text!)
        let modifyResponse:ServerResponse = server.pwdModify(data: modifyData)
        
        print("modifyData")
        print(modifyData.data())
        
        if(modifyResponse.getCode() as! Int == ServerResponse.EDIT_SUCCESS){
            print("수정완료")
            self.navigationController?.popViewController(animated: true)
            //여기서 다른화면으로 넘어가면됨~
            return
        }else{
            alertWithMessage(message: "비밀번호 수정을 실패하였습니다.")
            return
        }
    }
    
    func alertWithMessage(message input: Any) {
        let alert = UIAlertController(title: "", message: input as? String, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        self.present(alert, animated: false)
    }
    
    //To Do: 비밀번호 형식에 대한 부분은 추후에 논의 필요
    func isPwdForm(_pwd:String) -> Bool{
        if _pwd.count > 0 {
            return true
        } else {
            return false
        }
    }
}
