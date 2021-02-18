//
//  AnalysisViewController.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/16.
//

import UIKit
import Charts

class AnalysisViewController: UIViewController, ChartViewDelegate {
    var userInterfaceStyle: UIUserInterfaceStyle = .unspecified
    var deviceManager = DeviceManager.shared
    var startSyncButton: UIButton!
    var safeArea: UILayoutGuide!
    var chart: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Analysis"
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSyncDataDone), name: .receiveSyncDataDone, object: nil)

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

        chart.delegate = self
    }
    
//    override func viewDidDisappear(_ animated: Bool) {// View가 사라질 때. ViewWillDisappear은 View가 안 보일 때.
//        NotificationCenter.default.removeObserver(self, name: .receiveSyncDataDone, object: nil)
//        print("AnalysisViewController.viewDidDisappear()")
//    }
    
    // receiveSyncDataDone() will be called when Receiving SyncData Done!
    @objc func receiveSyncDataDone() {
        print("\n<<< AnalysisViewController.receiveSyncDataDone() >>>")        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var entries = [BarChartDataEntry]()
            
        for x in 0..<10 {
            entries.append(BarChartDataEntry(x: Double(x), y: Double(x)))
        }

        let set = BarChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.joyful()
        let data  = BarChartData(dataSet: set)
        chart.data = data
    }
    
    func initUIViews() {
        initStartSyncButton()
        initBarChartView()

    }
    
    func initStartSyncButton() {
        startSyncButton = UIButton()
        
        startSyncButton.setTitle("Start Sync", for: .normal)
        startSyncButton.setTitleColor(.white, for: .highlighted)
        startSyncButton.backgroundColor = .systemBlue
        startSyncButton.layer.cornerRadius = 8
        startSyncButton.addTarget(self, action: #selector((didTapStartSync)), for: .touchUpInside)

    }
    
    func initBarChartView() {
        chart = BarChartView()
        //What to do??
    }
    
    func addSubviews() {
        view.addSubview(startSyncButton)
        view.addSubview(chart)
    }
    
    func prepareForAutoLayout() {
        startSyncButton.translatesAutoresizingMaskIntoConstraints = false
        chart.translatesAutoresizingMaskIntoConstraints = false

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

        chart.topAnchor.constraint(equalTo: startSyncButton.bottomAnchor, constant: 100)
            .isActive = true
        chart.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            .isActive = true
//        chart.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//            .isActive = true
        chart.widthAnchor.constraint(equalTo: view.widthAnchor)
            .isActive = true
        chart.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            .isActive = true
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
