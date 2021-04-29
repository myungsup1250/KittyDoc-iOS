//
//  RingProgressGroupView.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/04/26.
//

import UIKit
import MKRingProgressView

class RingProgressGroupView: UIView {
    
        let ring1 = RingProgressView()
        let ring2 = RingProgressView()
        let ring3 = RingProgressView()
        
        @IBInspectable var ring1StartColor: UIColor = .red {
            didSet {
                ring1.startColor = ring1StartColor
            }
        }
        
        @IBInspectable var ring1EndColor: UIColor = .blue {
            didSet {
                ring1.endColor = ring1EndColor
            }
        }
        
        @IBInspectable var ring2StartColor: UIColor = .red {
            didSet {
                ring2.startColor = ring2StartColor
            }
        }
        
        @IBInspectable var ring2EndColor: UIColor = .blue {
            didSet {
                ring2.endColor = ring2EndColor
            }
        }
        
        @IBInspectable var ring3StartColor: UIColor = .red {
            didSet {
                ring3.startColor = ring3StartColor
            }
        }
        
        @IBInspectable var ring3EndColor: UIColor = .blue {
            didSet {
                ring3.endColor = ring3EndColor
            }
        }
        
        @IBInspectable var ringWidth: CGFloat = 20 {
            didSet {
                ring1.ringWidth = ringWidth
                ring2.ringWidth = ringWidth
                ring3.ringWidth = ringWidth
                setNeedsLayout()
            }
        }
        
        @IBInspectable var ringSpacing: CGFloat = 2 {
            didSet {
                setNeedsLayout()
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            print("RingProgressGroupView.init()")
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }
        
        private func setup() {
            addSubview(ring1)
            addSubview(ring2)
            addSubview(ring3)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            ring1.frame = bounds
            ring2.frame = bounds.insetBy(dx: ringWidth + ringSpacing, dy: ringWidth + ringSpacing)
            ring3.frame = bounds.insetBy(dx: 2 * ringWidth + 2 * ringSpacing, dy: 2 * ringWidth + 2 * ringSpacing)
        }

}
