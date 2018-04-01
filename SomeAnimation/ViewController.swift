//
//  ViewController.swift
//  SomeAnimation
//
//  Created by Fritz Ammon on 3/31/18.
//  Copyright © 2018 Ammon. All rights reserved.
//

import UIKit

@IBDesignable
class ViewController: UIViewController {
    @IBOutlet weak var sdIconImageView: CustomImageView!
    
    var radius: Double = 1
    var degrees: Double = 90
    var animationTimer: Timer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sdIconImageView.position = CGPoint.zero
        sdIconImageView.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        radius = Double(view.frame.centerOrigin.x / 2)
        
        UIView.animateKeyframes(withDuration: 2.5, delay: 0, options: [], animations: {
            // Fade in
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                self.sdIconImageView.alpha = 1.0
            }

            // Slide up
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                //self.sdIconImageView.position = CGPoint(x: Double(self.sdIconImageView.position.x), y: self.radius)
                self.sdIconImageView.transform = self.sdIconImageView.transform.translatedBy(x: 0, y: CGFloat(-self.radius))
            }
        }){ _ in

            // Main animation
            self.animationTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                let radians = self.degrees * Double.pi / 180
                let position = CGPoint(x: self.radius * cos(radians), y: self.radius * sin(radians))
                var transform = CGAffineTransform.identity
                
                //self.sdIconImageView.position = CGPoint(x: position.x, y: position.y)
                transform = transform.translatedBy(x: -position.x, y: -position.y)
                
                if self.degrees >= 180 && self.degrees < 270 {
                    // Normalization represents progress from 180 to 270
                    let progress = (self.degrees - 180) / (269 - 180)
                    let scaling = 1 - 0.5 * progress
                    transform = transform.scaledBy(x: CGFloat(scaling), y: CGFloat(scaling))
                } else if self.degrees >= 270 && self.degrees < 360 {
                    let progress = (self.degrees - 270) / (359 - 270)
                    let scaling = 0.5 + 0.5 * progress
                    let rotation = 2 * Double.pi * progress

                    transform = transform.rotated(by: CGFloat(rotation))
                    transform = transform.scaledBy(x: CGFloat(scaling), y: CGFloat(scaling))
                }
                
                self.sdIconImageView.transform = transform
                
                self.degrees += 1
                if self.degrees >= 360 {
                    self.degrees = 0.0
                }
            }
        }
    }
}

extension CGRect {
    var center: CGPoint {
        get {
            return CGPoint(x: width / 2, y: height / 2)
        }
    }
    
    var centerOrigin: CGPoint {
        get {
            return CGPoint(x: origin.x + center.x, y: origin.y + center.y)
        }
    }
}

extension CGAffineTransform {
    func rotated(byDegrees degrees: Double) -> CGAffineTransform {
        return self.rotated(by: CGFloat(degrees * (Double.pi / 180.0)))
    }
    
    var rotationInDegrees: Double {
        get {
            return atan2(Double(self.b), Double(self.a)) * (180.0 / Double.pi)
        }
    }
}

@IBDesignable
class CustomImageView: UIImageView {
    @IBInspectable
    var position: CGPoint {
        get {
            guard let _superview = superview else { return CGPoint.zero }
            
            return CGPoint(
                x: frame.centerOrigin.x - _superview.frame.centerOrigin.x,
                y: _superview.frame.centerOrigin.y - frame.centerOrigin.y
            )
        }
        
        set {
            guard let _superview = superview else { return }
            
            frame = CGRect(
                origin: CGPoint(
                    x: _superview.frame.centerOrigin.x + newValue.x - frame.center.x,
                    y: _superview.frame.centerOrigin.y - newValue.y - frame.center.y
                ),
                size: frame.size
            )
        }
    }
    
    @IBInspectable
    var translation: CGPoint {
        get {
            return CGPoint(x: transform.tx, y: -transform.ty)
        }
        
        set {
            transform = transform.translatedBy(x: newValue.x, y: -newValue.y)
        }
    }
    
    @IBInspectable
    var rotationInDegrees: Double {
        get {
            return transform.rotationInDegrees
        }
        
        set {
            transform = transform.rotated(byDegrees: newValue)
        }
    }
    
    @IBInspectable
    var scaling: CGPoint {
        get {
            return CGPoint(x: transform.a, y: transform.d)
        }
        
        set {
            transform = transform.scaledBy(x: newValue.x, y: newValue.y)
        }
    }
}

