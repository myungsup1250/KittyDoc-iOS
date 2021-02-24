//
//  BTSettingsViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/20.
//

import Foundation
import UIKit
import CoreBluetooth

class BTSettingsViewController: UIViewController {
    var tableView: UITableView!
    let tableViewRowHeight: CGFloat = 55
    var safeArea: UILayoutGuide!
    var deviceManager: DeviceManager = DeviceManager.shared
    var delegate: DeviceManagerDelegate!
    private var viewReloadTimer: Timer?
    var peripherals: [PeripheralData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Manage Device"
        //self.navigationItem.prompt = "기기 등록을 진행해주세요"
        
        print("BTSettingsViewController.viewDidLoad()")
//        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide

        setTableView()
        deviceManager.delegate = self
        if deviceManager.isConnected {
            print("\ndeviceManager.isConnected == true")
            //이미 연결된 기기가 있을 경우 어떻게?
            var prevPeripheralData = PeripheralData()
            prevPeripheralData.peripheral = deviceManager.peripheral
            deviceManager.peripheral?.readRSSI()
            prevPeripheralData.rssi = 0//deviceManager.curRSSI
            peripherals.append(prevPeripheralData)
            deviceManager.scanPeripheral()

        } else {
            print("\ndeviceManager.isConnected != true")
            deviceManager.scanPeripheral()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("BTSettingsViewController.viewWillAppear()")
        viewReloadTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshTableView), userInfo: nil, repeats: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("BTSettingsViewController.viewWillDisappear()")
        viewReloadTimer?.invalidate()
    }
    
    @objc private func refreshTableView() {
        print("refreshTableView()")
        guard deviceManager.manager != nil else {
            print("deviceManager.manager == nil!(refreshTableView)")
            return
        }
        if deviceManager.foundDevices.count > 0 && deviceManager.manager!.isScanning {
            tableView.reloadData()
        }
    }

    func setTableView() {
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor)
            .isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor)
            .isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
            .isActive = true
        tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
            .isActive = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PeripheralDataTableViewCell.self, forCellReuseIdentifier: "cell")
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tableView.rowHeight = tableViewRowHeight
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = tableViewRowHeight
    }
}

extension BTSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    // TableView Funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceManager.foundDevices.count// peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let peripheralData = deviceManager.foundDevices[indexPath.row]//peripherals[indexPath.row] // 종종 index 오류 발생... Why???
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PeripheralDataTableViewCell
        
        cell.setTableViewCell(peripheralData: peripheralData)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheralData = deviceManager.foundDevices[indexPath.row]
        let alert: UIAlertController = UIAlertController(title: "Connect?", message: "KittyDoc will connect to \(peripheralData.peripheral!.name ?? "Unknown")", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "OK", style: .default) { [self] _ in
            deviceManager.manager?.stopScan()
            viewReloadTimer?.invalidate()
            deviceManager.peripheral = peripheralData.peripheral
            deviceManager.connectPeripheral()//self.deviceManager.connectPeripheral()
        }
        alert.addAction(confirm)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        print("You've selected \(indexPath.row)th Row!")
        print("uuid : \(peripheralData.peripheral!.identifier.uuidString)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension BTSettingsViewController: DeviceManagerDelegate {
    func onDeviceNotFound() {
        DispatchQueue.main.async {
            self.viewReloadTimer?.invalidate()
            let alert: UIAlertController = UIAlertController(title: "Device Not Found!", message: "Couldn't find any KittyDoc Devices!", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func onDeviceConnected(peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            print("Successfully Connected to KittyDoc Device!")
//            let alert: UIAlertController = UIAlertController(title: "Connected!", message: "Successfully Connected to KittyDoc Device!", preferredStyle: .alert)
//            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alert.addAction(cancel)
//            self.present(alert, animated: true, completion: nil)
        }
    }

    func onDeviceDisconnected() {
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController(title: "Disconnected!", message: "Disonnected from KittyDoc Device!", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func onBluetoothNotAccessible() {
        print("[+]onBluetoothNotAccessible()")
        DispatchQueue.main.async {
            self.viewReloadTimer?.invalidate()
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
        //print("[+]onDevicesFound()")
        // 찾은 장치는 이미 테이블뷰에 잘 보이니, viewReloadTimer만 작동 중지시킨다?
        viewReloadTimer?.invalidate()
        tableView.reloadData()// 검색된 기기 모두 보여주다가 foundDevices 정렬 후에 reloadData()하거나, 모든 기기 다 찾은 후에 보여줄 것인가?
        //print("[-]onDevicesFound()")
    }

    func onConnectionFailed() {
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController(title: "Failed to Connect!", message: "Failed to Connect to KittyDoc Device!", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func onServiceFound() {
        print("[+]onServiceFound")
        print("<<< Found all required Service! >>>")
        DispatchQueue.main.async {
            //let alert: UIAlertController = UIAlertController(title: "Service Found!", message: "Found all required Service!", preferredStyle: .alert)
            let alert: UIAlertController = UIAlertController(title: "KittyDoc is all Set!", message: "Ready to go!", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
                self.deviceManager.getBattery()
                //self.deviceManager.startSync()
            }
//            let confirm = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
        print("[-]onServiceFound")

    }
    
    func onDfuTargFound(peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController(title: "Found DFU Device!", message: "There is a DFU Device!", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    // // // // // // // // // // // // // // // // // // // //
    // Delegate 분리? 21.02.14
    
    func onSysCmdResponse(data: Data) {
        print("[+]onSysCmdResponse")
        print("Data : \(data)")
        print("[-]onSysCmdResponse")
    }
    
    func onSyncProgress(progress: Int) {
        //print("[+]onSyncProgress")
        //print("Progress Percent : \(progress)")
        //print("[-]onSyncProgress")
    }
    
    func onReadBattery(percent: Int) {
        print("[+]onReadBattery")
        print("batteryLevel : \(percent)")
        print("[-]onReadBattery")
    }
    
    func onSyncCompleted() {
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController(title: "Sync Completed!", message: "Synchronization Completed!", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    // // // // // // // // // // // // // // // // // // // //
}
