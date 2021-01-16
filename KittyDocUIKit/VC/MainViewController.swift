//
//  MainViewController.swift [LogInViewController]
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/15.
//

import UIKit

extension String {
//    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
//        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
//    }
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
}

class MainViewController: UIViewController, UITextFieldDelegate {
    var userInfo: UserInfo! = UserInfo.shared
    var emailTF: UITextField!
    var pwTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.navigationItem.prompt = "UITabBarController"
        
        view.addSubview(welcomeLabel())
        view.addSubview(guideLabel())
        view.addSubview(signInView())
        view.addSubview(signInBtn())
        view.addSubview(signUpView())
                
        userInfo.Email = "myungsup1250@gmail.com"
        userInfo.Pw = "ms5892"
        
        // userInfo.wantsRememberEmail = true
        // userInfo.wantsAutoLogin = true

        if userInfo.loggedInPrev {
            if userInfo.wantsAutoLogin && !userInfo.Email.isEmpty && !userInfo.Pw.isEmpty { // Automatically Log In
                emailTF.text = userInfo.Email
                pwTF.text = userInfo.Pw
                didTapSignIn()
            } else if userInfo.wantsRememberEmail && !userInfo.Email.isEmpty { // Just Remember User's Email
                emailTF.text = userInfo.Email
            }
        }
    }
    
    func welcomeLabel() -> UILabel {
        let welcomeLabel = UILabel()

        welcomeLabel.frame = CGRect(x: 50, y: 150, width: view.frame.size.width, height: 80)
        welcomeLabel.text = "Welcome".localized
        welcomeLabel.font = welcomeLabel.font.withSize(40)
        
        return welcomeLabel
    }
    
    func guideLabel() -> UILabel {
        let guideLabel = UILabel()

        guideLabel.frame = CGRect(x: 50, y: 200, width: view.frame.size.width, height: 40)
        guideLabel.text = "Sign in to Continue".localized
        guideLabel.textColor = .systemGray

        return guideLabel
    }
    
    func signInView() -> UIView {
        let signInView = UIView()

        signInView.frame = CGRect(x: 60, y: 300, width: view.frame.size.width, height: 300)
        let emailLabel = UILabel(frame: CGRect(x: 0, y: 0, width: signInView.frame.size.width, height: 40))
        emailLabel.text = "Email"
        
        emailTF = UITextField(frame: CGRect(x: 0, y: 40, width: signInView.frame.size.width, height: 40))
        emailTF.placeholder = "kittydoc@jmsmart.co.kr"
        emailTF.delegate = self
        emailTF.autocapitalizationType = .none
        
        let pswLabel = UILabel(frame: CGRect(x: 0, y: 100, width: signInView.frame.size.width, height: 40))
        pswLabel.text = "Password"
        
        pwTF = UITextField(frame: CGRect(x: 0, y: 140, width: signInView.frame.size.width, height: 40))
        pwTF.placeholder = "password"
        pwTF.isSecureTextEntry = true
        pwTF.delegate = self
        
        signInView.addSubview(emailLabel)
        signInView.addSubview(pswLabel)
        signInView.addSubview(emailTF)
        signInView.addSubview(pwTF)
        
        return signInView
    }

    func signInBtn() -> UIButton {
        let signInBtn = UIButton()

        signInBtn.frame = CGRect(x: view.frame.midX - 150, y: 570, width: 300, height: 50)
        signInBtn.setTitle("Sign in", for: .normal)
        signInBtn.setTitleColor(.white, for: .highlighted)
        signInBtn.backgroundColor = .systemBlue
        signInBtn.layer.cornerRadius = 8
        signInBtn.addTarget(self, action: #selector((didTapSignIn)), for: .touchUpInside)

        return signInBtn
    }

    func signUpView() -> UIView {
        let signUpView = UIView()

        signUpView.frame = CGRect(x: 100, y: 640, width: view.frame.size.width, height: 50)
        let askLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        askLabel.text = "New User?"//"Don't have an account?"
        
        let signUpBtn = UIButton()
        signUpBtn.frame = CGRect(x: 90, y: 0, width: 100, height: 50)
        signUpBtn.setTitle("Sign Up", for: .normal)
        signUpBtn.setTitleColor(.systemIndigo, for: .normal)
        signUpBtn.addTarget(self, action: #selector((didTapSignUp)), for: .touchUpInside)
        
        
        signUpView.addSubview(askLabel)
        signUpView.addSubview(signUpBtn)

        return signUpView
    }

    @objc private func didTapSignUp() {
        let signUp = self.storyboard!.instantiateViewController(identifier: "SignUp")
        signUp.modalPresentationStyle = .fullScreen
            //UIModalTransitionStyle.flipHorizontal
        present(signUp, animated: true)
    }
    
    @objc private func didTapSignIn() {// // // // // 로그인 동작 추가 필요 // // // // //
        var logInSuccess: Bool
        
        if !userInfo.Email.isEmpty && !userInfo.Pw.isEmpty {
            // Attemps Log In
            
            let plist = UserDefaults.standard
            let userDict: [String : Any]? = plist.dictionary(forKey: "UserInfo") // Dictionary
            // ms branch TEST

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
                self.performSegue(withIdentifier: "LogInSegue", sender: nil)
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

