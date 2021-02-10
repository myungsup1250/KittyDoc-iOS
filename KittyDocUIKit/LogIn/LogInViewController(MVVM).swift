////
////  LogInViewController.swift
////  KittyDocUIKit
////
////  Created by 곽명섭 on 2021/01/18.
////
//
//import UIKit
//import Combine
//
//class LoginViewController: UIViewController {
//    var userInfo: UserInfo! = UserInfo.shared
//    private lazy var contentView = LogInView()
//    private let viewModel: LoginViewModel
//    private var bindings = Set<AnyCancellable>()
//
//    var email: String?
//    var pw: String?
//
//    init(viewModel: LoginViewModel = LoginViewModel()) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        self.viewModel = LoginViewModel()
//        super.init(coder: aDecoder)
//    }
////    required init?(coder: NSCoder) {
////        fatalError("init(coder:) has not been implemented")
////    }
//
//    override func loadView() {
//        view = contentView
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.backgroundColor = .white//.darkGray // backgroundColor?
//
//        print("LogInViewController.viewDidLoad()")
//        self.navigationItem.prompt = "UITabBarController"
//
//        setUpTargets()
//        setUpBindings()
//
////        // userInfo.wantsRememberEmail = true
////        // userInfo.wantsAutoLogin = true
//
//        if userInfo.loggedInPrev {
//            if userInfo.wantsAutoLogin && !userInfo.Email.isEmpty && !userInfo.Pw.isEmpty { // Automatically Log In
//                print("will AutoLogin")
//                contentView.emailTF.text = userInfo.Email
//                contentView.pwTF.text = userInfo.Pw
//                didTapSignIn()
//            } else if userInfo.wantsRememberEmail && !userInfo.Email.isEmpty { // Just Remember User's Email
//                contentView.emailTF.text = userInfo.Email
//            }
//
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//
//        email = UserDefaults.standard.string(forKey: "email_test")
//        pw = UserDefaults.standard.string(forKey: "pwd_test")
//
//        if let email_test = email {
//            contentView.emailTF.text = email_test
//        }
//
//        if let pw_test = pw {
//            contentView.pwTF.text = pw_test
//        }
//
//        if email != nil && pw != nil {
//            self.performSegue(withIdentifier: "LogInSegue", sender: nil)
//            didTapSignIn()
//        }
//
//        textFieldSetUp()
//        contentView.emailTF.becomeFirstResponder()
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//    private func setUpTargets() {
//        contentView.logInBtn.addTarget(self, action: #selector(didTapSignIn), for: UIControl.Event.touchUpInside)
//        contentView.signUpBtn.addTarget(self, action: #selector(didTapSignUp), for: UIControl.Event.touchUpInside)
//    }
//
//    private func setUpBindings() {
//        func bindViewToViewModel() {
//            contentView.emailTF.textPublisher
//                .receive(on: DispatchQueue.main)
//                .assign(to: \.email, on: viewModel)
//                .store(in: &bindings)
//
//            contentView.pwTF.textPublisher
//                .receive(on: RunLoop.main)
//                .assign(to: \.password, on: viewModel)
//                .store(in: &bindings)
//        }
//
//        func bindViewModelToView() {
//            viewModel.isInputValid
//                .receive(on: RunLoop.main)
//                .assign(to: \.isValid, on: contentView.logInBtn)
//                .store(in: &bindings)
//
//            viewModel.$isLoading
//                .assign(to: \.isLoading, on: contentView)
//                .store(in: &bindings)
//
//            viewModel.validationResult
//                .sink { completion in
//                    switch completion {
//                    case .failure:
//                        // Error can be handled here (e.g. alert)
//                        return
//                    case .finished:
//                        return
//                    }
//                } receiveValue: { [weak self] _ in
//                    self?.navigateToHome()
//                }
//                .store(in: &bindings)
//
//        }
//
//        bindViewToViewModel()
//        bindViewModelToView()
//    }
//
//    @objc private func onClick() {
//        viewModel.validateCredentials()
//    }
//
//    private func navigateToHome() {
//        let mainTabBarViewController = MainTabBarViewController()
//        navigationController?.pushViewController(mainTabBarViewController, animated: true)
//    }
//
//    @objc private func didTapSignUp() {
//        let signUp = self.storyboard!.instantiateViewController(identifier: "SignUp")
//        signUp.modalPresentationStyle = .fullScreen
//            //UIModalTransitionStyle.flipHorizontal
//        present(signUp, animated: true)
//    }
//
//    @objc private func didTapSignIn() {
//        if contentView.emailTF.text!.isEmpty {
//            alertWithMessage(message: "아이디를 입력해주세요!")
//        } else if contentView.pwTF.text!.isEmpty {
//            alertWithMessage(message: "비밀번호를 입력해주세요!")
//        }
//        else {
//            if(!isEmailForm(_email:contentView.emailTF.text!)){
//                alertWithMessage(message: "올바른 이메일 형식이 아닙니다!")
//                return
//            }
//            if(!isPwdForm(_pwd:contentView.pwTF.text!)){
//                alertWithMessage(message: "비밀번호를 입력해주세요!")
//                return
//            }
//            // Attemps Log In
////            let plist = UserDefaults.standard
//            //let userDict: [String : Any]? = plist.dictionary(forKey: "UserInfo")
//
//            let loginData:LoginData = LoginData(_userEmail: contentView.emailTF.text!, _userPwd: contentView.pwTF.text!)
//            let server:KittyDocServer = KittyDocServer()
//            let loginResponse:ServerResponse = server.userLogin(data: loginData)
//
//            //가능하다면 실패 시에 잘못 입력한 뷰로 focus를 주는 기능이 들어가는게 좋을듯. --- O
//            //회원가입 화면에 보면, UserInfo를 회원가입 성공시 초기화 한다는 주석이 있는데 아닌것 같음.
//            //회원가입만 하면 로그인도 안했는데 로그인 한것처럼 어플이 이미 모든 로그인 데이터를 가지고 있게 되니까! OOOK!
//            //intent느낌으로 메인 화면 방금 가입한 이메일이랑 비밀번호 채워주는건 좋은듯 ---- LATER
//
//
//            if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_SUCCESS){
//                self.performSegue(withIdentifier: "LogInSegue", sender: nil)
//                //MARK: TEMP ORIGIN HERE
//                UserDefaults.standard.set(contentView.emailTF.text, forKey: "email_test")
//                UserDefaults.standard.set(contentView.pwTF.text, forKey: "pwd_test")
//
//
//                let jsonString:String = loginResponse.getMessage() as! String
//                if let data = jsonString.data(using: .utf8) {
//                    do {
//                        if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject] {
//                            userInfo.Email = json["UserEmail"]! as! String
//                            userInfo.Pw = json["UserPwd"]! as! String
//                            userInfo.gender = json["UserSex"] as! String
//                            userInfo.Name = json["UserName"] as! String
//                            userInfo.UserID = json["UserID"] as! Int
//                            userInfo.UserPhone = json["UserPhone"] as! String
//                            userInfo.UserBirth = json["UserBirth"] as! String
//                            print(userInfo!)
//                        }
//                    } catch {
//                        print("JSON 파싱 에러")
//                    }
//                }
//
//
//            } else if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_WRONG_EMAIL) {
//                alertWithMessage(message: loginResponse.getMessage())
//                contentView.emailTF.becomeFirstResponder()
//            } else if(loginResponse.getCode() as! Int == ServerResponse.LOGIN_WRONG_PWD) {
//                print(loginResponse.getMessage())
//                contentView.pwTF.becomeFirstResponder()
//                alertWithMessage(message: loginResponse.getMessage())
//            } else {
//                print(loginResponse.getMessage())
//            }
//        }
//    }
//
//    func textFieldSetUp() {
//        contentView.emailTF.text = ""
//        contentView.pwTF.text = ""
//    }
//
//
//    func alertWithMessage(message input: Any) {
//        let alert = UIAlertController(title: "", message: input as? String, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
//        self.present(alert, animated: false)
//    }
//
//    //이메일 형식인지에 대한 정규표현식. 인터넷에 검색하면 쉽게 나오니 바꾸고 싶은게 있으면 바꾸셈
//    func isEmailForm(_email:String) -> Bool{
//        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,50}"
//        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailReg)
//        return emailTest.evaluate(with: _email)
//    }
//
//    //비밀번호 형식에 대한 검사함수. 지금은 길이가 1이상만 되면 되는 것으로 했지만 추후에 특수문자포함여부, 길이제한 추가하게 될지도?
//    func isPwdForm(_pwd:String) -> Bool{
//        if _pwd.count > 0 {
//            return true
//        } else {
//            return false
//        }
//    }
//}
