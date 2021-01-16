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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationItem.prompt = "UITabBarController"
        
        view.addSubview(welcomeLabel())
        view.addSubview(guideLabel())
        view.addSubview(signInView())
        view.addSubview(signInBtn())
        view.addSubview(signUpView())
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
        
        let emailInput = UITextField(frame: CGRect(x: 0, y: 40, width: signInView.frame.size.width, height: 40))
        emailInput.placeholder = "kittydoc@jmsmart.co.kr"
        emailInput.delegate = self
        emailInput.autocapitalizationType = .none
                
        let pswLabel = UILabel(frame: CGRect(x: 0, y: 100, width: signInView.frame.size.width, height: 40))
        pswLabel.text = "Password"
        
        let pswInput = UITextField(frame: CGRect(x: 0, y: 140, width: signInView.frame.size.width, height: 40))
        pswInput.placeholder = "password"
        pswInput.isSecureTextEntry = true
        pswInput.delegate = self
        
        signInView.addSubview(emailLabel)
        signInView.addSubview(pswLabel)
        signInView.addSubview(emailInput)
        signInView.addSubview(pswInput)
        
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
    
    @objc private func didTapSignIn() {
        self.performSegue(withIdentifier: "LogInSegue", sender: nil)
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

