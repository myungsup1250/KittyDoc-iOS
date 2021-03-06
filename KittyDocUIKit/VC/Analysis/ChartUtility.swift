//
//  ChartUtility.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/03/12.
//

import Foundation

struct ChartUtility {
    public static let SunGoal: Double = 60000
    public static let UVGoal: Double = 100
    public static let VitDGoal: Double = 400
    public static let ExerciseGoal: Double = 100
    public static let WalkGoal: Double = 510
    public static let StepGoal: Double = 7908
    public static let LuxPolGoal: Double = 100
    public static let RestGoal: Double = 946
    public static let KalGoal: Double = 548
    public static let WaterGoal: Double = 400
}

enum SegSelect: Int {
    case Year = 0
    case Month
    case Day
    case Week
}

enum OptSelect: Int {
    case Sun = 0
    case UV
    case Vit_D
    case Exercise
    case Walk
    case Steps
    case LuxPol
    case Rest
    case Kal
    case Water
}
