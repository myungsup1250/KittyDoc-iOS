//
//  daySchedule.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/02/24.
//

import Foundation
import RealmSwift

class daySchedule : Object {
    @objc dynamic var day: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var privateType = careType.hospital.rawValue
    var caretype: careType {
        get { return careType(rawValue: privateType)! }
        set { privateType = newValue.rawValue }
    }
}


enum careType: Int {
    case hospital = 0
    case bob = 1
    case med = 2
    case pill = 3
    case none = 4
}


