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
    var deviceManager = DeviceManager.shared
    var delegate: DeviceManagerDelegate!
    private var viewReloadTimer: Timer?
    var petDevices = [String]()
    var knownDevices = [PeripheralData]()
    var unknownDevices = [PeripheralData]()
    private let sections = ["Known Devices", "Unknown Devices"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Manage Device"

        print("BTSettingsViewController.viewDidLoad()")
        safeArea = view.layoutMarginsGuide
        
//        if !PetInfo.shared.petArray.isEmpty { // Pet's Device UUID in String
//            for pet in PetInfo.shared.petArray {
//                print("Pet<\(pet.PetName)>'s Device\t: [ \(pet.Device) ]")
//                if (!pet.Device.isEmpty && pet.Device != "NULL" && pet.Device != "No device") {
//                    let uuid: CBUUID? = CBUUID(string: pet.Device)
//                    // 안드로이드에서 등록한 MAC Address 형식이면 nil 이 된다
//                    if uuid != nil && !petDevices.contains(uuid!.uuidString) {
//                        petDevices.append(uuid!.uuidString)
//                    }
//                }
//            }
//        }
//        print("petDevices :", petDevices)

        setTableView()
        deviceManager.delegate = self
        deviceManager.scanPeripheral()
    }
    
    @objc func pullToRefresh(_ sender: Any) { // Restart scan IoT Device
        viewReloadTimer?.invalidate()
        deviceManager.manager?.stopScan()
        deviceManager.scanPeripheral()
        viewReloadTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshTableView), userInfo: nil, repeats: true)
        self.tableView.refreshControl?.endRefreshing()
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
    
    public func manageFoundDevices() {
        knownDevices.removeAll()
        unknownDevices.removeAll()
        for foundDevice in deviceManager.foundDevices {
            var peripheralData = PeripheralData()
            peripheralData.peripheral = foundDevice.peripheral!
            peripheralData.rssi = foundDevice.rssi
            if petDevices.contains(foundDevice.peripheral!.identifier.uuidString) {
                knownDevices.append(peripheralData)
            } else {
                unknownDevices.append(peripheralData)
            }
        }
        tableView.reloadData()
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
        manageFoundDevices()
    }

    fileprivate func setTableView() {
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
        tableView.rowHeight = tableViewRowHeight

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
    }
}

extension BTSettingsViewController: UITableViewDelegate, UITableViewDataSource { // TableView Funcs

    // Returns the number of sections.
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // Returns the title of the section.
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return knownDevices.count
        } else {// section == 1
            return unknownDevices.count//deviceManager.foundDevices.count
        }
        //return deviceManager.foundDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 가끔 OutOfRangeException 발생... Cell 생성 이전에 foundDevices에 변동이 있을 경우...
        guard indexPath.row < deviceManager.foundDevices.count else {
            print("There's something wrong with the deviceManager.foundDevices!")
            exit(0)
        }
        var peripheralData: PeripheralData
        //let peripheralData = deviceManager.foundDevices[indexPath.row]
        if indexPath.section == 0 {
            peripheralData = knownDevices[indexPath.row]
        } else { // indexPath.section == 1
            peripheralData = unknownDevices[indexPath.row]//deviceManager.foundDevices[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PeripheralDataTableViewCell
        cell.setTableViewCell(peripheralData: peripheralData)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 가끔 OutOfRangeException 발생... Cell 생성 이전에 foundDevices에 변동이 있을 경우...
        guard indexPath.row < deviceManager.foundDevices.count else {
            print("There's something wrong with the deviceManager.foundDevices!")
            exit(0)
        }
        //let peripheralData = deviceManager.foundDevices[indexPath.row]
        var peripheralData: PeripheralData
        if indexPath.section == 0 {
            peripheralData = knownDevices[indexPath.row]
        } else { // indexPath.section == 1
            peripheralData = unknownDevices[indexPath.row]//deviceManager.foundDevices[indexPath.row]
        }

        let alert = UIAlertController(title: "Connect?", message: "KittyDoc will connect to \(peripheralData.peripheral!.name ?? "Unknown")", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "OK", style: .default) { [self] _ in
            deviceManager.manager?.stopScan()
            viewReloadTimer?.invalidate()
            deviceManager.peripheral = peripheralData.peripheral
            deviceManager.connectPeripheral()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(confirm)
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
            let alert = UIAlertController(title: "Device Not Found!", message: "Couldn't find any KittyDoc Devices!", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func onDeviceConnected(peripheral: CBPeripheral) {
        print("Successfully Connected to KittyDoc Device!")
    }

    func onDeviceDisconnected() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Disconnected!", message: "Disonnected from KittyDoc Device!", preferredStyle: .alert)
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
        viewReloadTimer?.invalidate()
        manageFoundDevices()
        //print("[-]onDevicesFound()")
    }

    func onConnectionFailed() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Failed to Connect!", message: "Failed to Connect to KittyDoc Device!", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func onServiceFound() {
        print("[+]onServiceFound")
        print("<<< Found all required Service! >>>")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "KittyDoc is all Set!", message: "Ready to go!", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
                self.deviceManager.getBattery()
            }
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
        print("[-]onServiceFound")

    }
    
    func onDfuTargFound(peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Found DFU Device!", message: "There is a DFU Device!", preferredStyle: .alert)
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
        print("[+]onSyncProgress")
        print("Progress Percent : \(progress)")
        print("[-]onSyncProgress")
    }
    
    func onReadBattery(percent: Int) {
        print("[+]onReadBattery")
        print("batteryLevel : \(percent)")
        print("[-]onReadBattery")
    }
    
    func onSyncCompleted() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Sync Completed!", message: "Synchronization Completed!", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    // // // // // // // // // // // // // // // // // // // //
}
