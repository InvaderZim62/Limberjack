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
    static let barPoint = CGPoint(x: 190, y: 250)  // in animator's reference view coordinates
    static let barRadius = CGFloat(4)
    static let lineWidth = CGFloat(3)
    static let headRadius = CGFloat(8)
    static let neckLength = CGFloat(12)
    static let handLength = CGFloat(8)
    static let forearmLength = CGFloat(30)
    static let bicepsLength = CGFloat(30)
    static let torsoLength = CGFloat(80)
    static let thighLength = CGFloat(45)
    static let shinLength = CGFloat(45)
}

class LimberjackViewController: UIViewController, UICollisionBehaviorDelegate {
    
    var falling = false
    var freeOfBar = false
    
    var leftHandAttachment: UIAttachmentBehavior!
    var rightHandAttachment: UIAttachmentBehavior!

    let headAndNeckLength = Constants.headRadius * 2 + Constants.neckLength
    
    let wristRange = UIFloatRange(minimum: -1.0, maximum: 1.0)
    let elbowRange = UIFloatRange(minimum: 0.0, maximum: 2.0)
    let shoulderRange = UIFloatRange(minimum: -CGFloat.pi, maximum: CGFloat.pi)
    let hipRange = UIFloatRange(minimum: -2.8, maximum: 1.0)  // radians, min is forward bend, max is backward bend
    let kneeRange = UIFloatRange(minimum: 0.0, maximum: 2.0)

    let barView = BarView(frame: CGRect(x: 0, y: 0,
                                        width: (Constants.barRadius + Constants.lineWidth) * 2,
                                        height: (Constants.barRadius + Constants.lineWidth) * 2))
    let leftHandView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.handLength))
    let rightHandView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.handLength))
    let leftForearmView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.forearmLength))
    let rightForearmView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.forearmLength))
    let leftBicepsView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.bicepsLength))
    let rightBicepsView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.bicepsLength))
    let torsoView = HeadAndTorsoView(frame: CGRect(x: 0, y: 0,
                                                   width: (Constants.headRadius + Constants.lineWidth) * 2,
                                                   height: Constants.torsoLength))
    let leftThighView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.thighLength))
    let rightThighView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.thighLength))
    let leftShinView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.shinLength))
    let rightShinView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.shinLength))

    let motionManager = CMMotionManager()  // needed for accelerometers
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var limberjackBehavior = LimberjackBehavior(in: animator)
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
        
        barView.center = Constants.barPoint
        barView.backgroundColor = .clear
        view.addSubview(barView)
        
        addSubviews()
        setBackgroundColors()  // hide right limbs when hanging on bar
        createAttachments()

        limberjackBehavior.collisionBehavior.translatesReferenceBoundsIntoBoundary = false  // don't collide with walls while hanging
        limberjackBehavior.collisionBehavior.collisionDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // use accelerometers to determine direction of gravity
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                if let x = data?.acceleration.x, let y = data?.acceleration.y {
                    self.limberjackBehavior.gravityBehavior.gravityDirection = CGVector(dx: x, dy: -y)
                    // note: if you want to change gravityBehavior.magnitude, it has to be after
                    // gravityDirection is set, or by scaling the accels going into gravityDirection
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopAccelerometerUpdates()
    }

    // MARK: - Gestures

    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        if freeOfBar {
            reattachToBar()
        } else {
            // let go of bar
            animator.removeBehavior(leftHandAttachment)
            animator.removeBehavior(rightHandAttachment)
            falling = true
            
            // once falling, make bar region collidable
            let circle = UIBezierPath(arcCenter: barView.center,
                                      radius: Constants.barRadius,
                                      startAngle: 0.0,
                                      endAngle: 2.0 * CGFloat.pi,
                                      clockwise: true)
            limberjackBehavior.collisionBehavior.addBoundary(withIdentifier: NSString("bar"), for: circle)
            
            // once falling, make all body parts collidable with walls (animator reference view)
            limberjackBehavior.collisionBehavior.translatesReferenceBoundsIntoBoundary = true
            
            // make all limbs visible
            leftHandView.backgroundColor = .blue
            leftForearmView.backgroundColor = .blue
            leftBicepsView.backgroundColor = .blue
            rightHandView.backgroundColor = .blue
            rightForearmView.backgroundColor = .blue
            rightBicepsView.backgroundColor = .blue
            rightThighView.backgroundColor = .blue
            rightShinView.backgroundColor = .blue
        }
    }
    
    // MARK: - Helper Functions

    private func addSubviews() {
        view.addSubview(leftHandView)
        view.addSubview(rightHandView)
        view.addSubview(leftForearmView)
        view.addSubview(rightForearmView)
        view.addSubview(leftBicepsView)
        view.addSubview(rightBicepsView)
        view.addSubview(torsoView)
        view.addSubview(leftThighView)
        view.addSubview(rightThighView)
        view.addSubview(leftShinView)
        view.addSubview(rightShinView)
    }
    
    private func setBackgroundColors() {
        leftHandView.backgroundColor = .blue
        rightHandView.backgroundColor = .clear  // hide right limbs, until falling
        leftForearmView.backgroundColor = .blue
        rightForearmView.backgroundColor = .clear
        leftBicepsView.backgroundColor = .blue
        rightBicepsView.backgroundColor = .clear
        torsoView.backgroundColor = .clear
        leftThighView.backgroundColor = .blue
        rightThighView.backgroundColor = .clear
        leftShinView.backgroundColor = .blue
        rightShinView.backgroundColor = .clear
    }
    
    private func createAttachments() {
        leftHandAttachment = attach(topOf: leftHandView, to: Constants.barPoint)
        rightHandAttachment = attach(topOf: rightHandView, to: Constants.barPoint)
        attach(topOf: leftForearmView, offsetBy: 0.0, toBottomOf: leftHandView, range: wristRange, friction: 0.0)
        attach(topOf: rightForearmView, offsetBy: 0.0, toBottomOf: rightHandView, range: wristRange, friction: 0.0)
        attach(topOf: leftBicepsView, offsetBy: 0.0, toBottomOf: leftForearmView, range: elbowRange, friction: 0.0)
        attach(topOf: rightBicepsView, offsetBy: 0.0, toBottomOf: rightForearmView, range: elbowRange, friction: 0.0)
        attach(topOf: torsoView, offsetBy: headAndNeckLength, toBottomOf: leftBicepsView, range: shoulderRange, friction: 0.0)
        attach(topOf: torsoView, offsetBy: headAndNeckLength, toBottomOf: rightBicepsView, range: shoulderRange, friction: 0.0)
        attach(topOf: leftThighView, offsetBy: 0.0, toBottomOf: torsoView, range: hipRange, friction: 0.02)
        attach(topOf: rightThighView, offsetBy: 0.0, toBottomOf: torsoView, range: hipRange, friction: 0.02)
        attach(topOf: leftShinView, offsetBy: 0.0, toBottomOf: leftThighView, range: kneeRange, friction: 0.04)
        attach(topOf: rightShinView, offsetBy: 0.0, toBottomOf: rightThighView, range: kneeRange, friction: 0.04)
    }
    
    private func reattachToBar() {
        falling = false
        freeOfBar = false
        limberjackBehavior.collisionBehavior.removeBoundary(withIdentifier: NSString("bar"))
        limberjackBehavior.collisionBehavior.translatesReferenceBoundsIntoBoundary = false
        animator.addBehavior(leftHandAttachment)
        animator.addBehavior(rightHandAttachment)
        leftHandAttachment.length = 2
        rightHandAttachment.length = 2
        // hide right limbs
        rightHandView.backgroundColor = .clear
        rightForearmView.backgroundColor = .clear
        rightBicepsView.backgroundColor = .clear
        rightThighView.backgroundColor = .clear
        rightShinView.backgroundColor = .clear
    }

    private func attach(topOf view1: UIView, to point: CGPoint) -> UIAttachmentBehavior {
        view1.center = CGPoint(x: point.x,
                               y: point.y + view1.bounds.midY)
        limberjackBehavior.addItem(view1)
        
        let attachment = UIAttachmentBehavior(
            item: view1,
            offsetFromCenter: UIOffset(horizontal: 0, vertical: -view1.bounds.midY),
            attachedToAnchor: point
        )
        animator.addBehavior(attachment)
        
        return attachment
    }
    
    private func attach(topOf view1: UIView, offsetBy: CGFloat, toBottomOf view2: UIView,
                        range: UIFloatRange, friction: CGFloat) {
        
        view1.center = CGPoint(x: view2.center.x,
                               y: view2.center.y + view2.bounds.midY + view1.bounds.midY - offsetBy)
        limberjackBehavior.addItem(view1)
        
        // pinAttachment is the only kind that has frictionTorque and attachmentRange properties
        let attachment = UIAttachmentBehavior.pinAttachment(
            with: view1, attachedTo: view2,
            attachmentAnchor: CGPoint(x: view1.center.x, y: view1.frame.origin.y + offsetBy)
        )
        attachment.frictionTorque = friction
        attachment.attachmentRange = range  // relative rotational range in radians
        animator.addBehavior(attachment)
    }

    // MARK: - UICollisionBehaviorDelegate
    
    // called at end of each contact, including after beginning to fall, when hand
    // is finally beyond contact zone around bar
    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        if falling { freeOfBar = true }
    }
    
    // called when any part of body contacts edges of screen or zone around bar
    // note: this is called several times when body begins to fall away from bar
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        if freeOfBar {
            if let id = identifier as? NSString, id == "bar" {
                if let contactor = item as? UIView {
                    if contactor == leftHandView || contactor == rightHandView {
                        reattachToBar()
                    }
                }
            }
        }
    }
}

