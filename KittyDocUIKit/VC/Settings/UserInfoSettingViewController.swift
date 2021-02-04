//
//  UserInfoSettingViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/02/02.
//

import UIKit

class UserInfoSettingViewController: UIViewController {
    var userInterfaceStyle: UIUserInterfaceStyle = .unspecified
    var deviceManager = DeviceManager.shared
    var startSyncButton: UIButton!
    var safeArea: UILayoutGuide!
//    var loggedInPrev: Bool// = false // 여기서 관리?
//    var wantsRememberEmail: Bool// = false
//    var wantsAutoLogin: Bool// = false
//    var wantsDarkTheme: Bool// = false
//    var massUnit: String// = "Kg"
//
//    var UserID: Int
//    var UserPhone: String
//    var UserBirth: String
//    var Email: String
//    var Pw: String
//    var Name: String
//    var gender: String // male / female / none
    var userIdLabel: UILabel!
    var userPhoneLabel: UILabel!
    var userBirthLabel: UILabel!
    var userEmailLabel: UILabel!
    var userPwLabel: UILabel!
    var userPwConfirmLabel: UILabel!
    var userNameLabel: UILabel!
    var userGenderLabel: UILabel!
    
    var userIdTF: UITextField!
    var userPhoneTF: UITextField!
    var userBirthTF: UITextField!
    var userEmailTF: UITextField!
    var userPwTF: UITextField!
    var userPwConfirmTF: UITextField!
    var userNameTF: UITextField!
    var userGenderTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "내 정보"
        
        userInterfaceStyle = self.traitCollection.userInterfaceStyle
        
        print("AnalysisViewController.viewDidLoad()")
        safeArea = view.layoutMarginsGuide
        initUIViews()
        addSubviews()
        prepareForAutoLayout()
        setConstraints()

        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func initUIViews() {
        //initStartSyncButton()
        //initBarChartView()

    }
    
//    private let userIdLabel: UILabel = {
//        let userIdUiLabel = UILabel()
//        userIdUiLabel.text = "User ID : "
////        userIdUiLabel.textColor = .black
////        userIdUiLabel.backgroundColor = .systemBlue
//        return userIdUiLabel
//    }()
    
//    func initStartSyncButton() {
//        startSyncButton = UIButton()
//
//        startSyncButton.setTitle("Start Sync", for: .normal)
//        startSyncButton.setTitleColor(.white, for: .highlighted)
//        startSyncButton.backgroundColor = .systemBlue
//        startSyncButton.layer.cornerRadius = 8
//        startSyncButton.addTarget(self, action: #selector((didTapStartSync)), for: .touchUpInside)
//
//    }
//
//    func initBarChartView() {
//        chart = BarChartView()
//        //What to do??
//    }
    
    func addSubviews() {
        view.addSubview(startSyncButton)
//        view.addSubview(chart)
    }
    
    func prepareForAutoLayout() {
        startSyncButton.translatesAutoresizingMaskIntoConstraints = false
//        chart.translatesAutoresizingMaskIntoConstraints = false

    }

    func setConstraints() {
        startSyncButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            .isActive = true
        startSyncButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10)
            .isActive = true
        startSyncButton.heightAnchor.constraint(equalToConstant: 50)
            .isActive = true
        startSyncButton.widthAnchor.constraint(equalToConstant: 200)
            .isActive = true

//        chart.topAnchor.constraint(equalTo: startSyncButton.bottomAnchor, constant: 100)
//            .isActive = true
//        chart.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//            .isActive = true
//        chart.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//            .isActive = true
//        chart.widthAnchor.constraint(equalTo: view.widthAnchor)
//            .isActive = true
//        chart.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//            .isActive = true
//        proceedBtn.centerXAnchor.constraint(equalTo:view.centerXAnchor)
//            .isActive = true // 부모 뷰의 centerX를 proceedBtn의 centerX로...
//        proceedBtn.centerYAnchor.constraint(equalTo:view.centerYAnchor)
//            .isActive = true // 부모 뷰의 centerY를 proceedBtn의 centerY로...
//        proceedBtn.heightAnchor.constraint(equalToConstant: 50)
//            .isActive = true // proceedBtn의 높이를 50으로...
//        proceedBtn.widthAnchor.constraint(equalToConstant: 200)
//            .isActive = true // proceedBtn의 너비를 200으로...
//
//        guideLabel.topAnchor.constraint(equalTo: proceedBtn.bottomAnchor, constant: 10)
//            .isActive = true // proceedBtn의 bottomAnchor +10를 guideLabel의 topAnchor로...
//        guideLabel.centerXAnchor.constraint(equalTo:view.centerXAnchor)
//            .isActive = true // guideLabel의 centerX를 부모 뷰의 centerX로...
//        guideLabel.heightAnchor.constraint(equalToConstant: 50)
//            .isActive = true // guideLabel의 높이를 50으로...
////        guideLabel.widthAnchor.constraint(equalToConstant: 200)
////            .isActive = true // guideLabel의 높이를 200으로...
////        guideLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 80)
////            .isActive = true // guideLabel의 leftAnchor를 부모 뷰의 왼쪽 끝 +80으로...
////        guideLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -80)
////            .isActive = true // guideLabel의 rightAnchor를 부모 뷰의 오른쪽 끝 -80으로...

    }
    
    @objc func didTapStartSync() {
        let deviceManager = DeviceManager.shared
        
        if deviceManager.isConnected {
            print("didTapStartSync() will start sync")
            deviceManager.startSync()
        } else {
            print("didTapStartSync() Not Connected to KittyDoc Device!")
        }
    }
}
