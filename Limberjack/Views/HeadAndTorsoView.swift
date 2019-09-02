//
//  HeadAndTorsoView.swift
//  Limberjack
//
//  Created by Phil Stern on 8/31/19.
//  Copyright © 2019 Phil Stern. All rights reserved.
//

import UIKit

class HeadAndTorsoView: UIView {

    override func draw(_ rect: CGRect) {
        
        let headCenter = CGPoint(x: frame.width / 2, y: Constants.headRadius + Constants.lineWidth)
        let neckPoint = CGPoint(x: frame.width / 2, y: Constants.headRadius * 2 + Constants.lineWidth)
        let torsoBottom = CGPoint(x: frame.width / 2, y: frame.height)

        let circle = UIBezierPath(arcCenter: headCenter,
                                  radius: Constants.headRadius,
                                  startAngle: 0,
                                  endAngle: 2 * CGFloat.pi,
                                  clockwise: true)
        UIColor.blue.setStroke()
        circle.lineWidth = Constants.lineWidth - 0.5
        circle.stroke()
        
        let line = UIBezierPath()
        line.move(to: neckPoint)
        line.addLine(to: torsoBottom)
        line.lineWidth = Constants.lineWidth
        line.stroke()
    }
}
