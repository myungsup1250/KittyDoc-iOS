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
//        welcomeLabel.text = "Welcome".localized
//        welcomeLabel.font = welcomeLabel.font.withSize(40)
//
//        return welcomeLabel
//    }()
//
//    lazy var guideLabel: UILabel = {
//        let guideLabel = UILabel()
//
//        guideLabel.text = "Sign in to Continue".localized
//        guideLabel.textColor = .systemGray
//
//        return guideLabel
//    }()
//
//    lazy var emailLabel: UILabel = {
//        let emailLabel = UILabel()//(frame: CGRect(x: 0, y: 0, width: signInView.frame.size.width, height: 40))
//        emailLabel.text = "Email"
//
//        return emailLabel
//    }()
//
//    lazy var emailTF: UITextField = {
//        let emailTF = UITextField()//(frame: CGRect(x: 0, y: 40, width: signInView.frame.size.width, height: 40))
//        emailTF.placeholder = "kittydoc@jmsmart.co.kr"
////        emailTF.delegate = self
//        emailTF.autocapitalizationType = .none
//        return emailTF
//    }()
//
//    lazy var pwLabel: UILabel = {
//        let pwLabel = UILabel()//(frame: CGRect(x: 0, y: 100, width: signInView.frame.size.width, height: 40))
//        pwLabel.text = "Password"
//
//        return pwLabel
//    }()
//
//    lazy var pwTF: UITextField = {
//        let pwTF = UITextField()//(frame: CGRect(x: 0, y: 140, width: signInView.frame.size.width, height: 40))
//        pwTF.placeholder = "password"
//        pwTF.isSecureTextEntry = true
//
//        return pwTF
//    }()
//
//    lazy var logInBtn: UIButton = {
//        let logInBtn = UIButton()//(frame: CGRect(x: self.frame.midX - 150,y: 570, width: 300, height: 50))
//
//        logInBtn.setTitle("Sign In",for: .normal)//UIControl.State.normal
//        logInBtn.setTitleColor(.white, for: .highlighted)
//        logInBtn.backgroundColor = .systemBlue
//        logInBtn.layer.cornerRadius = 8
////        logInBtn.addTarget(self, action: #selector(didTapSignIn), for: UIControl.Event.touchUpInside)
//
//        return logInBtn
//    }()
//
//    lazy var askLabel: UILabel = {
//        let askLabel = UILabel()//(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
//        askLabel.text = "Don't have an account?"
//        return askLabel
//    }()
//
//    lazy var signUpBtn: UIButton = {
//        let signUpBtn = UIButton()//(frame: CGRect(x: 90, y: 0, width: 100, height: 50))
//        signUpBtn.setTitle("Sign Up", for: .normal)
//        signUpBtn.setTitleColor(.systemIndigo, for: .normal)
//
//        return signUpBtn
//    }()
//
//    lazy var signInView: UIView = {
//        let signInView = UIView()
//
//        return signInView
//    }()
//
//    lazy var isLoading: Bool = false {
//        didSet {
//            isLoading ? startLoading() : finishLoading()
//        }
//    }
//
//    var activityIndicator = ActivityIndicatorView(style: .medium)
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
//        [welcomeLabel, guideLabel, logInBtn, askLabel, signUpBtn, signInView, activityIndicator]
//            .forEach {
//                addSubview($0)
//                $0.translatesAutoresizingMaskIntoConstraints = false
//            }
//        [emailLabel, emailTF, pwLabel, pwTF]
//            .forEach {
//                signInView.addSubview($0)
//                $0.translatesAutoresizingMaskIntoConstraints = false
//            }
//    }
//
//    private func setUpConstraints() {
//        let signInViewConstraints = [
//            signInView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            signInView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            signInView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15),
//            signInView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15),
//            signInView.heightAnchor.constraint(equalToConstant: 300)
//        ]
//
//        let emailLabelConstraints = [
//            emailLabel.bottomAnchor.constraint(equalTo: signInView.centerYAnchor, constant: -15),
//            emailLabel.leftAnchor.constraint(equalTo: signInView.leftAnchor, constant: 10),
//            emailLabel.widthAnchor.constraint(equalToConstant: 80)
//        ]
//
//        let pwLabelConstraints = [
//            pwLabel.topAnchor.constraint(equalTo: signInView.centerYAnchor, constant: 15),
//            pwLabel.leftAnchor.constraint(equalTo: emailLabel.leftAnchor),
//            pwLabel.widthAnchor.constraint(equalToConstant: 80)
//        ]
//
//        let emailTFConstraints = [
//            //emailTF.topAnchor.constraint(equalTo: signInView.topAnchor, constant: 10),
//            emailTF.leftAnchor.constraint(equalTo: emailLabel.rightAnchor, constant: 10),
//            emailTF.rightAnchor.constraint(equalTo: signInView.rightAnchor, constant: -10),
//            emailTF.centerYAnchor.constraint(equalTo: emailLabel.centerYAnchor)
//        ]
//
//        let pwTFConstraints = [
//            //pwTF.topAnchor.constraint(equalTo: emailTF.bottomAnchor, constant: 10),
//            pwTF.leftAnchor.constraint(equalTo: pwLabel.rightAnchor, constant: 10),
//            pwTF.rightAnchor.constraint(equalTo: signInView.rightAnchor, constant: -10),
//            pwTF.centerYAnchor.constraint(equalTo: pwLabel.centerYAnchor)
//        ]
//
//        let guideLabelConstraints = [
//            guideLabel.bottomAnchor.constraint(equalTo: signInView.topAnchor, constant: -10),
//            guideLabel.leftAnchor.constraint(equalTo: signInView.leftAnchor, constant: 10)
//        ]
//
//        let welcomeLabelConstraints = [
//            welcomeLabel.bottomAnchor.constraint(equalTo: guideLabel.topAnchor, constant: -10),
//            welcomeLabel.leftAnchor.constraint(equalTo: guideLabel.leftAnchor, constant: -5)
//        ]
//
//        let logInBtnConstraints = [
//            logInBtn.topAnchor.constraint(equalTo: signInView.bottomAnchor, constant: 15),
//            logInBtn.leftAnchor.constraint(equalTo: signInView.leftAnchor, constant: 25),
//            logInBtn.rightAnchor.constraint(equalTo: signInView.rightAnchor, constant: -25),
//            logInBtn.heightAnchor.constraint(equalToConstant: 50)
//        ]
//
//        let askLabelConstraints = [
//            askLabel.topAnchor.constraint(equalTo: logInBtn.bottomAnchor, constant: 15),
//            askLabel.leftAnchor.constraint(equalTo: logInBtn.leftAnchor, constant: 15)
//        ]
//
//        let signUpBtnConstraints = [
//            //signUpBtn.topAnchor.constraint(equalTo: askLabel.topAnchor),
//            signUpBtn.centerYAnchor.constraint(equalTo: askLabel.centerYAnchor),
//            signUpBtn.rightAnchor.constraint(equalTo: logInBtn.rightAnchor, constant: -15)
//        ]
//
//        let activityIndicatorConstraints = [
//            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            activityIndicator.heightAnchor.constraint(equalToConstant: 50),
//            activityIndicator.widthAnchor.constraint(equalToConstant: 50)
//        ]
//
//        [signInViewConstraints, emailLabelConstraints, pwLabelConstraints, emailTFConstraints, pwTFConstraints, guideLabelConstraints, welcomeLabelConstraints, logInBtnConstraints, askLabelConstraints, signUpBtnConstraints, activityIndicatorConstraints]
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
