//
//  PetSettingsViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/20.
//

import UIKit

class PetSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
        

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "냥이 설정"
        self.navigationItem.prompt = "냥이를 등록해주세요!"
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    private let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //MARK: count
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //MARK: 배열 넘기고가~!!~
        let cell = UITableViewCell()
        return cell
    }
    
}
