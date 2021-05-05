//
//  BarChartViewExtension.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/05/03.
//

import Foundation
import Charts

extension BarChartView {
    public func addTapRecognizer() {
        let tapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chartTapped))
        tapRecognizer.minimumPressDuration = 0.05
        self.addGestureRecognizer(tapRecognizer)
    }
    @objc func chartTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            // show
            let position = sender.location(in: self)
            let highlight = self.getHighlightByTouchPoint(position)
            //let dataSet = self.getDataSetByTouchPoint(point: position)
            //dataSet?.drawValuesEnabled = true
            highlightValue(highlight)
            //print("chartTapped(highlight index: \(highlight!.x), value: \(highlight!.y))")
            let userInfo:[String: Highlight] = ["highlighted": highlight!]
            NotificationCenter.default.post(name: .highlightedData, object: nil, userInfo: userInfo)
        } else {
//            // hide
//            //data?.dataSets.forEach{ $0.drawValuesEnabled = false }
//            DispatchQueue.background(delay: 0.4, background: nil) {
//                self.highlightValue(nil)
//            }
        }
    }
}

//class TappableBarChartView: BarChartView {
//
//    public override init(frame: CGRect)
//    {
//        super.init(frame: frame)
//        addTapRecognizer()
//    }
//
//    public required init?(coder aDecoder: NSCoder)
//    {
//        super.init(coder: aDecoder)
//        addTapRecognizer()
//    }
//
//    func addTapRecognizer() {
//        let tapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chartTapped))
//        tapRecognizer.minimumPressDuration = 0.1
//        self.addGestureRecognizer(tapRecognizer)
//    }
//
//    @objc func chartTapped(_ sender: UITapGestureRecognizer) {
//        if sender.state == .began || sender.state == .changed {
//            // show
//            let position = sender.location(in: self)
//            let highlight = self.getHighlightByTouchPoint(position)
//            let dataSet = self.getDataSetByTouchPoint(point: position)
//            dataSet?.drawValuesEnabled = true
//            highlightValue(highlight)
//        } else {
//            // hide
//            data?.dataSets.forEach{ $0.drawValuesEnabled = false }
//            highlightValue(nil)
//        }
//    }
//}
