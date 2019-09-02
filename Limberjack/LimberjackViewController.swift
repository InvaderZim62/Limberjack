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
    static let neckLength = CGFloat(12)
    static let biseptLength = CGFloat(30)
    static let forearmLength = CGFloat(30)
    static let torsoLength = CGFloat(80)
    static let thighLength = CGFloat(45)
    static let shinLength = CGFloat(45)
}

class LimberjackViewController: UIViewController {
    
    var leftHandAttachment: UIAttachmentBehavior!
    var rightHandAttachment: UIAttachmentBehavior!

    let headAndNeckLength = Constants.headRadius * 2 + Constants.neckLength
    let elbowRange = UIFloatRange(minimum: 0.0, maximum: 2.0)  // radians, positive bends backwards
    let shoulderRange = UIFloatRange(minimum: -CGFloat.pi, maximum: CGFloat.pi)
    let hipRange = UIFloatRange(minimum: -2.8, maximum: 1.0)
    let kneeRange = UIFloatRange(minimum: 0.0, maximum: 2.0)

    let leftBiseptView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.biseptLength))
    let rightBiseptView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.biseptLength))
    let leftForearmView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.forearmLength))
    let rightForearmView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.forearmLength))
    let leftThighView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.thighLength))
    let rightThighView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.thighLength))
    let leftShinView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.shinLength))
    let rightShinView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.shinLength))
    let torsoView = HeadAndTorsoView(frame: CGRect(x: 0, y: 0,
                                                   width: (Constants.headRadius + Constants.lineWidth) * 2,
                                                   height: Constants.torsoLength))

    let motionManager = CMMotionManager()  // needed for accelerometers
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var limberjackBehavior = LimberjackBehavior(in: animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
        
        view.addSubview(leftBiseptView)
        view.addSubview(rightBiseptView)
        view.addSubview(leftForearmView)
        view.addSubview(rightForearmView)
        view.addSubview(torsoView)
        view.addSubview(leftThighView)
        view.addSubview(rightThighView)
        view.addSubview(leftShinView)
        view.addSubview(rightShinView)

        leftBiseptView.backgroundColor = .blue
        rightBiseptView.backgroundColor = .clear
        leftForearmView.backgroundColor = .blue
        rightForearmView.backgroundColor = .clear
        torsoView.backgroundColor = .clear
        leftThighView.backgroundColor = .blue
        rightThighView.backgroundColor = .clear
        leftShinView.backgroundColor = .blue
        rightShinView.backgroundColor = .clear

        leftHandAttachment = attach(topOf: leftForearmView, to: Constants.handPoint)
        rightHandAttachment = attach(topOf: rightForearmView, to: Constants.handPoint)
        attach(topOf: leftBiseptView, offsetBy: 0.0, toBottomOf: leftForearmView, range: elbowRange, friction: 0.0)
        attach(topOf: rightBiseptView, offsetBy: 0.0, toBottomOf: rightForearmView, range: elbowRange, friction: 0.0)
        attach(topOf: torsoView, offsetBy: headAndNeckLength, toBottomOf: leftBiseptView, range: shoulderRange, friction: 0.0)
        attach(topOf: torsoView, offsetBy: headAndNeckLength, toBottomOf: rightBiseptView, range: shoulderRange, friction: 0.0)
        attach(topOf: leftThighView, offsetBy: 0.0, toBottomOf: torsoView, range: hipRange, friction: 0.02)
        attach(topOf: rightThighView, offsetBy: 0.0, toBottomOf: torsoView, range: hipRange, friction: 0.02)
        attach(topOf: leftShinView, offsetBy: 0.0, toBottomOf: leftThighView, range: kneeRange, friction: 0.04)
        attach(topOf: rightShinView, offsetBy: 0.0, toBottomOf: rightThighView, range: kneeRange, friction: 0.04)
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
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        animator.removeBehavior(leftHandAttachment)
        animator.removeBehavior(rightHandAttachment)

        rightBiseptView.backgroundColor = .blue
        rightForearmView.backgroundColor = .blue
        rightThighView.backgroundColor = .blue
        rightShinView.backgroundColor = .blue
    }

    private func attach(topOf view1: UIView, to point: CGPoint) -> UIAttachmentBehavior {
        view1.center = CGPoint(x: point.x,
                               y: point.y + view1.frame.height / 2)
        limberjackBehavior.addItem(view1)
        
        let attachment = UIAttachmentBehavior(
            item: view1,
            offsetFromCenter: UIOffset(horizontal: 0, vertical: -view1.frame.height / 2),
            attachedToAnchor: point
        )
        animator.addBehavior(attachment)
        
        return attachment
    }
    
    private func attach(topOf view1: UIView,
                        offsetBy: CGFloat,
                        toBottomOf view2: UIView,
                        range: UIFloatRange,
                        friction: CGFloat) {
        
        view1.center = CGPoint(x: view2.center.x,
                               y: view2.center.y + (view2.frame.height + view1.frame.height) / 2 - offsetBy)
        limberjackBehavior.addItem(view1)
        
        let attachment = UIAttachmentBehavior.pinAttachment(
            with: view1,
            attachedTo: view2,
            attachmentAnchor: CGPoint(x: view1.center.x, y: view1.frame.origin.y + offsetBy)
        )
        attachment.frictionTorque = friction
        attachment.attachmentRange = range
        animator.addBehavior(attachment)
    }
}

