//
//  LogInViewController.swift [Main]
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/15.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    var userInfo: UserInfo = UserInfo.shared

    var welcomeLabel: UILabel!
    var guideLabel: UILabel!
    var signInView: UIView!
    var emailLabel: UILabel!
    var pwdLabel: UILabel!
    var signInBtn: UIButton!
    var askLabel: UILabel!
    var signUpBtn: UIButton!

    var emailTF: UITextField!
    var pwdTF: UITextField!
    var showPwdUIView: UIView!
    var showPwdLabel: UILabel!
    var showPwdSwitch: UISwitch!

    var email: String?
    var pw: String?

//    override func viewWillLayoutSubviews() {
//        print("LogInViewController.viewWillLayoutSubviews()")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LogInViewController.viewDidLoad()")
        self.navigationItem.prompt = "UITabBarController"

        initUIViews()
        addSubviews()
        prepareForAutoLayout()
        setConstraints()

//        let dayInSec: TimeInterval = 86400 // (86400 == 24Hours in seconds)
//        let hourInSec: TimeInterval = 3600
//
//        // 일주일 (604800 == A week in seconds)
//        //let frontTime = Int(Date().timeIntervalSince1970 * 1000)// - 604800000)    // frontTime in milliseconds
//        //let rearTime = Int((Date().timeIntervalSince1970 - (dayInSec * 7)) * 1000)// * 2) // rearTime in milliseconds
//
//        // 하루 (86400 == 24Hours in seconds)
//        //let frontTime = Int(Date().timeIntervalSince1970 * 1000)                                    // frontTime in milliseconds
//        //let rearTime = Int((Date().timeIntervalSince1970 - (dayInSec * Double(forDays))) * 1000)    // rearTime in milliseconds
//
//        // 00시부터 지금까지?
//        let timeIntervalSince1970 = Date().timeIntervalSince1970
//        let timeIntervalFromMidnight = TimeInterval(Int(timeIntervalSince1970 + hourInSec * 9) % Int(dayInSec))
//        let frontTime = Int(timeIntervalSince1970 * 1000)                                    // frontTime in milliseconds
//        let rearTime = Int((timeIntervalSince1970 - timeIntervalFromMidnight) * 1000)   // rearTime in milliseconds
//        print("requestServerData(From : \(unixtimeToString(unixtime: time_t(rearTime / 1000))), Til : \(unixtimeToString(unixtime: time_t(frontTime / 1000))))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        email = UserDefaults.standard.string(forKey: "email_test")
        pw = UserDefaults.standard.string(forKey: "pwd_test")
        
        if let email_test = email {
            emailTF.text = email_test
        }
        
        if let pw_test = pw {
            pwdTF.text = pw_test
        }
        
        if email != nil && pw != nil {
            self.performSegue(withIdentifier: "LogInSegue", sender: nil)
            didTapSignIn()
        }
        
        textFieldSetUp()
        emailTF.becomeFirstResponder()
    }
    
    @objc func onClickSwitch(sender: UISwitch) {
        print("onClickSwitch(UISwitch : \(showPwdSwitch.isOn)")
//        var text: String!
//        var color: UIColor!
//
//        if sender.isOn {
//            text = "On"
//            color = UIColor.gray
//        } else {
//            text = "Off"
//            color = UIColor.green
//        }
//
//        self.label.text = text
//        self.label.backgroundColor = color
    }

    
    @objc private func didTapSignUp() {
        let signUp = self.storyboard!.instantiateViewController(identifier: "SignUp")
        signUp.modalPresentationStyle = .fullScreen
            //UIModalTransitionStyle.flipHorizontal
        present(signUp, animated: true)
    }
    
    @objc private func didTapSignIn() {

        if emailTF.text!.isEmpty {
            alertWithMessage(message: "아이디를 입력해주세요!")
        } else if pwdTF.text!.isEmpty {
            alertWithMessage(message: "비밀번호를 입력해주세요!")
        } else {
            if(!isEmailForm(_email:emailTF.text!)){
                alertWithMessage(message: "올바른 이메일 형식이 아닙니다!")
                return
            }
            if(!isPwdForm(_pwd:pwdTF.text!)){
                alertWithMessage(message: "비밀번호를 입력해주세요!")
                return
            }
            // Attemps Log In
//            let plist = UserDefaults.standard
            //let userDict: [String : Any]? = plist.dictionary(forKey: "UserInfo")
            
            let loginData:LoginData = LoginData(_userEmail: emailTF.text!, _userPwd: pwdTF.text!)
            let server:KittyDocServer = KittyDocServer()
            let loginResponse:ServerResponse = server.userLogin(data: loginData)
            
            //가능하다면 실패 시에 잘못 입력한 뷰로 focus를 주는 기능이 들어가는게 좋을듯. --- O
            //회원가입 화면에 보면, UserInfo를 회원가입 성공시 초기화 한다는 주석이 있는데 아닌것 같음.
            //회원가입만 하면 로그인도 안했는데 로그인 한것처럼 어플이 이미 모든 로그인 데이터를 가지고 있게 되니까! OOOK!
            //intent느낌으로 메인 화면 방금 가입한 이메일이랑 비밀번호 채워주는건 좋은듯 ---- LATER
            
            //서버가 꺼져있어서 서버 연결이 안되는 상황에 로그 외에 UIAlertController 활용해서 서버 연결 실패했다고 알려주고 다시 시도하도록 했으면 좋겠음.
            //지금은 서버 연결이 안되면 앱이 아무런 말도 없이 멈춰버린다. 로그를 보지 못하면 알 수가 없다!
            //21.03.12 명섭 제안            
            
            if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_SUCCESS){
                self.performSegue(withIdentifier: "LogInSegue", sender: nil)
                //MARK: TEMP ORIGIN HERE
                UserDefaults.standard.set(emailTF.text, forKey: "email_test")
                UserDefaults.standard.set(pwdTF.text, forKey: "pwd_test")

                let jsonString: String = loginResponse.getMessage() as! String
                if let data = jsonString.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject] {
                            userInfo.Email = json["UserEmail"]! as! String
                            userInfo.Pw = json["UserPwd"]! as! String
                            userInfo.gender = json["UserSex"] as! String
                            userInfo.Name = json["UserName"] as! String
                            userInfo.UserID = json["UserID"] as! Int
                            userInfo.UserPhone = json["UserPhone"] as! String
                            userInfo.UserBirth = json["UserBirth"] as! String
                            print(userInfo)
                        }
                    } catch {
                        print("JSON 파싱 에러")
                    }
                }
            } else if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_WRONG_EMAIL) {
                alertWithMessage(message: loginResponse.getMessage())
                self.emailTF.becomeFirstResponder()
            } else if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_WRONG_PWD) {
                print(loginResponse.getMessage())
                self.pwdTF.becomeFirstResponder()
                alertWithMessage(message: loginResponse.getMessage())
            } else {
                print(loginResponse.getMessage())
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)// 화면 터치 시 키보드 내려가는 코드 -ms
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func logout(_ sender: UIStoryboardSegue) {
        
    }
    
    func textFieldSetUp() {
        emailTF.text = ""
        pwdTF.text = ""
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
    
    //비밀번호 형식에 대한 검사함수. 지금은 길이가 1이상만 되면 되는 것으로 했지만 추후에 특수문자포함여부, 길이제한 추가하게 될지도?
    func isPwdForm(_pwd:String) -> Bool{
        if _pwd.count > 0 {
            return true
        } else {
            return false
        }
    }
}

extension LogInViewController { // AutoLayout
    fileprivate func initUIViews() {
        initEmailTF()
        initPwdTF()
        initLabels()
        initButtons()
        initSwitch()
        initUIView()
    }
    
    fileprivate func addSubviews() {
        view.addSubview(welcomeLabel)
        view.addSubview(guideLabel)
        view.addSubview(signInView)
        view.addSubview(signInBtn)
        view.addSubview(askLabel)
        view.addSubview(signUpBtn)
        
        signInView.addSubview(emailLabel)
        signInView.addSubview(pwdLabel)
        signInView.addSubview(emailTF)
        signInView.addSubview(pwdTF)
        signInView.addSubview(showPwdUIView)
        
        showPwdUIView.addSubview(showPwdLabel)
        showPwdUIView.addSubview(showPwdSwitch)
    }

    func initEmailTF() {
        emailTF = UITextField()
        emailTF.delegate = self
        emailTF.placeholder = "kittydoc@jmsmart.co.kr"
        emailTF.autocapitalizationType = .none
        emailTF.borderStyle = .roundedRect
        emailTF.clearButtonMode = .whileEditing
        emailTF.keyboardType = .emailAddress
        emailTF.enablesReturnKeyAutomatically = true
    }
    
    func initPwdTF() {
        pwdTF = UITextField()
        pwdTF.delegate = self
        pwdTF.placeholder = "password"
        pwdTF.isSecureTextEntry = true
        pwdTF.borderStyle = .roundedRect
        pwdTF.clearButtonMode = .whileEditing
        pwdTF.enablesReturnKeyAutomatically = true
    }
    
    func initLabels() {
        welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome".localized
        welcomeLabel.font = welcomeLabel.font.withSize(40)
        
        guideLabel = UILabel()
        guideLabel.text = "Sign in to Continue".localized
        guideLabel.textColor = .systemGray

        emailLabel = UILabel()
        emailLabel.text = "Email"

        pwdLabel = UILabel()
        pwdLabel.text = "Password"

        showPwdLabel = UILabel()
        showPwdLabel.text = "Hide/Show Password"
            
        askLabel = UILabel()
        askLabel.text = "Don't have an account?"

    }
    
    func initUIView() {
        signInView = UIView()
        showPwdUIView = UIView()
    }
    
    func initButtons() {
        signInBtn = UIButton()
        signInBtn.setTitle("Sign in", for: .normal)
        signInBtn.setTitleColor(.white, for: .highlighted)
        signInBtn.backgroundColor = .systemBlue
        signInBtn.layer.cornerRadius = 8
        signInBtn.addTarget(self, action: #selector((didTapSignIn)), for: .touchUpInside)
        
        signUpBtn = UIButton()
        signUpBtn.setTitle("Sign Up", for: .normal)
        signUpBtn.setTitleColor(.systemIndigo, for: .normal)
        //signUpBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        signUpBtn.addTarget(self, action: #selector((didTapSignUp)), for: .touchUpInside)
    }
    
    func initSwitch() {
        showPwdSwitch = UISwitch()
        
        showPwdSwitch.isOn = true
        showPwdSwitch.addTarget(self, action: #selector(onClickSwitch(sender:)), for: UIControl.Event.valueChanged)
        
        //showPwdSwitch.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height - 200)
    }
    
    func prepareForAutoLayout() {
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        signInView.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        pwdLabel.translatesAutoresizingMaskIntoConstraints = false
        signInBtn.translatesAutoresizingMaskIntoConstraints = false
        askLabel.translatesAutoresizingMaskIntoConstraints = false
        signUpBtn.translatesAutoresizingMaskIntoConstraints = false
        emailTF.translatesAutoresizingMaskIntoConstraints = false
        pwdTF.translatesAutoresizingMaskIntoConstraints = false
        showPwdUIView.translatesAutoresizingMaskIntoConstraints = false
        showPwdLabel.translatesAutoresizingMaskIntoConstraints = false
        showPwdSwitch.translatesAutoresizingMaskIntoConstraints = false
    }

    func setConstraints() {
        let signInViewConstraints = [
            signInView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signInView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            signInView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
            signInView.heightAnchor.constraint(equalToConstant: 300)
        ]

        let emailLabelConstraints = [
            emailLabel.bottomAnchor.constraint(equalTo: signInView.centerYAnchor, constant: -15),
            emailLabel.leftAnchor.constraint(equalTo: signInView.leftAnchor, constant: 10),
            emailLabel.widthAnchor.constraint(equalToConstant: 80)
        ]

        let pwdLabelConstraints = [
            pwdLabel.topAnchor.constraint(equalTo: signInView.centerYAnchor, constant: 15),
            pwdLabel.leftAnchor.constraint(equalTo: emailLabel.leftAnchor),
            pwdLabel.widthAnchor.constraint(equalToConstant: 80)
        ]

        let emailTFConstraints = [
            //emailTF.topAnchor.constraint(equalTo: signInView.topAnchor, constant: 10),
            emailTF.leftAnchor.constraint(equalTo: emailLabel.rightAnchor, constant: 10),
            emailTF.rightAnchor.constraint(equalTo: signInView.rightAnchor, constant: -10),
            emailTF.centerYAnchor.constraint(equalTo: emailLabel.centerYAnchor)
        ]

        let pwdTFConstraints = [
            //pwdTF.topAnchor.constraint(equalTo: emailTF.bottomAnchor, constant: 10),
            pwdTF.leftAnchor.constraint(equalTo: pwdLabel.rightAnchor, constant: 10),
            pwdTF.rightAnchor.constraint(equalTo: signInView.rightAnchor, constant: -10),
            pwdTF.centerYAnchor.constraint(equalTo: pwdLabel.centerYAnchor)
        ]
        
        let showPwdUIViewConstraints = [
            showPwdUIView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showPwdUIView.topAnchor.constraint(equalTo: pwdLabel.bottomAnchor, constant: 30),
            showPwdUIView.leftAnchor.constraint(equalTo: signInView.leftAnchor, constant: 15),
            showPwdUIView.rightAnchor.constraint(equalTo: signInView.rightAnchor, constant: -15),
        ]
        
        let showPwdLabelConstraints = [
            showPwdLabel.leftAnchor.constraint(equalTo: showPwdUIView.leftAnchor, constant: 15),
            //showPwdLabel.topAnchor.constraint(equalTo: showPwdUIView.topAnchor, constant: 15),
            //showPwdLabel.rightAnchor.constraint(equalTo: showPwdUIView.centerXAnchor),

        ]

        let showPwdSwitchConstraints = [
            showPwdSwitch.rightAnchor.constraint(equalTo: showPwdUIView.rightAnchor, constant: -15),
            //showPwdSwitch.topAnchor.constraint(equalTo: showPwdLabel.topAnchor),
            //showPwdSwitch.leftAnchor.constraint(equalTo: showPwdLabel.rightAnchor, constant: 15),
            showPwdSwitch.centerYAnchor.constraint(equalTo: showPwdLabel.centerYAnchor),
        ]
        
        let guideLabelConstraints = [
            guideLabel.bottomAnchor.constraint(equalTo: signInView.topAnchor, constant: -10),
            guideLabel.leftAnchor.constraint(equalTo: signInView.leftAnchor, constant: 10)
        ]
        
        let welcomeLabelConstraints = [
            welcomeLabel.bottomAnchor.constraint(equalTo: guideLabel.topAnchor, constant: -10),
            welcomeLabel.leftAnchor.constraint(equalTo: guideLabel.leftAnchor, constant: -5)
        ]

        let signInBtnConstraints = [
            signInBtn.topAnchor.constraint(equalTo: signInView.bottomAnchor, constant: 15),
            signInBtn.leftAnchor.constraint(equalTo: signInView.leftAnchor, constant: 25),
            signInBtn.rightAnchor.constraint(equalTo: signInView.rightAnchor, constant: -25),
            signInBtn.heightAnchor.constraint(equalToConstant: 50)
        ]

        let askLabelConstraints = [
            askLabel.topAnchor.constraint(equalTo: signInBtn.bottomAnchor, constant: 15),
            askLabel.leftAnchor.constraint(equalTo: signInBtn.leftAnchor, constant: 15)
        ]
        
        let signUpBtnConstraints = [
            //signUpBtn.topAnchor.constraint(equalTo: askLabel.topAnchor),
            signUpBtn.centerYAnchor.constraint(equalTo: askLabel.centerYAnchor),
            signUpBtn.rightAnchor.constraint(equalTo: signInBtn.rightAnchor, constant: -15)
        ]
        
        [signInViewConstraints, emailLabelConstraints, pwdLabelConstraints, emailTFConstraints, pwdTFConstraints, showPwdUIViewConstraints, showPwdLabelConstraints, showPwdSwitchConstraints, guideLabelConstraints, welcomeLabelConstraints, signInBtnConstraints, askLabelConstraints, signUpBtnConstraints]
            .forEach(NSLayoutConstraint.activate(_:))
    }
}
