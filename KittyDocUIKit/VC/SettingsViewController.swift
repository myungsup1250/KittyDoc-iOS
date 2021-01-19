//
//  SettingViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/06.
//

import UIKit

struct Section {
    let title: String
    let options : [SettingsOptionType]
}

enum SettingsOptionType {
    case staticCell(model: SettingsOption)
    case switchCell(model: SettingsSwitchOption)
}

struct SettingsSwitchOption {
    let title: String
    let icon: UIImage
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
    var isOn: Bool
}

struct SettingsOption {
    let title: String
    let icon: UIImage
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
}


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView: UITableView = {
    
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
        table.register(SwitchTableViewCell.self, forCellReuseIdentifier:  SwitchTableViewCell.identifier)
       
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        title = "Settings"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        self.title = "Settings"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        

    }
    
    func configure() {
        models.append(Section(title: "Device Connection", options: [.switchCell(model: SettingsSwitchOption(title: "기기 착용 유무", icon: UIImage(systemName: "house")!, iconBackgroundColor: .systemYellow, handler: {
            
        }, isOn: true)),
        ]))
        
        models.append(Section(title: "My Information", options: [.staticCell(model: SettingsOption(title: "내 정보", icon: UIImage(systemName: "person.fill")!, iconBackgroundColor: .systemOrange) {
        })
        ]))
        
        models.append(Section(title: "Account Settings", options:
            [.staticCell(model: SettingsOption(title: "기기 상태", icon: UIImage(systemName: "note.text")!, iconBackgroundColor: .systemGreen) {
            print("first tapped")
            })
            ,
            .staticCell(model: SettingsOption(title: "기기 추가", icon: UIImage(systemName: "plus.circle")!, iconBackgroundColor: .systemBlue) {
            print("first tapped")
        }),
            .staticCell(model: SettingsOption(title: "기기 제거", icon: UIImage(systemName: "minus.circle")!, iconBackgroundColor: .systemPink) {
            print("first tapped")
        })
        
        ]))
        
        models.append(Section(title: "Cat Settings", options: [.staticCell(model: SettingsOption(title: "냥이 등록", icon: UIImage(systemName: "plus.circle")!, iconBackgroundColor: .systemBlue) {
            print("first tapped")
        })
        
        ]))
        
        models.append(Section(title: "Account", options: [
            .staticCell(model: SettingsOption(title: "로그아웃", icon: UIImage(systemName: "power")!, iconBackgroundColor: .systemRed) {
            print("first tapped")
        })
        
        ]))
        
    }
    
    
    var models = [Section]()
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        
        switch model.self {
        case .staticCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingTableViewCell.identifier,
                for: indexPath
            ) as? SettingTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
        case .switchCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SwitchTableViewCell.identifier,
                for: indexPath
            ) as? SwitchTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = models[indexPath.section].options[indexPath.row]
        switch type.self {
        case .staticCell(let model):
            model.handler()
        case .switchCell(let model):
            model.handler()
    }
    
    

}
}
