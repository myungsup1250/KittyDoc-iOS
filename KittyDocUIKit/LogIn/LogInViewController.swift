//
//  LogInViewController.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/18.
//

import UIKit
import Combine

class LoginViewController: UIViewController {
    var userInfo: UserInfo! = UserInfo.shared
    private lazy var contentView = LogInView()
    private let viewModel: LoginViewModel
    private var bindings = Set<AnyCancellable>()
    
    init(viewModel: LoginViewModel = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .darkGray // bacjgroundColor?
        
        setUpTargets()
        setUpBindings()
    }
    
    private func setUpTargets() {
        contentView.logInBtn.addTarget(self, action: #selector(didTapSignIn), for: UIControl.Event.touchUpInside)
        contentView.signUpBtn.addTarget(self, action: #selector(didTapSignUp), for: UIControl.Event.touchUpInside)
    }
    
    private func setUpBindings() {
        func bindViewToViewModel() {
            contentView.emailTF.textPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.email, on: viewModel)
                .store(in: &bindings)
            
            contentView.pwTF.textPublisher
                .receive(on: RunLoop.main)
                .assign(to: \.password, on: viewModel)
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            viewModel.isInputValid
                .receive(on: RunLoop.main)
                .assign(to: \.isValid, on: contentView.logInBtn)
                .store(in: &bindings)
            
            viewModel.$isLoading
                .assign(to: \.isLoading, on: contentView)
                .store(in: &bindings)
            
            viewModel.validationResult
                .sink { completion in
                    switch completion {
                    case .failure:
                        // Error can be handled here (e.g. alert)
                        return
                    case .finished:
                        return
                    }
                } receiveValue: { [weak self] _ in
                    self?.navigateToHome()
                }
                .store(in: &bindings)
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    @objc private func onClick() {
        viewModel.validateCredentials()
    }
    
    private func navigateToHome() {
        let mainTabBarViewController = MainTabBarViewController()
        navigationController?.pushViewController(mainTabBarViewController, animated: true)
    }
    
    @objc private func didTapSignUp() {
        let vc = VC()
//        let storyboardName = vc.mainStoryboardName // "Main"
//        let storyboardId = vc.signUpStoryboardID // "SignUp"
        let storyboard = UIStoryboard(name: vc.mainStoryboardName, bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(identifier: vc.signUpStoryboardID)
        viewController.modalPresentationStyle = .fullScreen
        vc.present(viewController, animated: true)
//        let signUp = self.storyboard!.instantiateViewController(identifier: "SignUp")
//        signUp.modalPresentationStyle = .fullScreen
//            //UIModalTransitionStyle.flipHorizontal
//        present(signUp, animated: true)
    }

    @objc private func didTapSignIn() {// // // // // 로그인 동작 추가 필요 // // // // //
        var logInSuccess: Bool

        if !userInfo.Email.isEmpty && !userInfo.Pw.isEmpty {
            // Attemps Log In

//            let plist = UserDefaults.standard
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
                let vc = VC()
                vc.performSegue(withIdentifier: "LogInSegue", sender: nil) // self.performSegue(withIdentifier: "LogInSegue", sender: nil)
            } else {// Failed
                // Inform user failed to log in!
            }
        }
    }
}
