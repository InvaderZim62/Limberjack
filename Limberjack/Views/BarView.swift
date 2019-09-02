//
//  BarView.swift
//  Limberjack
//
//  Created by Phil Stern on 9/1/19.
//  Copyright © 2019 Phil Stern. All rights reserved.
//

import UIKit

class BarView: UIView {

    override func draw(_ rect: CGRect) {
        
        let frameCenter = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)

        let circle = UIBezierPath(arcCenter: frameCenter,
                                  radius: Constants.barRadius,
                                  startAngle: 0.0,
                                  endAngle: 2.0 * CGFloat.pi,
                                  clockwise: true)
        UIColor.black.setFill()
        circle.fill()
    }
}
