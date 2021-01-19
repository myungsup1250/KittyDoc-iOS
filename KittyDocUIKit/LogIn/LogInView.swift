////
////  LogInView.swift
////  KittyDocUIKit
////
////  Created by 곽명섭 on 2021/01/17.
////
//
//import UIKit
//
//class VC: UIViewController {
//    let mainStoryboardName = "Main"
//    let signUpStoryboardID = "SignUp"
//}
//
//final class LogInView: UIView {
//    var userInfo: UserInfo! = UserInfo.shared
////    var emailTF: UITextField!
////    var pwTF: UITextField!
////    var signUpBtn: UIButton!
//
//    lazy var welcomeLabel: UILabel = {
//        let welcomeLabel = UILabel()
//        
////        welcomeLabel.frame = CGRect(x: 50, y: 150, width: self.frame.size.width, height: 80)
//        welcomeLabel.text = "Welcome".localized
//        welcomeLabel.font = welcomeLabel.font.withSize(40)
//        
//        return welcomeLabel
//    }()
//    
//    lazy var guideLabel: UILabel = {
//        let guideLabel = UILabel()
//        
////        guideLabel.frame = CGRect(x: 50, y: 200, width: self.frame.size.width, height: 40)
//        guideLabel.text = "Sign in to Continue".localized
//        guideLabel.textColor = .systemGray
//        
//        return guideLabel
//    }()
//    
//    lazy var emailLabel: UILabel = {
//        let emailLabel = UILabel()//(frame: CGRect(x: 0, y: 0, width: signInView.frame.size.width, height: 40))
////        emailLabel.frame = CGRect(x: 0, y: 0, width: signInView.frame.size.width, height: 40)
//        emailLabel.text = "Email"
//
//        return emailLabel
//    }()
//    
//    lazy var emailTF: UITextField = {
//        let emailTF = UITextField()//(frame: CGRect(x: 0, y: 40, width: signInView.frame.size.width, height: 40))
////        emailTF.frame = CGRect(x: 0, y: 40, width: signInView.frame.size.width, height: 40)
//        emailTF.placeholder = "kittydoc@jmsmart.co.kr"
////        emailTF.delegate = self
//        emailTF.autocapitalizationType = .none
//        return emailTF
//    }()
//    
//    lazy var pwLabel: UILabel = {
//        let pwLabel = UILabel()//(frame: CGRect(x: 0, y: 100, width: signInView.frame.size.width, height: 40))
////        pswLabel.frame = CGRect(x: 0, y: 100, width: signInView.frame.size.width, height: 40)
//        pwLabel.text = "Password"
//        
//        return pwLabel
//    }()
//    
//    lazy var pwTF: UITextField = {
//        let pwTF = UITextField()//(frame: CGRect(x: 0, y: 140, width: signInView.frame.size.width, height: 40))
////        pwTF.frame = CGRect(x: 0, y: 140, width: signInView.frame.size.width, height: 40)
//        pwTF.placeholder = "password"
//        pwTF.isSecureTextEntry = true
//
//        return pwTF
//    }()
//
//    lazy var logInBtn: UIButton = {
//        let logInBtn = UIButton()//(frame: CGRect(x: self.frame.midX - 150,y: 570, width: 300, height: 50))
//        
////        logInBtn.frame = CGRect(x: self.frame.midX - 150,y: 570, width: 300, height: 50)
//        logInBtn.setTitle("Sign in",for: .normal)//UIControl.State.normal
//        logInBtn.setTitleColor(.white, for: .highlighted)
//        logInBtn.backgroundColor = .systemBlue//UIColor.systemBlue
//        logInBtn.layer.cornerRadius = 8
////        logInBtn.addTarget(self, action: #selector(didTapSignIn), for: UIControl.Event.touchUpInside)
//
//        return logInBtn
//    }()
//
//    lazy var askLabel: UILabel = {
//        let askLabel = UILabel()//(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
////        askLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
//        askLabel.text = "Don't have an account?"
//        return askLabel
//    }()
//    
//    lazy var signUpBtn: UIButton = {
//        let signUpBtn = UIButton()//(frame: CGRect(x: 90, y: 0, width: 100, height: 50))
//        signUpBtn.frame = CGRect(x: 90, y: 0, width: 100, height: 50)
//        signUpBtn.setTitle("Sign Up", for: .normal)
//        signUpBtn.setTitleColor(.systemIndigo, for: .normal)
//
//        return signUpBtn
//    }()
//    
//    var isLoading: Bool = false {
//        didSet {
//            isLoading ? startLoading() : finishLoading()
//        }
//    }
//    
//    lazy var activityIndicator = ActivityIndicatorView(style: .medium)
//
//    init() {
//        super.init(frame: .zero)
//        
//        addSubviews()
//        setUpConstraints()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func addSubviews() {
//         [welcomeLabel, guideLabel, emailLabel, emailTF, pwLabel, pwTF, logInBtn, askLabel, signUpBtn]
//            .forEach {
//                addSubview($0)
//                $0.translatesAutoresizingMaskIntoConstraints = false
//        }
//    }
//
//    private func setUpConstraints() {
//        let welcomeLabelConstraints = [
//            welcomeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            welcomeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -100.0),
//            welcomeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 100.0),
//            welcomeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -100.0),
//            welcomeLabel.heightAnchor.constraint(equalToConstant: 100.0)
//        ]
//        
//        let guideLabelConstraints = [
//            guideLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            guideLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -80.0),
//            guideLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 100.0),
//            guideLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -100.0),
//            guideLabel.heightAnchor.constraint(equalToConstant: 80.0)
//        ]
//
//        let emailLabelConstraints = [
//            emailLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            emailLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30.0),
//            emailLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50.0),
//            emailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50.0),
//            emailLabel.heightAnchor.constraint(equalToConstant: 30.0)
//        ]
//        //emailLabel
////        let emailTFConstraints = [
////            emailTF.centerXAnchor.constraint(equalTo: self.centerXAnchor),
////            emailTF.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30.0),
////            emailTF.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50.0),
////            emailTF.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50.0),
////            emailTF.heightAnchor.constraint(equalToConstant: 30.0)
////        ]
//
//        let pwLabelConstraints = [
//            pwLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            pwLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30.0),
//            pwLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50.0),
//            pwLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50.0),
//            pwLabel.heightAnchor.constraint(equalToConstant: 30.0)
//        ]
//        
//        let logInBtnConstraints = [
//            logInBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            logInBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30.0),
//            logInBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50.0),
//            logInBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50.0),
//            logInBtn.heightAnchor.constraint(equalToConstant: 30.0)
//        ]
//        
//        let askLabelConstraints = [
//            askLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            askLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30.0),
//            askLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50.0),
//            askLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50.0),
//            askLabel.heightAnchor.constraint(equalToConstant: 30.0)
//        ]
//        
//        let signUpBtnConstraints = [
//            signUpBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            signUpBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30.0),
//            signUpBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50.0),
//            signUpBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50.0),
//            signUpBtn.heightAnchor.constraint(equalToConstant: 30.0)
//        ]
//        
//        let loginConstraints = [
//            emailTF.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            emailTF.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30.0),
//            emailTF.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50.0),
//            emailTF.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50.0),
//            emailTF.heightAnchor.constraint(equalToConstant: 30.0)
//        ]
//        
//        let passwordConstraints = [
//            pwTF.topAnchor.constraint(equalTo: emailTF.bottomAnchor, constant: 10.0),
//            pwTF.centerXAnchor.constraint(equalTo: emailTF.centerXAnchor),
//            pwTF.widthAnchor.constraint(equalTo: emailTF.widthAnchor, multiplier: 1.0),
//            pwTF.heightAnchor.constraint(equalTo: emailTF.heightAnchor)
//        ]
//
//        let loginButtonConstraints = [
//            logInBtn.topAnchor.constraint(equalTo: pwTF.bottomAnchor, constant: 20.0),
//            logInBtn.centerXAnchor.constraint(equalTo: pwTF.centerXAnchor),
//            logInBtn.widthAnchor.constraint(equalToConstant: 120.0),
//            logInBtn.heightAnchor.constraint(equalToConstant: 30.0)
//        ]
//
//        let activityIndicatorConstraints = [
//            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
//            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
//            activityIndicator.heightAnchor.constraint(equalToConstant: 50),
//            activityIndicator.widthAnchor.constraint(equalToConstant: 50.0)
//        ]
//
//        [welcomeLabelConstraints, guideLabelConstraints, emailLabelConstraints, pwLabelConstraints, logInBtnConstraints, askLabelConstraints, signUpBtnConstraints, loginConstraints, passwordConstraints, loginButtonConstraints, activityIndicatorConstraints
//        ]
//            .forEach(NSLayoutConstraint.activate(_:))
//    }
//
//    func startLoading() {
//        isUserInteractionEnabled = false
//        activityIndicator.isHidden = false
//        activityIndicator.startAnimating()
//    }
//    
//    func finishLoading() {
//        isUserInteractionEnabled = true
//        activityIndicator.stopAnimating()
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//}
