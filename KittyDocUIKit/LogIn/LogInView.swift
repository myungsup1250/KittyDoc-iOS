//
//  LogInView.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/17.
//

import UIKit

class VC: UIViewController {
    let mainStoryboardName = "Main"
    let signUpStoryboardID = "SignUp"
}

final class LogInView: UIView {
    var userInfo: UserInfo! = UserInfo.shared
    var emailTF: UITextField!
    var pwTF: UITextField!
    var signUpBtn: UIButton!

    lazy var welcomeLabel: UILabel = {
        let welcomeLabel = UILabel()
        
//        welcomeLabel.frame = CGRect(x: 50, y: 150, width: self.frame.size.width, height: 80)
        welcomeLabel.text = "Welcome".localized
        welcomeLabel.font = welcomeLabel.font.withSize(40)
        
        return welcomeLabel
    }()
    
    lazy var guideLabel: UILabel = {
        let guideLabel = UILabel()
        
//        guideLabel.frame = CGRect(x: 50, y: 200, width: self.frame.size.width, height: 40)
        guideLabel.text = "Sign in to Continue".localized
        guideLabel.textColor = .systemGray
        
        return guideLabel
    }()
    
    lazy var signInView: UIView = {
        let signInView = UIView()//(frame: CGRect(x: 60, y: 300, width: self.frame.size.width, height: 300))
//        signInView.frame = CGRect(x: 60, y: 300, width: self.frame.size.width, height: 300)
        let emailLabel = UILabel()//(frame: CGRect(x: 0, y: 0, width: signInView.frame.size.width, height: 40))
//        emailLabel.frame = CGRect(x: 0, y: 0, width: signInView.frame.size.width, height: 40)
        emailLabel.text = "Email"

        emailTF = UITextField()//(frame: CGRect(x: 0, y: 40, width: signInView.frame.size.width, height: 40))
//        emailTF.frame = CGRect(x: 0, y: 40, width: signInView.frame.size.width, height: 40)
        emailTF.placeholder = "kittydoc@jmsmart.co.kr"
//        emailTF.delegate = self
        emailTF.autocapitalizationType = .none

        let pswLabel = UILabel()//(frame: CGRect(x: 0, y: 100, width: signInView.frame.size.width, height: 40))
//        pswLabel.frame = CGRect(x: 0, y: 100, width: signInView.frame.size.width, height: 40)
        pswLabel.text = "Password"

        pwTF = UITextField()//(frame: CGRect(x: 0, y: 140, width: signInView.frame.size.width, height: 40))
//        pwTF.frame = CGRect(x: 0, y: 140, width: signInView.frame.size.width, height: 40)
        pwTF.placeholder = "password"
        pwTF.isSecureTextEntry = true
//        pwTF.delegate = self

        signInView.addSubview(emailLabel)
        signInView.addSubview(pswLabel)
        signInView.addSubview(emailTF)
        signInView.addSubview(pwTF)
        
        return signInView
    }()

    lazy var logInBtn: UIButton = {
        let logInBtn = UIButton()//(frame: CGRect(x: self.frame.midX - 150,y: 570, width: 300, height: 50))
        
//        logInBtn.frame = CGRect(x: self.frame.midX - 150,y: 570, width: 300, height: 50)
        logInBtn.setTitle("Sign in",for: .normal)//UIControl.State.normal
        logInBtn.setTitleColor(.white, for: .highlighted)
        logInBtn.backgroundColor = .systemBlue//UIColor.systemBlue
        logInBtn.layer.cornerRadius = 8
//        logInBtn.addTarget(self, action: #selector(didTapSignIn), for: UIControl.Event.touchUpInside)

        return logInBtn
    }()

    lazy var signUpView: UIView = {
        let signUpView = UIView()//(frame: CGRect(x: 100, y: 640, width: self.frame.size.width, height: 50))
//        signUpView.frame = CGRect(x: 100, y: 640, width: self.frame.size.width, height: 50)

        let askLabel = UILabel()//(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
//        askLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        askLabel.text = "Don't have an account?"

        signUpBtn = UIButton()//(frame: CGRect(x: 90, y: 0, width: 100, height: 50))
//        signUpBtn.frame = CGRect(x: 90, y: 0, width: 100, height: 50)
        signUpBtn.setTitle("Sign Up", for: .normal)
        signUpBtn.setTitleColor(.systemIndigo, for: .normal)
//        signUpBtn.addTarget(self, action: #selector((didTapSignUp)), for: .touchUpInside)

        signUpView.addSubview(askLabel)
        signUpView.addSubview(signUpBtn)

        return signInView
    }()

    var isLoading: Bool = false {
        didSet {
            isLoading ? startLoading() : finishLoading()
        }
    }
    
    lazy var activityIndicator = ActivityIndicatorView(style: .medium)

    init() {
        super.init(frame: .zero)
        
        addSubviews()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        [welcomeLabel, guideLabel, signInView, logInBtn, signUpView]
            .forEach {
                addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func setUpConstraints() {
        let loginConstraints = [
            emailTF.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            emailTF.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30.0),
            emailTF.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50.0),
            emailTF.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50.0),
            emailTF.heightAnchor.constraint(equalToConstant: 30.0)
        ]
        
        let passwordConstraints = [
            pwTF.topAnchor.constraint(equalTo: emailTF.bottomAnchor, constant: 10.0),
            pwTF.centerXAnchor.constraint(equalTo: emailTF.centerXAnchor),
            pwTF.widthAnchor.constraint(equalTo: emailTF.widthAnchor, multiplier: 1.0),
            pwTF.heightAnchor.constraint(equalTo: emailTF.heightAnchor)
        ]
        
        let loginButtonConstraints = [
            logInBtn.topAnchor.constraint(equalTo: pwTF.bottomAnchor, constant: 20.0),
            logInBtn.centerXAnchor.constraint(equalTo: pwTF.centerXAnchor),
            logInBtn.widthAnchor.constraint(equalToConstant: 120.0),
            logInBtn.heightAnchor.constraint(equalToConstant: 30.0)
        ]
        
        let activityIndicatorConstraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 50),
            activityIndicator.widthAnchor.constraint(equalToConstant: 50.0)
        ]
        
        [loginConstraints,
         passwordConstraints,
         loginButtonConstraints,
         activityIndicatorConstraints]
            .forEach(NSLayoutConstraint.activate(_:))
    }

    func startLoading() {
        isUserInteractionEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func finishLoading() {
        isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
    }



    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
//class LogInViewController: UIViewController, UITextFieldDelegate {

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//
//        self.navigationItem.prompt = "UITabBarController"
//
//        view.addSubview(welcomeLabel())
//        view.addSubview(guideLabel())
//        view.addSubview(signInView())
//        view.addSubview(signInBtn())
//        view.addSubview(signUpView())
//
//        userInfo.Email = "myungsup1250@gmail.com"
//        userInfo.Pw = "ms5892"
//
//        // userInfo.wantsRememberEmail = true
//        // userInfo.wantsAutoLogin = true
//
//        if userInfo.loggedInPrev {
//            if userInfo.wantsAutoLogin && !userInfo.Email.isEmpty && !userInfo.Pw.isEmpty { // Automatically Log In
//                emailTF.text = userInfo.Email
//                pwTF.text = userInfo.Pw
//                didTapSignIn()
//            } else if userInfo.wantsRememberEmail && !userInfo.Email.isEmpty { // Just Remember User's Email
//                emailTF.text = userInfo.Email
//            }
//        }
//    }
//

//}
