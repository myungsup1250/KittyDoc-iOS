//
//  daySchedule.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/02/24.
//

import Foundation

class daySchedule {
    var day: String = ""
    var title: String = ""
    var type: careType = .none
}


enum careType {
    case hospital
    case bob
    case snack
    case med
    case none
}

