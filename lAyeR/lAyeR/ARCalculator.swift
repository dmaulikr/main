//
//  ARCalculator.swift
//  lAyeR
//
//  Created by 罗宇阳 on 9/3/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import CoreMotion
import Foundation
import UIKit

class ARCalculator {
    func calculateARLayoutAdjustment(motion: CMDeviceMotion, azimuth: Double, within superView: UIView) -> ARLayoutAdjustment {
        //TODO: handle different azimuth also (also elevation angle if data can be got)
        
        let rotationMatrix = motion.attitude.rotationMatrix
        let rollSin = rotationMatrix.m32
        let pitchSin = rotationMatrix.m33
        
        let m31 = rotationMatrix.m31
        let m32 = rotationMatrix.m32
        let m33 = rotationMatrix.m33
        let m21 = rotationMatrix.m21
        let m22 = rotationMatrix.m22
        let m23 = rotationMatrix.m23
        
        // STEP 1. calculate "pure" yaw angle
        
        // the horizontal vector perpendicular to the z-axis vector of the device
        let horzVectorPerpToDeviceZ = Vector3D(x: -m32, y: m31, z: 0)
        
        // the normal vector of the surface spanned by the following 2 vectors:
        // - the z-axis vector of the device
        // - horzVectorPerpToDeviceZ
        let normalVector = Vector3D(x: (m33 * m31) / (m32 * m32 + m31 * m31),
                                    y: (m33 * m32) / (m32 * m32 + m31 * m31),
                                    z: -1)
        
        let deviceY = Vector3D(x: m21, y: m22, z: m23)
        let cos = -deviceY.projectionLength(on: normalVector) / deviceY.length
        var sin = sqrt(1 - cos * cos)
        if deviceY * horzVectorPerpToDeviceZ < 0 {
            sin = -sin
        }
        
        let yawAngle = atan2(sin, cos)
        
        // STEP 2. calculate offset
        let superViewWidth = superView.bounds.width
        let superViewHeight = superView.bounds.height
        let visionWidth = superViewWidth * CGFloat(abs(cos)) + superViewHeight * CGFloat(abs(sin))
        let visionHeight = superViewWidth * CGFloat(abs(sin)) + superViewHeight * CGFloat(abs(cos))
        // positive x direction is rigth
        let horzOffset = -CGFloat(rollSin) * visionWidth
        // positive y direction is down
        let verticalOffset = CGFloat(pitchSin) * visionHeight
        
        let xOffset = CGFloat(horzOffset) * CGFloat(cos) - CGFloat(verticalOffset) * CGFloat(sin)
        let yOffset = -(CGFloat(verticalOffset) * CGFloat(cos) + CGFloat(horzOffset) * CGFloat(sin))
        
        return ARLayoutAdjustment(xOffset: xOffset, yOffset: yOffset, rotationAngle: -(CGFloat)(yawAngle))
    }
}


struct ARLayoutAdjustment {
    let xOffset: CGFloat
    let yOffset: CGFloat
    let rotationAngle: CGFloat

    func apply(to view: UIView, within superView: UIView) {
        view.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
        view.center.x = (superView.bounds.width - view.frame.width) / 2 + xOffset
        view.center.y = (superView.bounds.height - view.frame.height) / 2 + yOffset
    }
}

