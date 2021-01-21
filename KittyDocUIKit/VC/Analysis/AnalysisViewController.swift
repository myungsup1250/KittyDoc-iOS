//
//  AnalysisViewController.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/16.
//

import UIKit
import Charts

class AnalysisViewController: UIViewController, ChartViewDelegate {

    var chart = BarChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chart.delegate = self
        self.title = "Analysis"

    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        chart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
        chart.center = view.center
        view.addSubview(chart)
        
        var entries = [BarChartDataEntry]()
            
        for x in 0..<10 {
            entries.append(BarChartDataEntry(x: Double(x), y: Double(x)))
        }

        let set = BarChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.joyful()
        let data  = BarChartData(dataSet: set)
        chart.data = data
    }

}
