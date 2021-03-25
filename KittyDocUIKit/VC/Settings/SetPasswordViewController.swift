////
////  SetPasswordViewController.swift
////  KittyDocUIKit
////
////  Created by 곽명섭 on 2021/03/18.
////
//
//import UIKit
//
//class SetPasswordViewController: UIViewController {
//    var userInterfaceStyle: UIUserInterfaceStyle = .unspecified
//    var safeArea: UILayoutGuide!
//
//    var titleLabel: UILabel!
//    var guideLabel: UILabel!
//    
//    var userInfoView: UIView!
//    
//    var emailLabel: UILabel!
//    var emailTF: UITextField!
//    var pwdLabel: UILabel!
//    var pwdTF: UITextField!
//    var pwdConfirmLabel: UILabel!
//    var pwdConfirmTF: UITextField!
//    var signInBtn: UIButton!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//        userInterfaceStyle = self.traitCollection.userInterfaceStyle
//        
//        print("AnalysisViewController.viewDidLoad()")
//        safeArea = view.layoutMarginsGuide
//        initUIViews()
//        addSubviews()
//        prepareForAutoLayout()
//        setConstraints()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//    }
//
//    fileprivate func initUIViews() {
//        initTitleLabel()
//        initGuideLabel()
//        initSignUpView()
//        initEmailLabel()
//        initEmailTF()
//        initNameLabel()
//        initNameTF()
//        initSignUpBtn()
//    }
//
//    fileprivate func addSubviews() {
//        view.addSubview(titleLabel)
//        view.addSubview(guideLabel)
//        
//        view.addSubview(userInfoView)
//        userInfoView.addSubview(emailLabel)
//        userInfoView.addSubview(emailTF)
//        userInfoView.addSubview(nameLabel)
//        userInfoView.addSubview(nameTF)
//        
//        view.addSubview(signUpBtn)
//    }
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
