//
//  UIRecordButton.swift
//  Vlogr
//
//  Created by Kenny Batista on 4/26/17.
//  Copyright © 2017 kennybatista. All rights reserved.
//

import UIKit

class UIRecordButton: UIButton {
    
    var pathLayer: CAShapeLayer?
    
    // 1. Set up the initial state of the control, do it in the setup() so that it can be called from the initializers
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.setup()
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    
    
    
    // common code setup
    
    func setup(){
        // add a shape layer to the inner shape to be able to animate it
        self.pathLayer = CAShapeLayer()
        
        
        // show the right for the current control state
        self.pathLayer?.path = self.currentInnerPath().cgPath
        
        // don't use a stroke color, which would give a ring around the inner circle
        self.pathLayer?.strokeColor = nil
        
        // set the color for the inner shape
        self.pathLayer?.fillColor = UIColor.red.cgColor
        
        // add the path layer to the control layer so it gets drawn
        self.layer.addSublayer(self.pathLayer!)
    }
    
    
    // Awake from nib gurantees that all IBOutlets are connected. So that's the perfect time to add constraints
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // let's add constraints to make sure that the button stays the same size
        // lock the size to match the size of the camera button
//        self.addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 66.0))
//        
//        self.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 66.0))
        
        // Clear the title
        self.setTitle("", for: .normal)
        
        // add out target for event handling
        self.addTarget(self, action: #selector(touchUpInside(sender:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchDown(sender:)), for: .touchDown)
        
    }
    
    
    
    // Returns the correct innerPath depending the the state
    func currentInnerPath() -> UIBezierPath {
        // choose the correct inner path based on the state
        var returnPath: UIBezierPath
        
        if self.isSelected {
             returnPath = self.innerSquarePath()
        } else {
            returnPath = self.innerCirclePath()
        }
        
        return returnPath
    }
    
    
    func innerCirclePath() -> UIBezierPath {
        // Make the corner radius the same as the radius of the circle to
    
        // Make the rectangle look like a circle
        return UIBezierPath(roundedRect: CGRect(x: 8, y: 8, width: 50, height: 50), cornerRadius: 25)
    }
    
    func innerSquarePath() -> UIBezierPath {
        //
        return UIBezierPath(roundedRect: CGRect(x: 18, y: 18, width: 30, height: 30), cornerRadius: 4)
    }
    
    
    override func draw(_ rect: CGRect) {
        
        // Always draw the outer ring, the inner control is drawn during the animations
        let outerRing = UIBezierPath(ovalIn: CGRect(x: 3, y: 3, width: 60, height: 60))
        
        outerRing.lineWidth = 6
        UIColor.white.setStroke()
        outerRing.stroke()
    }
    
    
    
    
    func touchDown(sender: UIButton){
        // when the user touches the button, the inner shape should change transparency
        // create the animation for the fill color: 
        let morph = CABasicAnimation(keyPath: "fillColor")
        morph.duration = 0.5
        
        // set the value we want to animate to 
        morph.toValue = UIColor(colorLiteralRed: 1, green: 0, blue: 0, alpha: 0.5).cgColor
        
        // ensure that the animation does not get reverted once completed
        morph.fillMode = kCAFillModeForwards
        morph.isRemovedOnCompletion = false
        
        morph.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        self.pathLayer?.add(morph, forKey: "")
        
        
        
    }
    
    
    func touchUpInside(sender: UIButton){
        // Create the animation to restore the color of the button
        let colorChange = CABasicAnimation(keyPath: "fillColor")
        colorChange.duration = 1
        colorChange.toValue = UIColor.red.cgColor
        
        // make sure that the color animation is not reverted
        colorChange.fillMode = kCAFillModeForwards
        colorChange.isRemovedOnCompletion = false
        
        // Indicate which animation timing to use, in this case ease in and ease out
        colorChange.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        // add the animation
        self.pathLayer?.add(colorChange, forKey: "darkColor")
        
        // change the state of the control to update the shape
        self.isSelected = !self.isSelected
    }
    
    
    // override the setter for the isSelected state to update the inner shape
    override var isSelected: Bool{
        didSet {
            // change the inner shape to match the state
            let morph = CABasicAnimation(keyPath: "path")
            morph.duration = 0.5
            morph.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            
            // change the shape according to the currentstate of the control 
            morph.toValue = self.currentInnerPath().cgPath
            
            // ensure that the animation is not reverted
            morph.fillMode = kCAFillModeForwards
            morph.isRemovedOnCompletion = false
            
            // add animation
            self.pathLayer?.add(morph, forKey: "")
        }
    }
    
    
    
    
    
    
    
    
}
