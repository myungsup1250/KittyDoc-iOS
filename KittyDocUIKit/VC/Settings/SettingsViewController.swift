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
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        self.title = "Settings"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 화면 터치 시 키보드 내려가는 코드! -ms
    }
    
    func configure() {
        models.append(Section(title: "Device Connection", options: [.switchCell(model: SettingsSwitchOption(title: "기기 착용 유무", icon: UIImage(systemName: "house")!, iconBackgroundColor: .systemYellow, handler: {
        }, isOn: true)),
        .staticCell(model: SettingsOption(title: "기기 설정", icon: UIImage(systemName: "gear")!, iconBackgroundColor: .systemGreen, handler: {
            self.performSegue(withIdentifier: "BTSettingsSegue", sender: self)
        }))
        
        ]))
        
        
        
        models.append(Section(title: "My Information", options: [.staticCell(model: SettingsOption(title: "내 정보", icon: UIImage(systemName: "person.fill")!, iconBackgroundColor: .systemOrange, handler: {
            //self.performSegue(withIdentifier: "UserInfoSegue", sender: self)
            print("수정클릭됨")
            let storyboard = UIStoryboard(name: "Main", bundle: nil) // type storyboard name instead of Main
            guard let vc = storyboard.instantiateViewController(identifier: "SignUp") as? SignUpViewController else {
                print("guard let vc = self.storyboard?.instantiateViewController(identifier: SignUp) Error")
                return
            }
            
            //뷰컨 인스턴스화해서 값 넘겨주고 확인누르면 그 객체에 정보가 들어가야 하는디 isEditMode 를 false true로 조절
            // test
            UserInfo.shared.Email = "myungsup1250@gmail.com"
            UserInfo.shared.Pw = "123456"
            UserInfo.shared.Name = "곽명섭"
            UserInfo.shared.gender = "male"
            UserInfo.shared.UserPhone = "01012345678"
            UserInfo.shared.UserBirth = "19960330"
            // test
            vc.editEmail = UserInfo.shared.Email
            vc.editPw = UserInfo.shared.Pw//비밀번호 등 정보는 서버에서 받아와서 처리하나?
            vc.editName = UserInfo.shared.Name
            vc.editGender = UserInfo.shared.gender
            vc.editPhone = UserInfo.shared.UserPhone
            vc.editBirth = UserInfo.shared.UserBirth

            vc.isEditMode = true
            vc.doneBtn.setTitle("수정", for: .normal)
            self.navigationController?.pushViewController(vc, animated: true)
//            self.present(vc, animated: true)
        }))
        ]))
        
        
        
        models.append(Section(title: "Cat Settings", options: [.staticCell(model: SettingsOption(title: "냥이 등록", icon: UIImage(systemName: "plus.circle")!, iconBackgroundColor: .systemBlue) {
            self.performSegue(withIdentifier: "PetSettingsSegue", sender: self)
        })
        ]))
        
        models.append(Section(title: "Account", options: [
            .staticCell(model: SettingsOption(title: "로그아웃", icon: UIImage(systemName: "power")!, iconBackgroundColor: .systemRed) {
                UserDefaults.standard.removeObject(forKey: "email_test")
                UserDefaults.standard.removeObject(forKey: "pwd_test")
                self.performSegue(withIdentifier: "logoutSegue", sender: self)
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
