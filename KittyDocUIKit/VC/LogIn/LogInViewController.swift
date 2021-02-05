//
//  LogInViewController.swift [Main]
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/15.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    var userInfo: UserInfo = UserInfo.shared
    var emailTF: UITextField!
    var pwTF: UITextField!
    var email: String?
    var pw: String?

    
    override func viewWillLayoutSubviews() {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
    
        
        // Do any additional setup after loading the view.

        let _: UITextField = {
            emailTF = UITextField(frame: CGRect(x: 0, y: 40, width: 320, height: 40))
            emailTF.placeholder = "kittydoc@jmsmart.co.kr"
            emailTF.delegate = self
            emailTF.autocapitalizationType = .none
            emailTF.borderStyle = .roundedRect
            emailTF.clearButtonMode = .whileEditing
            emailTF.keyboardType = .emailAddress
            emailTF.enablesReturnKeyAutomatically = true
            return emailTF
        }()
        
        
        let _: UITextField = {
            pwTF = UITextField(frame: CGRect(x: 0, y: 140, width: 320, height: 40))
            pwTF.placeholder = "password"
            pwTF.isSecureTextEntry = true
            pwTF.delegate = self
            pwTF.borderStyle = .roundedRect
            pwTF.clearButtonMode = .whileEditing
            pwTF.enablesReturnKeyAutomatically = true
            return pwTF
        }()
        
        
        self.navigationItem.prompt = "UITabBarController"

        view.addSubview(welcomeLabel)
        view.addSubview(guideLabel)
        view.addSubview(signInView)
        view.addSubview(signInBtn)
        view.addSubview(askLabel)
        view.addSubview(signUpBtn)

        
        signInView.addSubview(emailLabel)
        signInView.addSubview(pswLabel)
        signInView.addSubview(emailTF)
        signInView.addSubview(pwTF)

        
        //userInfo.Email = "myungsup1250@gmail.com"
        //userInfo.Pw = "ms5892"

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
    
    override func viewWillAppear(_ animated: Bool) {
        
        email = UserDefaults.standard.string(forKey: "email_test")
        pw = UserDefaults.standard.string(forKey: "pwd_test")
        
        if let email_test = email {
            emailTF.text = email_test
        }
        
        if let pw_test = pw {
            pwTF.text = pw_test
        }
        
        if emailTF.text != "" && pwTF.text != "" {
            self.performSegue(withIdentifier: "LogInSegue", sender: nil)
            didTapSignIn()
        }
        
        textFieldSetUp()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }

    let welcomeLabel: UILabel = {
        let welcomeLabel = UILabel()

        welcomeLabel.frame = CGRect(x: 50, y: 150, width: 400, height: 80)
        welcomeLabel.text = "Welcome".localized
        welcomeLabel.font = welcomeLabel.font.withSize(40)

        return welcomeLabel
    }()

    let guideLabel : UILabel = {
        let guideLabel = UILabel()

        guideLabel.frame = CGRect(x: 50, y: 200, width: 400, height: 40)
        guideLabel.text = "Sign in to Continue".localized
        guideLabel.textColor = .systemGray

        return guideLabel
    }()
    
    
    let signInView : UIView = {
        let signInView = UIView()
        signInView.frame = CGRect(x: 30, y: 300, width: 500, height: 300)
        
        return signInView
    }()
    
    
    let emailLabel : UILabel = {
        let emailLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 500, height: 40))
        emailLabel.text = "Email"
        
        return emailLabel
    }()
    
    
    let pswLabel : UILabel = {
        let pswLabel = UILabel(frame: CGRect(x: 10, y: 100, width: 500, height: 40))
        pswLabel.text = "Password"
        
        return pswLabel
    }()
    

    
    let signInBtn : UIButton = {
        let signInBtn = UIButton()

        signInBtn.frame = CGRect(x: 40, y: 570, width: 300, height: 50)
        signInBtn.setTitle("Sign in", for: .normal)
        signInBtn.setTitleColor(.white, for: .highlighted)
        signInBtn.backgroundColor = .systemBlue
        signInBtn.layer.cornerRadius = 8
        signInBtn.addTarget(self, action: #selector((didTapSignIn)), for: .touchUpInside)
        
        return signInBtn
    }()
    

    let askLabel : UILabel = {
        let askLabel = UILabel()
        askLabel.frame = CGRect(x: 100, y: 640, width: 100, height: 50)
        askLabel.text = "New User?"//"Don't have an account?"
        
        return askLabel
    }()
    

    let signUpBtn : UIButton = {
        let signUpBtn = UIButton()
        signUpBtn.frame = CGRect(x: 190, y: 640, width: 100, height: 50)
        signUpBtn.setTitle("Sign Up", for: .normal)
        signUpBtn.setTitleColor(.systemIndigo, for: .normal)
        signUpBtn.addTarget(self, action: #selector((didTapSignUp)), for: .touchUpInside)
        
        return signUpBtn
    }()
        
    
    @objc private func didTapSignUp() {
        let signUp = self.storyboard!.instantiateViewController(identifier: "SignUp")
        signUp.modalPresentationStyle = .fullScreen
            //UIModalTransitionStyle.flipHorizontal
        present(signUp, animated: true)
    }
    

    @objc private func didTapSignIn() {
        if emailTF.text!.isEmpty {
            alertWithMessage(message: "아이디를 입력해주세요!")
        } else if pwTF.text!.isEmpty {
            alertWithMessage(message: "비밀번호를 입력해주세요!")
        }
        else {
            if(!isEmailForm(_email:emailTF.text!)){
                alertWithMessage(message: "올바른 이메일 형식이 아닙니다!")
                return
            }
            if(!isPwdForm(_pwd:pwTF.text!)){
                alertWithMessage(message: "비밀번호를 입력해주세요!")
                return
            }
            // Attemps Log In
//            let plist = UserDefaults.standard
            //let userDict: [String : Any]? = plist.dictionary(forKey: "UserInfo")
            
            let loginData:LoginData = LoginData(_userEmail: emailTF.text!, _userPwd: pwTF.text!)
            let server:KittyDocServer = KittyDocServer()
            let loginResponse:ServerResponse = server.userLogin(data: loginData)
            
            //가능하다면 실패 시에 잘못 입력한 뷰로 focus를 주는 기능이 들어가는게 좋을듯. --- O
            //회원가입 화면에 보면, UserInfo를 회원가입 성공시 초기화 한다는 주석이 있는데 아닌것 같음.
            //회원가입만 하면 로그인도 안했는데 로그인 한것처럼 어플이 이미 모든 로그인 데이터를 가지고 있게 되니까! OOOK!
            //intent느낌으로 메인 화면 방금 가입한 이메일이랑 비밀번호 채워주는건 좋은듯 ---- LATER
            
            
            if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_SUCCESS){
                self.performSegue(withIdentifier: "LogInSegue", sender: nil)
                //MARK: TEMP ORIGIN HERE
                UserDefaults.standard.set(emailTF.text, forKey: "email_test")
                UserDefaults.standard.set(pwTF.text, forKey: "pwd_test")
                

                let jsonString:String = loginResponse.getMessage() as! String
                if let data = jsonString.data(using: .utf8){
                    do{
                        if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]{
                            userInfo.Email = json["UserEmail"]! as! String
                            userInfo.Pw = json["UserPwd"]! as! String
                            userInfo.gender = json["UserSex"] as! String
                            userInfo.Name = json["UserName"] as! String
                            userInfo.UserID = json["UserID"] as! Int
                            userInfo.UserPhone = json["UserPhone"] as! String
                            userInfo.UserBirth = json["UserBirth"] as! String
                            print(userInfo)
                        }
                    } catch{
                        print("JSON 파싱 에러")
                    }
                }

                
            }else if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_WRONG_EMAIL){
                alertWithMessage(message: loginResponse.getMessage())
                self.emailTF.becomeFirstResponder()
            }else if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_WRONG_PWD){
                print(loginResponse.getMessage())
                self.pwTF.becomeFirstResponder()
                alertWithMessage(message: loginResponse.getMessage())
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
    
    
    func textFieldSetUp() {
        emailTF.text = ""
        pwTF.text = ""
    }
    
    
    func alertWithMessage(message input: Any) {
        let alert = UIAlertController(title: "", message: input as? String, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        self.present(alert, animated: false)
    }
    
    //이메일 형식인지에 대한 정규표현식. 인터넷에 검색하면 쉽게 나오니 바꾸고 싶은게 있으면 바꾸셈
    func isEmailForm(_email:String) -> Bool{
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,50}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailReg)
        return emailTest.evaluate(with: _email)
    }
    
    //비밀번호 형식에 대한 검사함수. 지금은 길이가 1이상만 되면 되는 것으로 했지만 추후에 특수문자포함여부, 길이제한 추가
    //하게 될지도?
    func isPwdForm(_pwd:String) -> Bool{
        if(_pwd.count > 0){
            return true
        }else{
            return false
        }
    }

    
}

