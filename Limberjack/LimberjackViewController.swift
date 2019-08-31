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
    static let armLength = CGFloat(60)
    static let torsoLength = CGFloat(60)
    static let legLength = CGFloat(100)
}

class LimberjackViewController: UIViewController {
    
    let armView = UIView(frame: CGRect(x: Constants.handPoint.x - Constants.lineWidth / 2,
                                       y: Constants.handPoint.y,
                                       width: Constants.lineWidth,
                                       height: Constants.armLength))
    let torsoView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.torsoLength))
    let legView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.legLength))

    let motionManager = CMMotionManager()  // needed to access accelerometers
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var limberjackBehavior = LimberjackBehavior(in: animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        armView.backgroundColor = .blue
        view.addSubview(armView)
        limberjackBehavior.addItem(armView)
        
        let handArmAttachment = UIAttachmentBehavior(
            item: armView,
            offsetFromCenter: UIOffset(horizontal: 0, vertical: -Constants.armLength / 2),
            attachedToAnchor: Constants.handPoint
        )
        animator.addBehavior(handArmAttachment)
        
        torsoView.backgroundColor = .blue
        torsoView.center = CGPoint(x: armView.center.x,
                                   y: armView.center.y + (armView.frame.height + torsoView.frame.height) / 2)
        view.addSubview(torsoView)
        limberjackBehavior.addItem(torsoView)
        
        let armTorsoAttachment = UIAttachmentBehavior(
            item: armView,
            offsetFromCenter: UIOffset(horizontal: 0, vertical: Constants.armLength / 2),
            attachedTo: torsoView,
            offsetFromCenter: UIOffset(horizontal: 0, vertical: -Constants.torsoLength / 2)
        )
        animator.addBehavior(armTorsoAttachment)
        
        legView.backgroundColor = .blue
        legView.center = CGPoint(x: torsoView.center.x,
                                 y: torsoView.center.y + (torsoView.frame.height + legView.frame.height) / 2)
        view.addSubview(legView)
        limberjackBehavior.addItem(legView)
        
        let torsoLegAttachment = UIAttachmentBehavior(
            item: torsoView,
            offsetFromCenter: UIOffset(horizontal: 0, vertical: Constants.torsoLength / 2),
            attachedTo: legView,
            offsetFromCenter: UIOffset(horizontal: 0, vertical: -Constants.legLength / 2)
        )
        animator.addBehavior(torsoLegAttachment)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // use accelerometers to determine direction of gravity
        if motionManager.isAccelerometerAvailable {
            limberjackBehavior.gravityBehavior.magnitude = 1.0
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
        limberjackBehavior.gravityBehavior.magnitude = 0.0
        motionManager.stopAccelerometerUpdates()
    }
}

