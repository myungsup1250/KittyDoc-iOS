//
//  WaterViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/02/10.
//

import Foundation
import UIKit
import CircularSlider

class WaterViewController: UIViewController {
    
    static let identifier = "AddWater"
    
    override func viewDidLoad() {
        
        //view.addSubview(waterSlide)
        view.addSubview(waterLabel)
        view.addSubview(water)
        water.frame = view.frame
        
    }
    
//    let waterSlide: UISlider = {
//       let slider = UISlider()
//        slider.frame = CGRect(x: 50, y: 400, width: 300, height: 50)
//        slider.minimumValue = 0
//        slider.maximumValue = 300
//        slider.addTarget(self, action: #selector(waterChanged), for: .allEvents)
//        return slider
//    }()
    
    lazy var waterLabel: UILabel = {
       let label = UILabel()
        label.frame = CGRect(x: 50, y: 450, width: 100, height: 50)
        //label.text = String(format: "%.0f", waterSlide.maximumValue / 2)
        return label
    }()
    
    let water: CircularSlider = {
       let slider = CircularSlider()
        
        slider.minimumValue = 0
        slider.maximumValue = 300
        slider.icon = UIImage(systemName: "drop")
        slider.lineWidth = 5
        slider.title = "Water"
        slider.pgHighlightedColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        slider.pgNormalColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        slider.radiansOffset = CGFloat(0.2)
        
        return slider
    }()
    
    @objc func waterChanged() {
        //waterLabel.text = String(format: "%.0f", waterSlide.value)
    }
    
}
