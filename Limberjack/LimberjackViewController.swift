//
//  LimberjackViewController.swift
//  Limberjack
//
//  Created by Phil Stern on 8/29/19.
//  Copyright © 2019 Phil Stern. All rights reserved.
//

import UIKit
import CoreMotion

struct Constants {
    static let handPoint = CGPoint(x: 190, y: 250)  // in animator's reference view coordinates
    static let lineWidth = CGFloat(3)
    static let headRadius = CGFloat(8)
    static let neckLength = CGFloat(10)
    static let armLength = CGFloat(60)
    static let torsoLength = CGFloat(80)
    static let legLength = CGFloat(90)
}

class LimberjackViewController: UIViewController {
    
    let armView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.armLength))
    let torsoView = HeadAndTorsoView(frame: CGRect(x: 0, y: 0,
                                                   width: (Constants.headRadius + Constants.lineWidth) * 2,
                                                   height: Constants.torsoLength))
    let legView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.legLength))

    let motionManager = CMMotionManager()  // needed for accelerometers
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var limberjackBehavior = LimberjackBehavior(in: animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        armView.backgroundColor = .blue
        torsoView.backgroundColor = .clear
        legView.backgroundColor = .blue
        
        attach(topOf: armView, to: Constants.handPoint)
        attach(topOf: torsoView, offsetBy: Constants.headRadius * 2 + Constants.neckLength, toBottomOf: armView)
        attach(topOf: legView, offsetBy: 0, toBottomOf: torsoView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // use accelerometers to determine direction of gravity
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                if let x = data?.acceleration.x, let y = data?.acceleration.y {
                    self.limberjackBehavior.gravityBehavior.gravityDirection = CGVector(dx: x, dy: -y)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopAccelerometerUpdates()
    }

    private func attach(topOf view1: UIView, to point: CGPoint) {
        view1.center = CGPoint(x: point.x,
                               y: point.y + view1.frame.height / 2)
        view.addSubview(view1)
        limberjackBehavior.addItem(view1)
        
        let attachment = UIAttachmentBehavior(
            item: view1,
            offsetFromCenter: UIOffset(horizontal: 0, vertical: -view1.frame.height / 2),
            attachedToAnchor: point
        )
        animator.addBehavior(attachment)
    }
    
    private func attach(topOf view1: UIView, offsetBy: CGFloat, toBottomOf view2: UIView) {
        view1.center = CGPoint(x: view2.center.x,
                               y: view2.center.y + (view2.frame.height + view1.frame.height) / 2 - offsetBy)
        view.addSubview(view1)
        limberjackBehavior.addItem(view1)
        
        let attachment = UIAttachmentBehavior(
            item: view2,
            offsetFromCenter: UIOffset(horizontal: 0, vertical: view2.frame.height / 2),
            attachedTo: view1,
            offsetFromCenter: UIOffset(horizontal: 0, vertical: -view1.frame.height / 2 + offsetBy)
        )
        animator.addBehavior(attachment)
    }
}

