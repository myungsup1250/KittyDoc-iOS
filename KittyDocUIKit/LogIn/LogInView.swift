//
//  LogInView.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/17.
//

import UIKit

final class LogInView: UIView {
    var userInfo: UserInfo! = UserInfo.shared
    var emailTF: UITextField!
    var pwTF: UITextField!

    lazy var welcomeLabel: UILabel = {
        let welcomeLabel = UILabel()
        
        welcomeLabel.frame = CGRect(x: 50, y: 150, width: self.frame.size.width, height: 80)
        welcomeLabel.text = "Welcome".localized
        welcomeLabel.font = welcomeLabel.font.withSize(40)
        
        return welcomeLabel
    }()
    
    lazy var guideLabel: UILabel = {
        let guideLabel = UILabel()
        
        guideLabel.frame = CGRect(x: 50, y: 200, width: self.frame.size.width, height: 40)
        guideLabel.text = "Sign in to Continue".localized
        guideLabel.textColor = .systemGray
        
        return guideLabel
    }()
    
    lazy var signInView: UIView = {
        let signInView = UIView(frame: CGRect(x: 60, y: 300, width: self.frame.size.width, height: 300))
        let emailLabel = UILabel(frame: CGRect(x: 0, y: 0, width: signInView.frame.size.width, height: 40))
        emailLabel.text = "Email"

        emailTF = UITextField(frame: CGRect(x: 0, y: 40, width: signInView.frame.size.width, height: 40))
        emailTF.placeholder = "kittydoc@jmsmart.co.kr"
//        emailTF.delegate = self
        emailTF.autocapitalizationType = .none

        let pswLabel = UILabel(frame: CGRect(x: 0, y: 100, width: signInView.frame.size.width, height: 40))
        pswLabel.text = "Password"

        pwTF = UITextField(frame: CGRect(x: 0, y: 140, width: signInView.frame.size.width, height: 40))
        pwTF.placeholder = "password"
        pwTF.isSecureTextEntry = true
//        pwTF.delegate = self

        signInView.addSubview(emailLabel)
        signInView.addSubview(pswLabel)
        signInView.addSubview(emailTF)
        signInView.addSubview(pwTF)
        
        return signInView
    }()

    lazy var signInBtn: UIButton = {
        let signInBtn = UIButton(frame: CGRect(x: self.frame.midX - 150,y: 570, width: 300, height: 50))
        
        signInBtn.setTitle("Sign in",for: .normal)//UIControl.State.normal
        signInBtn.setTitleColor(.white, for: .highlighted)
        signInBtn.backgroundColor = .systemBlue//UIColor.systemBlue
        signInBtn.layer.cornerRadius = 8
        signInBtn.addTarget(self, action: #selector(didTapSignIn), for: UIControl.Event.touchUpInside)

        return signInBtn
    }()

    lazy var signUpView: UIView = {
        let signUpView = UIView(frame: CGRect(x: 100, y: 640, width: self.frame.size.width, height: 50))

        let askLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        askLabel.text = "Don't have an account?"

        let signUpBtn = UIButton(frame: CGRect(x: 90, y: 0, width: 100, height: 50))
        signUpBtn.setTitle("Sign Up", for: .normal)
        signUpBtn.setTitleColor(.systemIndigo, for: .normal)
        signUpBtn.addTarget(self, action: #selector((didTapSignUp)), for: .touchUpInside)

        signUpView.addSubview(askLabel)
        signUpView.addSubview(signUpBtn)

        return signInView
    }()

    var isLoading: Bool = false {
        didSet {
            isLoading ? startLoading() : finishLoading()
        }
    }
    
//    lazy var activityIndicator = ActivityIndicatorView(style: .medium)

    init() {
        super.init(frame: .zero)
        
        addSubviews()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        [loginTextField, passwordTextField, loginButton, activityIndicator]
            .forEach {
                addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    @objc private func didTapSignUp() {
//        let signUp = self.storyboard!.instantiateViewController(identifier: "SignUp")
//        signUp.modalPresentationStyle = .fullScreen
//            //UIModalTransitionStyle.flipHorizontal
//        present(signUp, animated: true)
    }

    @objc private func didTapSignIn() {// // // // // 로그인 동작 추가 필요 // // // // //
        var logInSuccess: Bool

        if !userInfo.Email.isEmpty && !userInfo.Pw.isEmpty {
            // Attemps Log In

            let plist = UserDefaults.standard
//            let userDict: [String : Any]? = plist.dictionary(forKey: "UserInfo") // Dictionary
//            userDict[""]

            // 어떻게 텍스트필드 값을 UserInfo와 바인딩시킬 것인가?
            // emailTF.text
            // pwTF.text

            // userInfo.Email = emailTF.text
            // userInfo.Pw = pwTF.text

            // UserInfo와 텍스트필드가 바인딩 되어있을 경우
            // 로그인 실패했을 경우, UserInfo가 실패하는 정보로 바뀌어 있을텐데,
            // 잘못된 정보로 그냥 넘어가는 것에 대한 걱정?
            // UserDefaults에 저장되어있는 User 정보를 어떻게 같이 바꿔줄것인가?

            logInSuccess = true
            if logInSuccess {// Succeed

                //UserInfo 내용 업데이트 필요
//                self.performSegue(withIdentifier: "LogInSegue", sender: nil)
            } else {// Failed
                // Inform user failed to log in!
            }
        }
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
