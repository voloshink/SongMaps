//
//  FluidBackgroundView.swift
//  SongMaps
//
//  Created by Polecat on 11/12/19.
//  Copyright © 2019 Polecat. All rights reserved.
//

import UIKit

class FluidBackgroundView: UIView {
    
    var gradientLayer = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    
    var delayedGradientUpdate: [[CGColor]]?
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setupView()
    }
    
    private func setupView() {
        gradientSet.append([UIColor.orange.cgColor, UIColor.blue.cgColor])
        gradientSet.append([UIColor.blue.cgColor, UIColor.orange.cgColor])
        
        
        gradientLayer.frame = bounds
        gradientLayer.colors = gradientSet[currentGradient]
        gradientLayer.startPoint = CGPoint(x:0, y:0)
        gradientLayer.endPoint = CGPoint(x:1, y:1)
        gradientLayer.drawsAsynchronously = true
        layer.insertSublayer(gradientLayer, at: 0)
        
        animateGradient()
    }
    
    private func animateGradient() {
        currentGradient = nextGradientIndex(from: currentGradient)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.duration = 2.0
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientChangeAnimation.delegate = self
        gradientLayer.add(gradientChangeAnimation, forKey: "colorChange")
        
        if var update = delayedGradientUpdate {
            gradientSet[nextGradientIndex(from: currentGradient)] = update.removeFirst()
            delayedGradientUpdate = update
            if update.count == 0 {
                delayedGradientUpdate = nil
            }
        }
    }
    
    private func nextGradientIndex(from: Int) -> Int {
        if from < gradientSet.count - 1 {
            return currentGradient + 1
        } else {
            return 0
        }
    }
    
    func updateGradient(with color: UIColor, followed by: UIColor) {
        let currentSet = gradientSet[currentGradient]
        let nextIndex = nextGradientIndex(from:currentGradient)
        gradientSet[nextIndex] = [currentSet[1], color.cgColor]
        delayedGradientUpdate = [[color.cgColor, by.cgColor], [by.cgColor, color.cgColor]]
    }
}

extension FluidBackgroundView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradientLayer.colors = gradientSet[currentGradient]
            animateGradient()
        }
    }
}
