//
//  LogInViewController.swift [Main]
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/15.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
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

        signInView.frame = CGRect(x: 30, y: 300, width: view.frame.size.width, height: 300)
        let emailLabel = UILabel(frame: CGRect(x: 10, y: 0, width: signInView.frame.size.width, height: 40))
        emailLabel.text = "Email"

        emailTF = UITextField(frame: CGRect(x: 0, y: 40, width: 320, height: 40))
        emailTF.placeholder = "kittydoc@jmsmart.co.kr"
        emailTF.delegate = self
        emailTF.autocapitalizationType = .none
        emailTF.borderStyle = .roundedRect
        emailTF.clearButtonMode = .whileEditing
        emailTF.keyboardType = .emailAddress
        emailTF.enablesReturnKeyAutomatically = true
        
        let pswLabel = UILabel(frame: CGRect(x: 10, y: 100, width: signInView.frame.size.width, height: 40))
        pswLabel.text = "Password"
        
        pwTF = UITextField(frame: CGRect(x: 0, y: 140, width: 320, height: 40))
        pwTF.placeholder = "password"
        pwTF.isSecureTextEntry = true
        pwTF.delegate = self
        pwTF.borderStyle = .roundedRect
        pwTF.clearButtonMode = .whileEditing
        pwTF.enablesReturnKeyAutomatically = true
        
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
        if !userInfo.Email.isEmpty && !userInfo.Pw.isEmpty {
            // Attemps Log In
            //let plist = UserDefaults.standard
            //let userDict: [String : Any]? = plist.dictionary(forKey: "UserInfo")

            let loginData:LoginData = LoginData(_userEmail: emailTF.text!, _userPwd: pwTF.text!)
            let server:KittyDocServer = KittyDocServer()
            var loginResponse:ServerResponse = server.userLogin(data: loginData)
            
            print("loginResponse")
            print(loginResponse.getCode())
            
            if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_SUCCESS){
                self.performSegue(withIdentifier: "LogInSegue", sender: nil)
            }else if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_WRONG_EMAIL){
                print(loginResponse.getMessage())
            }else if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_WRONG_PWD){
                print(loginResponse.getMessage())
            }else{
                print(loginResponse.getMessage())
            }
        }
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func logout(_ sender: UIStoryboardSegue) {
        
    }

}

