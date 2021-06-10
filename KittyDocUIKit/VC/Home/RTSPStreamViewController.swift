//
//  RTSPStreamViewController.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/05/14.
//

import UIKit

class RTSPStreamViewController: UIViewController {
    let CCTV_URL = URL(string: "rtsp://192.168.10.2:9000/")//"rtsp://10.20.12.35:9000/"
    var safeArea: UILayoutGuide!
    var videoView: VideoView!
    var videoStreamURL: URL? {
        willSet {
            if let url = newValue {
                if let videoView = videoView {
                    videoView.loadVideo(from: url)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("RTSPStreamViewController.viewDidLoad()")
        self.title = "WhoseCat TV"//url.host
        safeArea = view.layoutMarginsGuide
        
        initVideoView()
        videoStreamURL = CCTV_URL
        guard let url = videoStreamURL else {
            return
        }
        videoView.loadVideo(from: url)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        let value = UIInterfaceOrientation.landscapeLeft.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    func initVideoView() {
        videoView = VideoView()
        view.addSubview(videoView)
        videoView.textLabel.font = UIFont.systemFont(ofSize: 40.0)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.leftAnchor.constraint(equalTo: view.leftAnchor)
            .isActive = true
        videoView.rightAnchor.constraint(equalTo: view.rightAnchor)
            .isActive = true
        videoView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
            .isActive = true
        videoView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
            .isActive = true
        videoView.heightAnchor.constraint(equalTo: videoView.widthAnchor, multiplier: 9/16)
            .isActive = true

    }
}
