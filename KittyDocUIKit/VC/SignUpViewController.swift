//
//  SignUpViewController.swift
//  New
//
//  Created by JEN Lee on 2021/01/15.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let welcomeLabel = UILabel()
        let plz = UILabel()
        let signInView = UIView()
        let signUpView = UIView()
        let doneBtn = UIButton()
        
        
        welcomeLabel.frame = CGRect(x: 50, y: 100, width: view.frame.size.width, height: 80)
        welcomeLabel.text = "Create Account"
        welcomeLabel.font = welcomeLabel.font.withSize(40)
        plz.frame = CGRect(x: 50, y: 150, width: view.frame.size.width, height: 40)
        plz.text = "Sign up to get Started!"
        plz.textColor = .systemGray
        
        
        signUpView.frame = CGRect(x: 60, y: 250, width: view.frame.size.width, height: 300)
        let emailLabel = UILabel(frame: CGRect(x: 0, y: 0, width: signUpView.frame.size.width, height: 30))
                emailLabel.text = "Email"
        
        let emailInput = UITextField(frame: CGRect(x: 0, y: 30, width: signUpView.frame.size.width, height: 30))
        emailInput.placeholder = "kittydoc@jmsmart.co.kr"
        emailInput.delegate = self
        
        let pswLabel = UILabel(frame: CGRect(x: 0, y: 70, width: signUpView.frame.size.width, height: 30))
            pswLabel.text = "Password"
        
        let pswInput = UITextField(frame: CGRect(x: 0, y: 100, width: signUpView.frame.size.width, height: 30))
        pswInput.placeholder = "password"
        pswInput.isSecureTextEntry = true
        pswInput.delegate = self
        
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 140, width: signUpView.frame.size.width, height: 30))
        nameLabel.text = "Name"
        
        let nameInput = UITextField(frame: CGRect(x: 0, y: 180, width: signUpView.frame.size.width, height: 30))
        nameInput.placeholder = "Name"
        nameInput.delegate = self
        
        signUpView.addSubview(emailLabel)
        signUpView.addSubview(pswLabel)
        signUpView.addSubview(emailInput)
        signUpView.addSubview(pswInput)
        signUpView.addSubview(nameLabel)
        signUpView.addSubview(nameInput)
        
        
        
        doneBtn.frame = CGRect(x: view.frame.midX - 150, y: 570, width: 300, height: 50)
        doneBtn.setTitle("Register", for: .normal)
        doneBtn.setTitleColor(.white, for: .highlighted)
        doneBtn.backgroundColor = .systemBlue
        doneBtn.layer.cornerRadius = 8
        doneBtn.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        
        
        signInView.frame = CGRect(x: 50, y: 640, width: view.frame.size.width, height: 50)
        let askLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        askLabel.text = "Already have an Account?"
        
        let signInBtn = UIButton()
        signInBtn.frame = CGRect(x: 190, y: 0, width: 100, height: 50)
        signInBtn.setTitle("Sign In", for: .normal)
        signInBtn.setTitleColor(.systemIndigo, for: .normal)
        signInBtn.addTarget(self, action: #selector((didTapSignIn)), for: .touchUpInside)
        
        signInView.addSubview(askLabel)
        signInView.addSubview(signInBtn)
        
        
        
        view.addSubview(welcomeLabel)
        view.addSubview(plz)
        view.addSubview(signUpView)
        view.addSubview(doneBtn)
        view.addSubview(signInView)
    }
    

    @objc private func didTapSignIn() {
        //이미 아이디 있는 경우
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    @objc private func didTapRegister() {
        //회원가입 된 경우
        //: UserInfo 인스턴스를 생성해서 값 저장해주고?
        //  메인화면 메일이랑 패스워드 채워넣는다.
    //let userInfo = UserInfo(email: nil, pwd: nil, name: nil, phone: nil, birth: nil)
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
