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
        
    }
    
    func addSubviews() {
//        view.addSubview(startSyncButton)
//        view.addSubview(chart)
    }
    
    func prepareForAutoLayout() {
//        startSyncButton.translatesAutoresizingMaskIntoConstraints = false
//        chart.translatesAutoresizingMaskIntoConstraints = false

    }

    func setConstraints() {
//        startSyncButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//            .isActive = true
//        startSyncButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10)
//            .isActive = true
//        startSyncButton.heightAnchor.constraint(equalToConstant: 50)
//            .isActive = true
//        startSyncButton.widthAnchor.constraint(equalToConstant: 200)
//            .isActive = true

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
