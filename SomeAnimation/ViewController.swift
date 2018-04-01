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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start at origin of superview
        sdIconImageView.position = CGPoint.zero
        // Start transparently
        sdIconImageView.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // This is the radius of the circle we will be moving around from the center
        let radius = Double(view.frame.centerOrigin.x / 2)
        
        // Since we animate a slide up by radius amount, we know that we will be at
        // sin(90) * radius == 1 * radius
        var degrees = 90.0
        
        UIView.animateKeyframes(withDuration: 2.5, delay: 0, options: [], animations: {
            // Fade in
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                self.sdIconImageView.alpha = 1.0
            }

            // Slide up
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                self.sdIconImageView.transform = self.sdIconImageView.transform.translatedBy(x: 0, y: CGFloat(-radius))
            }
        }){ _ in

            // Main animation moving the center of image around a circle
            // defined by trigonemetric function sin(x) + cos(x) = radius.
            // Performing a rotation, and scale.
            let _ = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                let radians = degrees * Double.pi / 180
                let position = CGPoint(x: radius * cos(radians), y: radius * sin(radians))
                var transform = CGAffineTransform.identity
                
                transform = transform.translatedBy(x: position.x, y: -position.y)
                
                if degrees >= 180 && degrees < 270 {
                    // Normalization represents progress from 180 to 270 (this will be a value between 0 and 1)
                    let progress = (degrees - 180) / (269 - 180)
                    let scaling = 1 - 0.5 * progress // We want to shrink to half size but only by a multiplier of progress
                    transform = transform.scaledBy(x: CGFloat(scaling), y: CGFloat(scaling))
                } else if degrees >= 270 && degrees < 360 {
                    let progress = (degrees - 270) / (359 - 270)
                    let scaling = 0.5 + 0.5 * progress // We want to grow from half size back to full size (by progress)
                    let rotation = 2 * Double.pi * progress // Will perform 360 == 2 * 180 = 2 * 3.14 rotation (by progress)

                    transform = transform.rotated(by: CGFloat(rotation))
                    transform = transform.scaledBy(x: CGFloat(scaling), y: CGFloat(scaling))
                }
                
                self.sdIconImageView.transform = transform
                
                degrees += 1
                if degrees >= 360 {
                    degrees = 0.0
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

