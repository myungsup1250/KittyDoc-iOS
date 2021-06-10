//
//  RTSPStreamViewController.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/05/14.
//

import UIKit

class RTSPStreamViewController: UIViewController {
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
    
    let CCTV_URL = URL(string: "rtsp://192.168.10.13:9000/")//"rtsp://10.20.12.35:9000/"
    var safeArea: UILayoutGuide!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("RTSPStreamViewController.viewDidLoad()")

        safeArea = view.layoutMarginsGuide

        videoView = VideoView()
        view.addSubview(videoView)
        videoView.textLabel.font = UIFont.systemFont(ofSize: 40.0)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        
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
//        videoView.topAnchor.constraint(equalTo: safeArea.topAnchor)
//            .isActive = true
//        videoView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
//            .isActive = true
        
        videoStreamURL = CCTV_URL
        guard let url = videoStreamURL else {
            return
        }

        title = url.host

        //navigationController?.setNavigationBarHidden(true, animated: false)

        videoView.loadVideo(from: url)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        let value = UIInterfaceOrientation.landscapeLeft.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RTSPStreamViewController {
    // MARK: Device Orientation

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var shouldAutorotate: Bool {
        return true
    }
}

//extension RTSPStreamViewController {
//// MARK: IBActions
//
//    @IBAction func close(sender: UIBarButtonItem) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func handleTap(gesture: UITapGestureRecognizer) {
//        if let hidden = navigationController?.isNavigationBarHidden {
//            navigationController?.setNavigationBarHidden(!hidden, animated: true)
//        }
//    }
//}
