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


class SettingsViewController: UIViewController {
    var Sections = [Section]()

    private let tableView: UITableView = {
        
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
        table.register(SwitchTableViewCell.self, forCellReuseIdentifier:  SwitchTableViewCell.identifier)
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        configureSections()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds

        view.addSubview(tableView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }
    
    func configureSections() {
        Sections.append(Section(title: "My Information",
                                options: [
                                    .staticCell(model: SettingsOption(title: "내 정보", icon: UIImage(systemName: "person.fill")!, iconBackgroundColor: #colorLiteral(red: 0.7725490196, green: 0.8509803922, blue: 0.9294117647, alpha: 1), handler: {
                                        //            let storyboard = UIStoryboard(name: "Main", bundle: nil) // type storyboard name instead of Main
                                        guard let vc = self.storyboard?.instantiateViewController(identifier: "EditUserInfo") as? UserInfoSettingViewController else {
                                            print("guard let vc = self.storyboard?.instantiateViewController(identifier: EditUserInfo) Error")
                                            return
                                        }
                                        
                                        self.navigationController?.pushViewController(vc, animated: true)
                                        //self.present(vc, animated: true)
                                    })),
                                    .staticCell(model: SettingsOption(title: "비밀번호 수정", icon: UIImage(systemName: "person.fill")!, iconBackgroundColor: #colorLiteral(red: 0.6196078431, green: 0.7607843137, blue: 0.9019607843, alpha: 1), handler: {
                                        guard let vc = self.storyboard?.instantiateViewController(identifier: "SetPwdSegue") as? SetPasswordViewController else {
                                            print("guard let vc = self.storyboard?.instantiateViewController(identifier: SetPwdSegue) Error")
                                            return
                                        }
                                        self.navigationController?.pushViewController(vc, animated: true)
                                        //self.present(vc, animated: true)
                                    }))
                                ]))
        
        Sections.append(Section(title: "Cat Settings", options: [.staticCell(model: SettingsOption(title: "냥이 등록", icon: UIImage(systemName: "plus.circle")!, iconBackgroundColor: #colorLiteral(red: 0.4470588235, green: 0.6823529412, blue: 0.9019607843, alpha: 1)) {
            self.performSegue(withIdentifier: "PetSettingsSegue", sender: self)
        })
        ]))

        Sections.append(Section(title: "Device Management",
                                options: [
                                    .staticCell(model: SettingsOption(title: "기기 관리", icon: UIImage(systemName: "gear")!, iconBackgroundColor: #colorLiteral(red: 0.373965323, green: 0.6513406038, blue: 0.8643702865, alpha: 1), handler: {
                                        self.performSegue(withIdentifier: "DeviceManageSegue", sender: self)
                                    })),
                                    .switchCell(model: SettingsSwitchOption(title: "기기 착용 유무(TEST)", icon: UIImage(systemName: "house")!, iconBackgroundColor: #colorLiteral(red: 0.2078431373, green: 0.5098039216, blue: 0.768627451, alpha: 1), handler: {
                                    }, isOn: true)),
                                    .staticCell(model: SettingsOption(title: "기기 설정(TEST)", icon: UIImage(systemName: "gear")!, iconBackgroundColor: #colorLiteral(red: 0.1333333333, green: 0.4431372549, blue: 0.6941176471, alpha: 1), handler: {
                                        self.performSegue(withIdentifier: "BTSettingsSegue", sender: self)
                                    })),
                                    .staticCell(model: SettingsOption(title: "Start Sync(TEST)", icon: UIImage(systemName: "tray.and.arrow.down") ?? .strokedCheckmark, iconBackgroundColor: #colorLiteral(red: 0.03921568627, green: 0.2941176471, blue: 0.4705882353, alpha: 1), handler: {
                                        print("Start Sync!")
                                        DeviceManager.shared.startSync()
                                    })),
                                    .staticCell(model: SettingsOption(title: "CCTV(TEST)", icon: UIImage(systemName: "camera") ?? .strokedCheckmark, iconBackgroundColor: #colorLiteral(red: 0.03921568627, green: 0.2941176471, blue: 0.4705882353, alpha: 1), handler: {
                                        guard let vc = self.storyboard?.instantiateViewController(identifier: "RTSPStreamViewController") as? RTSPStreamViewController else { return }
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }))
                                
                                ]))
        
        Sections.append(Section(title: "Account", options: [
            .staticCell(model: SettingsOption(title: "로그아웃", icon: UIImage(systemName: "power")!, iconBackgroundColor: .systemRed) {
                UserDefaults.standard.removeObject(forKey: "email_test")
                UserDefaults.standard.removeObject(forKey: "pwd_test")
                self.performSegue(withIdentifier: "logoutSegue", sender: self)
            })
            
        ]))
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = Sections[indexPath.section].options[indexPath.row]
        
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = Sections[section]
        return section.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = Sections[indexPath.section].options[indexPath.row]
        switch type.self {
        case .staticCell(let model):
            model.handler()
        case .switchCell(let model):
            model.handler()
        }
    }
}
