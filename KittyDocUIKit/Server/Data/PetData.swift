//
//  PetData.swift
//  KittyDocUIKit
//
//  Created by ImHyunWoo on 2021/03/09.
//

import Foundation

class PetData{
    var time: CLong
    var sunVal: Int
    var uvVal: Double
    var vitDVal: Double
    var exerciseVal: Int
    var walkVal: Int
    var stepVal: Int
    var luxpolVal: Double
    var restVal: Int
    var kalVal: Double
    var waterVal: Int
    
    init(){
        self.time = 0
        self.sunVal = 0
        self.uvVal = 0
        self.vitDVal = 0
        self.exerciseVal = 0
        self.walkVal = 0
        self.stepVal = 0
        self.luxpolVal = 0
        self.restVal = 0
        self.kalVal = 0
        self.waterVal = 0
    }
    
    init(_time: CLong, _sunVal: Int, _uvVal: Double, _vitDVal: Double, _exerciseVal: Int, _walkVal: Int, _stepVal: Int, _luxpolVal: Double, _restVal: Int, _kalVal: Double, _waterVal: Int){
        self.time = _time
        self.sunVal = _sunVal
        self.uvVal = _uvVal
        self.vitDVal = _vitDVal
        self.exerciseVal = _exerciseVal
        self.walkVal = _walkVal
        self.stepVal = _stepVal
        self.luxpolVal = _luxpolVal
        self.restVal = _restVal
        self.kalVal = _kalVal
        self.waterVal = _waterVal
    }
}
