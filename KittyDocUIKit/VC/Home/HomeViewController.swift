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
        view.addSubview(speechBubble)
        view.addSubview(talkTemp)
        
    }
    
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
    
    
    let imageAddBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 200, y: 330, width: 40, height: 40)
        btn.setBackgroundImage(UIImage(systemName: "pencil"), for: .normal)
        btn.setTitleColor(.black, for: .normal)
        //btn.backgroundColor =
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
   

}

