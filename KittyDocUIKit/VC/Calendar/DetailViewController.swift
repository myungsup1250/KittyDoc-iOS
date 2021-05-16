//
//  DetailViewController.swift
//  calendar2
//
//  Created by JEN Lee on 2021/03/06.
//

import UIKit

class DetailViewController: UIViewController {

    var scheduleArr: [daySchedule] = []
    var today = ""
    var year = ""
    var month = ""
    var day = ""
    
    struct Cells {
        static let detailCell = "detailCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewController()
        addSubViews()
        addConstraints()
        
        print(today)
        print(scheduleArr)
    }
    
    
    private func initViewController() {
        self.view.backgroundColor = .clear
        self.scheduleTable.delegate = self
        self.scheduleTable.dataSource = self
    }
    
    private func addSubViews() {
        
        view.addSubview(screenView)
        screenView.addSubview(titleLabel)
        screenView.addSubview(doneBtn)
        screenView.addSubview(scheduleTable)
    }
    
    
    private func addConstraints() {
        
        NSLayoutConstraint.activate([
            screenView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 180),
            screenView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200),
            screenView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            screenView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: screenView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: screenView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            doneBtn.bottomAnchor.constraint(equalTo: screenView.bottomAnchor, constant: -20),
            doneBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneBtn.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            scheduleTable.topAnchor.constraint(equalTo: screenView.topAnchor, constant: 80),
            scheduleTable.bottomAnchor.constraint(equalTo: doneBtn.topAnchor, constant: -10),
            scheduleTable.leadingAnchor.constraint(equalTo: screenView.leadingAnchor),
            scheduleTable.trailingAnchor.constraint(equalTo: screenView.trailingAnchor)
        ])
        
        
    }
    
    
    let screenView: UIView = {
        let myView = UIView()
        myView.translatesAutoresizingMaskIntoConstraints = false
        myView.addColor(color: .white)
        return myView
    }()
    
    lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(year)년 \(month)월 \(day)일"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    
    let doneBtn: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("확인", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        return button
    }()
    
    @objc func closeModal() {
        self.dismiss(animated: true)
        //삭제
    }

    let scheduleTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(DetailTableViewCell.self, forCellReuseIdentifier: Cells.detailCell)
        return table
    }()
    

}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        scheduleArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.detailCell) as! DetailTableViewCell
        let schedule = scheduleArr[indexPath.row]
        cell.set(schedule: schedule)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    
}
