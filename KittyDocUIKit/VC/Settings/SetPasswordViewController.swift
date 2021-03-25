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
    var pwdLabel: UILabel!
    var pwdTF: UITextField!
    var pwdConfirmLabel: UILabel!
    var pwdConfirmTF: UITextField!

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
}

extension SetPasswordViewController {
    
    fileprivate func initUIViews() {
        initTitleLabel()
        initGuideLabel()
        initUserInfoView()
        initEmailLabel()
        initEmailTF()
        initPwdLabel()
        initPwdTF()
        initPwdConfirmLabel()
        initPwdConfirmTF()
        initSubmitBtn()
    }

    fileprivate func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(guideLabel)
        view.addSubview(userInfoView)
        userInfoView.addSubview(emailLabel)
        userInfoView.addSubview(emailTF)
        userInfoView.addSubview(pwdLabel)
        userInfoView.addSubview(pwdTF)
        userInfoView.addSubview(pwdConfirmLabel)
        userInfoView.addSubview(pwdConfirmTF)
        view.addSubview(submitBtn)
    }
    
    fileprivate func prepareForAutoLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        userInfoView.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTF.translatesAutoresizingMaskIntoConstraints = false
        pwdLabel.translatesAutoresizingMaskIntoConstraints = false
        pwdTF.translatesAutoresizingMaskIntoConstraints = false
        pwdConfirmLabel.translatesAutoresizingMaskIntoConstraints = false
        pwdConfirmTF.translatesAutoresizingMaskIntoConstraints = false
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

        let pwdLabelConstraints = [
            pwdLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 30),
            pwdLabel.leftAnchor.constraint(equalTo: emailLabel.leftAnchor),
//            pwdLabel.heightAnchor.constraint(equalToConstant: 20),
            pwdLabel.widthAnchor.constraint(equalToConstant: 120)
        ]

        let pwdTFConstraints = [
            pwdTF.centerYAnchor.constraint(equalTo: pwdLabel.centerYAnchor),
//            pwdTF.topAnchor.constraint(equalTo: pwdLabel.topAnchor),
            pwdTF.leftAnchor.constraint(equalTo: pwdLabel.rightAnchor, constant: 10),
            pwdTF.rightAnchor.constraint(equalTo: emailTF.rightAnchor),
//            pwdTF.heightAnchor.constraint(equalToConstant: 20)
        ]

        let pwdConfirmLabelConstraints = [
            pwdConfirmLabel.topAnchor.constraint(equalTo: pwdLabel.bottomAnchor, constant: 30),
            pwdConfirmLabel.leftAnchor.constraint(equalTo: pwdLabel.leftAnchor),
//            pwdConfirmLabel.heightAnchor.constraint(equalToConstant: 20),
            pwdConfirmLabel.widthAnchor.constraint(equalToConstant: 120)
        ]

        let pwdConfirmTFConstraints = [
            pwdConfirmTF.centerYAnchor.constraint(equalTo: pwdConfirmLabel.centerYAnchor),
//            pwdConfirmTF.topAnchor.constraint(equalTo: pwdConfirmLabel.topAnchor),
            pwdConfirmTF.leftAnchor.constraint(equalTo: pwdConfirmLabel.rightAnchor, constant: 10),
            pwdConfirmTF.rightAnchor.constraint(equalTo: emailTF.rightAnchor),
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
        

        [userInfoViewConstraints, emailLabelConstraints, emailTFConstraints, pwdLabelConstraints, pwdTFConstraints, pwdConfirmLabelConstraints, pwdConfirmTFConstraints, guideLabelConstraints, titleLabelConstraints, submitBtnConstraints]
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

    func initUserInfoView() {
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
        //emailTF.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        emailTF.isEnabled = false
    }

    func initPwdLabel() {
        pwdLabel = UILabel()
        pwdLabel.text = "Current Password"
    }
    
    func initPwdTF() {
        pwdTF = UITextField()
        pwdTF.text = UserInfo.shared.Name
        pwdTF.delegate = self
        pwdTF.borderStyle = .roundedRect
        let rightViewBtn = UIButton()
        rightViewBtn.setBackgroundImage(UIImage(systemName: "eye"), for: UIControl.State())
        rightViewBtn.addTarget(self, action: #selector(onShowPwdBtn(_:)), for: .touchUpInside)
        rightViewBtn.tintColor = .gray
        
        pwdTF.rightView = rightViewBtn
        pwdTF.rightViewMode = .always
        pwdTF.enablesReturnKeyAutomatically = true
    }

    @objc private func onShowPwdBtn(_ sender: UIButton) {//onClickSwitch(_ sender: UISwitch)
        //print("onClickSwitch(UISwitch : \(showPwdSwitch.isOn))")
        print("onShowPwdBtn()")
        pwdTF.isSecureTextEntry.toggle()
    }

    func initPwdConfirmLabel() {
        pwdConfirmLabel = UILabel()
        pwdConfirmLabel.text = "New Password"
    }
    
    func initPwdConfirmTF() {
        pwdConfirmTF = UITextField()
        pwdConfirmTF.text = UserInfo.shared.Name
        pwdConfirmTF.delegate = self
        pwdConfirmTF.borderStyle = .roundedRect
        let rightViewBtn = UIButton()
        rightViewBtn.setBackgroundImage(UIImage(systemName: "eye"), for: UIControl.State())
        rightViewBtn.addTarget(self, action: #selector(onShowPwdConfirmBtn(_:)), for: .touchUpInside)
        rightViewBtn.tintColor = .gray
        
        pwdConfirmTF.rightView = rightViewBtn
        pwdConfirmTF.rightViewMode = .always
        pwdConfirmTF.enablesReturnKeyAutomatically = true
    }
    @objc private func onShowPwdConfirmBtn(_ sender: UIButton) {//onClickSwitch(_ sender: UISwitch)
        //print("onClickSwitch(UISwitch : \(showPwdSwitch.isOn))")
        print("onShowPwdConfirmBtn()")
        pwdConfirmTF.isSecureTextEntry.toggle()
    }

    func initSubmitBtn() {
        submitBtn = onOffButton()
        submitBtn.setTitle("Submit", for: .normal)
        submitBtn.setTitleColor(.white, for: .highlighted)
        submitBtn.backgroundColor = .systemBlue
        submitBtn.layer.cornerRadius = 8
        //submitBtn.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        //submitBtn.isOn = .On
    }

    
    // curPwd, newPwd, newConfirmPwd 세개로 늘려야할 것!!!!
}
