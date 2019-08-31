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
    static let attachmentPoint = CGPoint(x: 200, y: 250)  // relative to animator's reference view
    static let viewWidth = CGFloat(4)
    static let viewHeight = CGFloat(150)
}

class LimberjackViewController: UIViewController {
    
    let barView = UIView(frame: CGRect(x: Constants.attachmentPoint.x - Constants.viewWidth / 2,
                                       y: Constants.attachmentPoint.y,
                                       width: Constants.viewWidth,
                                       height: Constants.viewHeight))
    
    let blockView = UIView(frame: CGRect(x: 50, y: 320, width: 20, height: 20))
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(behavior)
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = 0.7
        behavior.resistance = 0
        animator.addBehavior(behavior)
        return behavior
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        blockView.backgroundColor = .black
        view.addSubview(blockView)
        
        barView.backgroundColor = .red
        view.addSubview(barView)
        
        collisionBehavior.addItem(barView)
        collisionBehavior.addItem(blockView)
        itemBehavior.addItem(barView)

        let attachment = UIAttachmentBehavior(item: barView,
                                              offsetFromCenter: UIOffset(horizontal: 0, vertical: -Constants.viewHeight / 2),
                                              attachedToAnchor: Constants.attachmentPoint)
        animator.addBehavior(attachment)
        
        let push = UIPushBehavior(items: [blockView], mode: .instantaneous)
        push.angle = 0
        push.magnitude = 0.1
        push.action = { [unowned push] in
            push.dynamicAnimator?.removeBehavior(push)
        }
        animator.addBehavior(push)
    }
}

