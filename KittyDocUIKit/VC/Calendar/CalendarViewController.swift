//
//  CalendarViewController.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/16.
//

import UIKit

class CalendarViewController: UIViewController {
    var userInterfaceStyle: UIUserInterfaceStyle = .unspecified
    var deviceManager = DeviceManager.shared
    var safeArea: UILayoutGuide!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calendar"
        
        if self.traitCollection.userInterfaceStyle == .light {
            userInterfaceStyle = .light
        } else if self.traitCollection.userInterfaceStyle == .dark {
            userInterfaceStyle = .dark
        } else {
            userInterfaceStyle = .unspecified
        }
        
        print("AnalysisViewController.viewDidLoad()")
        safeArea = view.layoutMarginsGuide
        initUIViews()
        addSubviews()
        prepareForAutoLayout()
        setConstraints()

    }
    
    func initUIViews() {
        
    }
    func addSubviews() {

    }
    func prepareForAutoLayout() {

    }
    func setConstraints() {

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }

}

