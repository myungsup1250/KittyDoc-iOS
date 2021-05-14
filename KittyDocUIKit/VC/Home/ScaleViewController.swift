//
//  ScaleViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/05/14.
//

import UIKit
import CoreBluetooth

class ScaleViewController: UIViewController {

    @IBOutlet weak var scaleValueLabel: UILabel!
    
    //let miScaleManager = MiScaleManager.shared

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //miScaleManager.delegate = self

    }
    

}

extension ScaleViewController: MiScaleManagerDelegate {
    func onDeviceNotFound() {
        DispatchQueue.main.async {
            print("Couldn't find any Mi Scale Devices!")
            //self.connectionLabel.text = "기기를 찾을 수 없습니다"
        }
    }
    
    func onDeviceConnected(peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            print("onDeviceConnected(\(peripheral))")
            //self.connectionLabel.text = "기기에 연결 중..."
        }
    }
    
    func onDeviceDisconnected() {
        DispatchQueue.main.async {
            print("onDeviceDisconnected()")
        }
    }
    
    func onMeasureWeightFinished(weight: Double) {
        DispatchQueue.main.async {
            print("onMeasureWeightFinished(weight: \(weight)")
            // 검은색으로 몸무게 데이터 출력?
        }
    }
    
    func onMeasuringWeight(weight: Double) {
        DispatchQueue.main.async {
            print("onMeasuringWeight(weight: \(weight)")
            // 회색으로 몸무게 데이터 출력?
        }
    }
    
    func onBluetoothNotAccessible() {
        print("[+]onBluetoothNotAccessible()")
        DispatchQueue.main.async {
            //self.connectionLabel.text = "블루투스 에러 : 설정을 확인하세요"
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
    
    func onDevicesFound(peripherals: [PeripheralData]) {
        print("onDevicesFound()")
        DispatchQueue.main.async {
            print("\n<<< Found some MiScale Devices! >>>\n")
            //self.connectionLabel.text = "기기를 찾았습니다"
        }
    }
    
    func onConnectionFailed() {
        print("onConnectionFailed()")
        DispatchQueue.main.async {
            print("\n<<< Failed to Connect to MiScale Device! >>>\n")
            //self.connectionLabel.text = "연결이 해제되었습니다"
        }
    }
    
    func onServiceFound() {
        //print("[+]onServiceFound")
        DispatchQueue.main.async {
            print("\n<<< Found all required Service! >>>\n")
            //self.connectionLabel.text = "기기에 연결되었습니다"
        }
    }
    
}
