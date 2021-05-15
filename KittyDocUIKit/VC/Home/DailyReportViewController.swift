//
//  DailyReportViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/05/15.
//

import UIKit

class DailyReportViewController: UIViewController {

    @IBOutlet weak var goalVIew: UIView!
    @IBOutlet weak var sunLevelView: UIView!
    @IBOutlet weak var moveLevelView: UIView!
    @IBOutlet weak var vitaLevelView: UIView!
    @IBOutlet weak var commentView: UIView!
    
    @IBOutlet weak var sunLevelLabel: UILabel!
    @IBOutlet weak var moveLevelLabel: UILabel!
    @IBOutlet weak var vitaLevelLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var sunValue: Int = 0
    var moveValue: Int = 0
    var vitaValue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViewColor()
        self.title = "Daily Report"
        setData()
    }
    

    func addViewColor() {
        goalVIew.addColor(color: .white)
        commentView.addColor(color: .white)
        sunLevelView.addColor(color: .white)
        moveLevelView.addColor(color: .white)
        vitaLevelView.addColor(color: .white)
    }
    
    func setData() {
        sunLevelLabel.text = calcDataLevel(index: 0, value: sunValue)
        moveLevelLabel.text = calcDataLevel(index: 1, value: moveValue)
        vitaLevelLabel.text = calcDataLevel(index: 2, value: vitaValue)
    }
    
    func calcDataLevel(index: Int, value: Any) -> String {
        let value = value as! Int
        
        switch index {
        
        case 0:
            
            if (value < 20000) {
                return "낮음"
            } else if (value < 40000) {
                return "보통"
            } else {
                return "높음"
            }
            
        case 1:
            
            if value <= 33 {
                return "낮음"
            } else if value <= 66 {
                return "보통"
            } else {
                return "높음"
            }
            
        case 2:
            
                if value < 1000 {
                return "낮음"
                } else if value < 2000 {
                return "보통"
                } else {
                return "높음"
                }
                
        default:
            return "보통"
        }
    }
    
    @IBAction func sunClicked(_ sender: Any) {
        viewClear()
        sunLevelView.addColor(color: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 0.8))
        commentLabel.text = "둥근해가 떴..지만 나는 못자"
    }
    
    @IBAction func moveClicked(_ sender: Any) {
        viewClear()
        moveLevelView.addColor(color: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 0.8))
        commentLabel.text = "운동가야지 .."
    }
    
    @IBAction func vitaClicked(_ sender: Any) {
        viewClear()
        vitaLevelView.addColor(color: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 0.8))
        commentLabel.text = "삐가삐까 .."
    }
    
    func viewClear() {
        
        sunLevelView.addColor(color: .white)
        moveLevelView.addColor(color: .white)
        vitaLevelView.addColor(color: .white)
        
    }
    
}
