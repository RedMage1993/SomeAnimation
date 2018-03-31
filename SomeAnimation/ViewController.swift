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
        
        sdIconImageView.position = CGPoint.zero
        sdIconImageView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let radius = self.view.frame.centerOrigin.x / 2
        
        UIView.animateKeyframes(withDuration: 2.5, delay: 0, options: [], animations: {
            // Fade in
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                self.sdIconImageView.alpha = 1
            }

            // Slide up
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                self.sdIconImageView.position = CGPoint(x: self.sdIconImageView.position.x, y: radius)
            }
        })
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
    func rotated(byDegrees degrees: CGFloat) -> CGAffineTransform {
        return self.rotated(by: degrees * CGFloat(Double.pi / 180))
    }
    
    var rotationInDegrees: CGFloat {
        get {
            return CGFloat(atan2f(Float(self.b), Float(self.a))) * CGFloat(180 / Double.pi)
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
    var rotationInDegrees: CGFloat {
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

