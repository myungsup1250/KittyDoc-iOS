//
//  HomeViewController.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/16.
//

import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        self.navigationController?.navigationBar.prefersLargeTitles = true
       
        view.addSubview(image)
        view.addSubview(imageAddBtn)

        
    }
    
    let image: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "gear")
        image.frame = CGRect(x: 120, y: 200, width: 150, height: 150)
        image.layer.cornerRadius = image.frame.height/2
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.clear.cgColor
        image.clipsToBounds = true
        return image
    }()
    
    
    let imageAddBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 120, y: 300, width: 100, height: 100)
        btn.setTitle("사진 추가", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector((didTapImageAddBtn)), for: .touchUpInside)

        return btn
    }()
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) { () in
            let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            self.image.image = img
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: false) { () in
            
            let alert = UIAlertController(title: "", message: "이미지 선택이 취소되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel))
            self.present(alert, animated: false)
            
        }
    }
    
    
    @objc func didTapImageAddBtn() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: false)
    }
       
   

}
