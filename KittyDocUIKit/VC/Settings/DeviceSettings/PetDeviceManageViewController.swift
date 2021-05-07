//
//  DeviceManageViewController.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/05/07.
//

import UIKit

class PetDeviceManageViewController: UIViewController {
    var valueLabel: UILabel!
    var valueUnitLabel: UILabel!
    var calBtn: UIButton!
    var datePicker: UIDatePicker!

    var userInterfaceStyle: UIUserInterfaceStyle!
    var deviceManager = DeviceManager.shared
    var safeArea: UILayoutGuide!
    var dateInput: String = ""
    var petDatas = [PetData]()
    var dateFormatter: DateFormatter!
    
    var tableView: UITableView!
    let tableViewRowHeight: CGFloat = 60
    var petNames = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Manage Device"
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
        print("DeviceManageViewController.viewDidLoad()")
        
        safeArea = view.safeAreaLayoutGuide
        userInterfaceStyle = self.traitCollection.userInterfaceStyle
        
        dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent

        refreshPetNameArray()
        
        initUIViews()
        addSubviews()
        prepareForAutoLayout()
        setConstraints()
        setTableView()
//        manageUserInterfaceStyle()
//        addObservers()
    }
    
    @objc func pullToRefresh(_ sender: Any) { // Refresh Pet Name Array
        refreshPetNameArray()
        tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }
    
    func refreshPetNameArray() {
        petNames.removeAll()
        if !PetInfo.shared.petArray.isEmpty { // Pet's Device UUID in String
            for pet in PetInfo.shared.petArray {
                print("Pet<\(pet.PetName)>")
                petNames.append(pet.PetName)
            }
        }
        print("petNames :", petNames)
    }
    
    func initUIViews() {
        tableView = UITableView()
    }
    
    func addSubviews() {
        view.addSubview(tableView)
    }
    
    func prepareForAutoLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setConstraints() {
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor)
            .isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor)
            .isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
            .isActive = true
        tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
            .isActive = true
    }

    func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(PetDeviceTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = tableViewRowHeight

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
    }
    
}

extension PetDeviceManageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 가끔 OutOfRangeException 발생... Cell 생성 이전에 foundDevices에 변동이 있을 경우...
        guard indexPath.row < PetInfo.shared.petArray.count else {
            print("There's something wrong with PetInfo.shared.petArray!")
            exit(0)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PetDeviceTableViewCell
        cell.setTableViewCell(petType: "CAT", petName: petNames[indexPath.row])//cell.setTableViewCell(petName: petNames[indexPath.row])

        return cell
    }
    
    
}
