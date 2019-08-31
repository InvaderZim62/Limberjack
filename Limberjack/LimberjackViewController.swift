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
    static let attachmentPoint = CGPoint(x: 190, y: 200)  // relative to animator's reference view
    static let viewWidth = CGFloat(4)
    static let viewHeight = CGFloat(150)
}

class LimberjackViewController: UIViewController {
    
    let bar1View = UIView(frame: CGRect(x: Constants.attachmentPoint.x - Constants.viewWidth / 2,
                                        y: Constants.attachmentPoint.y,
                                        width: Constants.viewWidth,
                                        height: Constants.viewHeight))
    let bar2View = UIView(frame: CGRect(x: 0, y: 0,width: Constants.viewWidth, height: Constants.viewHeight))

    let motionManager = CMMotionManager()  // needed to access accelerometers
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var limberjackBehavior = LimberjackBehavior(in: animator)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bar1View.backgroundColor = .red
        view.addSubview(bar1View)
        limberjackBehavior.addItem(bar1View)

        let attachment1 = UIAttachmentBehavior(item: bar1View,
                                              offsetFromCenter: UIOffset(horizontal: 0, vertical: -Constants.viewHeight / 2),
                                              attachedToAnchor: Constants.attachmentPoint)
        animator.addBehavior(attachment1)
        
        bar2View.backgroundColor = .red
        bar2View.center = CGPoint(x: bar1View.center.x, y: bar1View.center.y + bar2View.frame.height)
        view.addSubview(bar2View)
        limberjackBehavior.addItem(bar2View)

        let attachment2 = UIAttachmentBehavior(item: bar2View,
                                               offsetFromCenter: UIOffset(horizontal: 0, vertical: -Constants.viewHeight / 2),
                                               attachedTo: bar1View,
                                               offsetFromCenter: UIOffset(horizontal: 0, vertical: Constants.viewHeight / 2))
        animator.addBehavior(attachment2)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // use accelerometers to determine direction of gravity
        if motionManager.isAccelerometerAvailable {
            limberjackBehavior.gravityBehavior.magnitude = 1.0
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                if var x = data?.acceleration.x, var y = data?.acceleration.y {
                    switch UIDevice.current.orientation {
                    case .portrait: y *= -1
                    case .portraitUpsideDown: break
                    case .landscapeRight: swap(&x, &y)
                    case .landscapeLeft: swap(&x, &y); y *= -1
                    default: x = 0; y = 0;
                    }
                    self.limberjackBehavior.gravityBehavior.gravityDirection = CGVector(dx: x, dy: y)
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

