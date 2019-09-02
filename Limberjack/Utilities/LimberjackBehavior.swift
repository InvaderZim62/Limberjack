//
//  LimberjackBehavior.swift
//  Limberjack
//
//  Created by Phil Stern on 8/30/19.
//  Copyright © 2019 Phil Stern. All rights reserved.
//

import UIKit

class LimberjackBehavior: UIDynamicBehavior {
    
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true  // bounce off edges of screen
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = 0.7
        behavior.resistance = 0.5
        return behavior
    }()
    
    lazy var gravityBehavior: UIGravityBehavior = {
        let behavior = UIGravityBehavior()
        behavior.magnitude = 1.0
        return behavior
    }()
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        gravityBehavior.addItem(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
        gravityBehavior.removeItem(item)
    }

    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
        addChildBehavior(gravityBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
