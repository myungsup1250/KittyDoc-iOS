//
//  AddPetViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/25.
//

import UIKit

class AddPetViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var nameInput: UITextField!
    var weightInput: UITextField!
    var birthInput: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let _: UITextField = {
            nameInput = UITextField()
            nameInput.frame = CGRect(x: 0, y: 0, width: 400, height: 30)
            nameInput.placeholder = "이름"
            return nameInput
        }()
        
        
        let _: UITextField = {
            weightInput = UITextField()
            weightInput.frame = CGRect(x: 0, y: 50, width: 400, height: 30)
            weightInput.placeholder = "몸무게"
            return weightInput
        }()
        
        
        _ = setUpdatePicker()
        
        view.addSubview(image)
        view.addSubview(imageAddBtn)
        
        
        
        view.addSubview(petView)
        
        
        petView.addSubview(nameInput)
        petView.addSubview(weightInput)
        petView.addSubview(weightSelect)
        petView.addSubview(genderSelect)
        petView.addSubview(DateOfBirthLabel)
        petView.addSubview(birthDataField)
        petView.addSubview(deviceLabel)
        petView.addSubview(deviceInput)
        petView.addSubview(scanBtn)
        
        view.addSubview(doneBtn)
    }
    
    
    let image: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "person.circle")
        image.frame = CGRect(x: 110, y: 100, width: 150, height: 150)
        image.layer.cornerRadius = image.frame.height/2
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.clear.cgColor
        image.clipsToBounds = true
        return image
    }()
    
    let imageAddBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 200, y: 230, width: 40, height: 40)
        btn.setBackgroundImage(UIImage(systemName: "pencil"), for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector((didTapImageAddBtn)), for: .touchUpInside)
        
        return btn
    }()
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) { () in
            let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            self.image.image = img
        }
    }
    
    @objc func didTapImageAddBtn() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: false)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: false) { () in
            
            let alert = UIAlertController(title: "", message: "이미지 선택이 취소되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel))
            self.present(alert, animated: false)
            
        }
    }
    
    let petView: UIView = {
        let petView = UIView()
        petView.frame = CGRect(x: 60, y: 300, width: 500, height: 500)
        return petView
    }()
    
    
    
    
    let weightSelect: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.frame = CGRect(x: 140, y: 50, width: 100, height: 30)
        segment.insertSegment(withTitle: "kg", at: 0, animated: true)
        segment.insertSegment(withTitle: "lb", at: 1, animated: true)
        return segment
    }()
    
    
    
    let genderSelect: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.frame = CGRect(x: 0, y: 110, width: 250, height: 40)
        segment.insertSegment(withTitle: "Male", at: 0, animated: true)
        segment.insertSegment(withTitle: "Female", at: 1, animated: true)
        segment.insertSegment(withTitle: "None", at: 2, animated: true)
        return segment
    }()
    
    
    
    let DateOfBirthLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 170, width: 200, height: 50)
        label.text = "생년월일"
        return label
    }()
    
    
    let birthDataField: UITextField = {
        let birthDataField = UITextField()
        birthDataField.frame = CGRect(x: 0, y: 190, width: 300, height: 80)
        birthDataField.placeholder = "여기를 클릭해서 생년월일을 입력해주세요"
        // birthDataField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        return birthDataField
    }()
    
    
    func setUpdatePicker() -> UIDatePicker {
        let picker: UIDatePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(self.dataChanged), for: .allEvents)
        
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        
        self.birthDataField.inputView = picker
        
        let toolBar: UIToolbar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        
        let space: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.tapOnDoneBtn))
        
        toolBar.setItems([space, done], animated: true)
        
        self.birthDataField.inputAccessoryView = toolBar
        return picker
    }
    
    
    @objc func dataChanged(_ picker: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        self.birthDataField.text = dateFormatter.string(from: picker.date)
        
        
        let writedateFormatter = DateFormatter()
        writedateFormatter.dateFormat = "yyyyMMdd"
        birthInput = writedateFormatter.string(from: picker.date)
    }
    
    @objc func tapOnDoneBtn(_ picker: UIDatePicker) {
        birthDataField.resignFirstResponder()
        
    }
    
    let deviceLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 260, width: 100, height: 50)
        label.text = "디바이스"
        return label
    }()
    
    let deviceInput: UILabel = {
        let device = UILabel()
        device.frame = CGRect(x: 0, y: 290, width: 200, height: 50)
        device.text = "디바이스가 없습니다."
        return device
    }()
    
    let scanBtn: UIButton = {
        let scanBtn = UIButton()
        scanBtn.frame = CGRect(x: 170, y: 300, width: 100, height: 30)
        scanBtn.setTitle("스캔", for: .normal)
        scanBtn.backgroundColor = .orange
        scanBtn.layer.cornerRadius = 8
        return scanBtn
    }()
    
    
    let doneBtn: UIButton = {
        let doneBtn = UIButton()
        doneBtn.frame = CGRect(x: 40, y: 660, width: 300, height: 50)
        doneBtn.setTitle("등록", for: .normal)
        doneBtn.backgroundColor = .systemBlue
        doneBtn.layer.cornerRadius = 8
        doneBtn.addTarget(self, action: #selector(didTapDoneBtn), for: .touchUpInside)
        return doneBtn
    }()
    
    
    @objc func didTapDoneBtn() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let birth:String = birthInput ?? dateFormatter.string(from: date)
        
        print("등록 버튼 누름")
        print(nameInput.text!)
        print(weightInput.text!)
        print(weightSelect.selectedSegmentIndex) //0이면 kg, 1이면 lb, -1이면 선택안됨!
        print(genderSelect.selectedSegmentIndex) //0이면 수, 1이면 암, 2이면 중성화..?, -1이면 선택안됨!
        print(birth)
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
}
