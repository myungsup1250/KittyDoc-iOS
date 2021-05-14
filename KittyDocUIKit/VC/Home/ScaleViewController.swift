//
//  ScaleViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/05/14.
//

import UIKit

class ScaleViewController: UIViewController {

    @IBOutlet weak var scaleValueLabel: UILabel!
    
    //let miScaleManager = MiScaleManager.shared

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //miScaleManager.delegate = self

    }
    

}

//extension ScaleViewController: MiScaleManagerDelegate {
//    func onDeviceNotFound() {
//        DispatchQueue.main.async {
//            print("Couldn't find any KittyDoc Devices!")
//            self.connectionLabel.text = "기기를 찾을 수 없습니다"
//        }
//    }
//
//    func onDeviceConnected(peripheral: CBPeripheral) {
//        DispatchQueue.main.async {
//            print("onDeviceConnected(\(peripheral))")
//            self.connectionLabel.text = "기기에 연결 중..."
//        }
//    }
//
//    func onDeviceDisconnected() {
//        DispatchQueue.main.async {
//            self.connectionLabel.text = "기기 연결이 해제되었습니다"
//            let alert: UIAlertController = UIAlertController(title: "Disconnected!", message: "Disonnected from KittyDoc Device!", preferredStyle: .alert)
//            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alert.addAction(cancel)
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func onBluetoothNotAccessible() {
//        print("[+]onBluetoothNotAccessible()")
//        DispatchQueue.main.async {
//            self.connectionLabel.text = "블루투스 에러 : 설정을 확인하세요"
//            let alert = UIAlertController(title: "Error on Bluetooth!", message: "Please check your settings!", preferredStyle: .alert)
//            let confirm = UIAlertAction(title: "Settings", style: .default) { (alert: UIAlertAction!) in
//                if let appSettings = URL(string: UIApplication.openSettingsURLString) {//"App-Prefs:root=Bluetooth" //Banned from Apple App Store
//                    UIApplication.shared.open(appSettings, options: [:], completionHandler: { (success) in
//                        print("Settings opened: \(success)") // Prints true
//                    })
//                }
//            }
//            let cancel = UIAlertAction(title: "Dismiss", style: .destructive) { (alert: UIAlertAction!) in
//                print("Dismiss Alert")
//            }
//            alert.addAction(confirm)
//            alert.addAction(cancel)
//
//            self.present(alert, animated: true, completion: nil)
//        }
//        print("[-]onBluetoothNotAccessible()")
//    }
//
//    func onDevicesFound(peripherals: [PeripheralData]) {// peripherals 사용?
//        print("[+]onDevicesFound()")
//        DispatchQueue.main.async {
//            print("\n<<< Found some KittyDoc Devices! >>>\n")
//            self.connectionLabel.text = "기기를 찾았습니다"
//        }
//        print("[-]onDevicesFound()")
//    }
//
//    func onConnectionFailed() {
//        print("[+]onConnectionFailed()")
//        DispatchQueue.main.async {
//            print("\n<<< Failed to Connect to KittyDoc Device! >>>\n")
//            self.connectionLabel.text = "연결이 해제되었습니다"
//        }
//        print("[-]onConnectionFailed()")
//    }
//
//    func onServiceFound() {
//        //print("[+]HomeViewController.onServiceFound")
//        DispatchQueue.main.async {
//            print("\n<<< Found all required Service! >>>\n")
//            self.connectionLabel.text = "기기에 연결되었습니다"
//            self.deviceManager.getBattery()
//            self.deviceManager.startSync()
//        }
//        //print("[-]HomeViewController.onServiceFound")
//    }
//
//    func onDfuTargFound(peripheral: CBPeripheral) {
//        DispatchQueue.main.async {
//            self.connectionLabel.text = "초기화가 필요합니다"
//            let alert: UIAlertController = UIAlertController(title: "Found DFU Device!", message: "There is a DFU Device!", preferredStyle: .alert)
//            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alert.addAction(cancel)
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//}
//
//extension HomeViewController: DeviceManagerSecondDelegate {
//    func onSysCmdResponse(data: Data) {
//        print("[+]onSysCmdResponse")
//        //        print("Data : \(data)")
//        //        print("data(count : \(data.count)) => ", terminator: "")
//        //        for i in 0..<data.count {
//        //            print("\(data[i]) ", terminator: "")
//        //        }
//        //        print("")
//        if count == 0 {
//            count += 1
//            deviceManager.setUUID(uuid: CBUUID(data: data.advanced(by: 1)))
//        }
//        print("[-]onSysCmdResponse")
//    }
//
//    func onSyncProgress(progress: Int) {
//        print("[+]onSyncProgress")
//        print("Progress Percent : \(progress)")
//        print("[-]onSyncProgress")
//    }
//
//    func onReadBattery(percent: Int) {
//        DispatchQueue.main.async {
//            print("[+]onReadBattery")
//            print("batteryLevel : \(percent)")
//            let percentDivide: Double = Double(percent) / 100
//            self.batteryView.progress = Float(percentDivide)
//            self.batteryLabel.text = "\(percent) %"
//            print("[-]onReadBattery")
//        }
//    }
//
//    func onSyncCompleted() {
//        DispatchQueue.main.async {
//            self.connectionLabel.text = "동기화 완료"
//        }
//    }
//}
