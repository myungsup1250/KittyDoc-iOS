//
//  ScaleViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/05/14.
//

import UIKit
import CoreBluetooth

class ScaleViewController: UIViewController, ScaleViewControllerDelegate {

    @IBOutlet weak var WeightBackgroundView: UIView!
    @IBOutlet weak var descriptionBackgroundView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scaleValueLabel: UILabel!
    @IBOutlet weak var connectionLabel: UILabel!
    
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var descriptionImageView: UIImageView!
    
    var isMeasuring: Bool!
    let miScaleManager = MiScaleManager.shared
    //let homeVC = HomeViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isMeasuring = false

        miScaleManager.delegate = self
        //homeVC.delegate = self
        receiveBroadcast()
        addColor()
        
        retryButton.addTarget(self, action: #selector(initMiScaleManager), for: .touchDown)
        submitButton.addTarget(self, action: #selector(submitMeasuredData), for: .touchDown)

    }
    
    @objc func initMiScaleManager() {
        isMeasuring = true
        miScaleManager.disconnect()
        miScaleManager.manager?.stopScan()
        miScaleManager.scanPeripheral()
    }

    @objc func submitMeasuredData() {
        if !isMeasuring {
            // 몸무게 측정 값 제출
//            let modifyData = ModifyData_Weight(_petId: , _petKG: , _petLB: )
//            let server = KittyDocServer()
//            let modifyResponse:ServerResponse = server.weightModify(data: modifyData)
//            if(modifyResponse.getCode() as! Int == ServerResponse.PET_MODIFY_SUCCESS){
//                print(modifyResponse.getMessage())
//            } else {
//                print(modifyResponse.getMessage())
//            }            
        }
    }

    func receiveBroadcast() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(nameChanged),
                                               name: .petName,
                                               object: nil)
    }
    
    @objc func nameChanged(notification: NSNotification) {
        if let index = notification.object as? Int {
            nameLabel.text = "\(PetInfo.shared.petArray[index].PetName) 의 몸무게 측정"
        }
    }
    
    func addColor() {
        WeightBackgroundView.addColor(color: .white)
        descriptionBackgroundView.addColor(color: .white)
        nameView.addColor(color: #colorLiteral(red: 0.4620226622, green: 0.735007147, blue: 1, alpha: 1))
    }
    
    func setButtons() {
        retryButton.isHidden = true
        submitButton.isHidden = true
    }
    
    func setPetName(name: String) {
        nameLabel.text = name
    }

}

extension ScaleViewController: MiScaleManagerDelegate {
    func onMeasureWeightFinished(weight: Double) {
        DispatchQueue.main.async { [self] in
            print("onMeasureWeightFinished(weight: \(weight)")

            if isMeasuring {                
                scaleValueLabel.text = "\(weight)"
                connectionLabel.text = "3. 체중 측정 완료!"
                miScaleManager.disconnect() //.removePeripheral() // removePeripheral()
                descriptionImageView.image = UIImage(named: "checkmark")
                retryButton.isHidden = false
                submitButton.isHidden = false
                isMeasuring = false
            }
        }
    }
    
    func onMeasuringWeight(weight: Double) {
        DispatchQueue.main.async { [self] in
            print("onMeasuringWeight(weight: \(weight)")

            if isMeasuring {
                scaleValueLabel.text = "\(weight)"
                connectionLabel.text = "2. 체중 측정 중 ..."
                descriptionImageView.image = UIImage(named: "timer")
            }
        }
    }
        
    func onDeviceNotFound() {
        DispatchQueue.main.async { [self] in
            print("Couldn't find any Mi Scale Devices!")
            connectionLabel.text = "기기를 찾을 수 없습니다"
        }
    }

    func onDeviceConnected(peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            print("onDeviceConnected(\(peripheral))")
            self.connectionLabel.text = "기기에 연결 중..."
        }
    }

    func onDeviceDisconnected() {
        DispatchQueue.main.async {
            print("onDeviceDisconnected()")
        }
    }

    func onBluetoothNotAccessible() {
        print("[+]onBluetoothNotAccessible()")
        DispatchQueue.main.async {
            self.connectionLabel.text = "블루투스 에러 : 설정을 확인하세요"
            let alert = UIAlertController(title: "Error on Bluetooth!", message: "Please check your settings!", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "Settings", style: .default) { (alert: UIAlertAction!) in
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {//"App-Prefs:root=Bluetooth" //Banned from Apple App Store
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            let cancel = UIAlertAction(title: "Dismiss", style: .destructive) { (alert: UIAlertAction!) in
                print("Dismiss Alert")
            }
            alert.addAction(confirm)
            alert.addAction(cancel)

            self.present(alert, animated: true, completion: nil)
        }
        print("[-]onBluetoothNotAccessible()")
    }

    func onDevicesFound(peripherals: [PeripheralData]) {// peripherals 사용?
        print("[+]onDevicesFound()")
        DispatchQueue.main.async {
            print("\n<<< Found some MiScale Devices! >>>\n")
            self.connectionLabel.text = "기기를 찾았습니다"
        }
        print("[-]onDevicesFound()")
    }

    func onConnectionFailed() {
        print("[+]onConnectionFailed()")
        DispatchQueue.main.async {
            print("\n<<< Failed to Connect to MiScale Device! >>>\n")
            self.connectionLabel.text = "연결이 해제되었습니다"
        }
        print("[-]onConnectionFailed()")
    }

    func onServiceFound() {
        //print("[+]onServiceFound")
        DispatchQueue.main.async {
            print("\n<<< Found all required Service! >>>\n")
            self.connectionLabel.text = "기기에 연결되었습니다"
        }
    }
    
}
