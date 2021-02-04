//
//  HomeViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/16.
//

import UIKit

class HomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    //var PetArray: [PetInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        self.navigationController?.navigationBar.prefersLargeTitles = true
       
        view.addSubview(petNameSelectTF)
        view.addSubview(image)
        view.addSubview(speechBubble)
        view.addSubview(talkTemp)
        view.addSubview(WaterBtn)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PetInfo.shared.petArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PetInfo.shared.petArray[row].PetName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("value: \(PetInfo.shared.petArray[row].PetName)")
        petNameSelectTF.text = PetInfo.shared.petArray[row].PetName
    }
    
    
    lazy var pickerView: UIPickerView = {
       let picker = UIPickerView()
        picker.frame = CGRect(x: 0, y: 250, width: self.view.bounds.width, height: 180)
        picker.backgroundColor = .white
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    
    let petNameSelectTF: UITextField = {
        let petNameSelectTF = UITextField()
        petNameSelectTF.frame = CGRect(x: 150, y: 160, width: 100, height: 50)
        petNameSelectTF.text = "왕왕이"
        return petNameSelectTF
    }()
    
    let image: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "person.circle")
        image.frame = CGRect(x: 110, y: 200, width: 150, height: 150)
        
        image.layer.cornerRadius = image.frame.height/2
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.clear.cgColor
        image.clipsToBounds = true
        return image
    }()
    
    
    let speechBubble: UILabel = {
        let bubble = UILabel()
        bubble.frame = CGRect(x: 120, y: 350, width: 200, height: 200)
        bubble.text = "💭"
        bubble.font = bubble.font.withSize(130)
        
        return bubble
    }()
    
    let talkTemp: UILabel = {
        let talk = UILabel()
        talk.frame = CGRect(x: 160, y: 350, width: 200, height: 200)
        talk.text = "냥냥!"
        talk.font = talk.font.withSize(30)
        return talk
    }()
    
    
    
    
    private let WaterBtn: UIButton = {
       let WaterBtn = UIButton()
        WaterBtn.setBackgroundImage(UIImage(systemName: "drop"), for: .normal)
        
        WaterBtn.frame = CGRect(x: 40, y: 600, width: 50, height: 50)
        WaterBtn.addTarget(self, action: #selector(test), for: .touchUpInside)
        return WaterBtn
    }()
   
    
    @objc func test() {
        print(PetInfo.shared.petArray.count)
        print(PetInfo.shared.PetName)
    }

}

