//
//  DrawManager.swift
//  Instacam
//
//  Created by Apple on 18/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    func newCoords(_ _manager: DrawPointManager, isPrint: Bool = true) -> CGPoint {
        let currentFrame = UIScreen.main.bounds
        let oldFrame = _manager.frameSize!
        let scale = UIScreen.main.scale
        
        if _manager.deviceType.lowercased() == "ios" {
            let xPoint = (currentFrame.width * (self.x/scale)) / (oldFrame.width/scale)
            let yPoint = (currentFrame.height * (self.y/scale)) / (oldFrame.height/scale)
            
            if isPrint {
                print("Other Device: coord(\(self.x,self.y)) deviceSize(\(oldFrame.width,oldFrame.height))")
                print("Other CalCulate: coord(\(self.x/scale,self.y/scale)) deviceSize(\(oldFrame.width/scale,oldFrame.height/scale))")
                print("Current Device: coord(\(xPoint,yPoint)) deviceSize(\(currentFrame.width,currentFrame.height))")
            }
            
            return CGPoint(x: xPoint, y: yPoint)
        }else{
            let xPoint = (currentFrame.width * self.x) / oldFrame.width
            let yPoint = (currentFrame.height * self.y) / oldFrame.height
            
            if isPrint {
                print("Other Device: coord(\(self.x,self.y)) deviceSize(\(oldFrame.width,oldFrame.height))")
                print("Current Device: coord(\(xPoint,yPoint)) deviceSize(\(currentFrame.width,currentFrame.height))")
            }
            
            return CGPoint(x: xPoint, y: yPoint)
        }
        
    }
}

extension UIBezierPath {
    convenience init(_manager:DrawPointManager)
    {
        self.init()
        
        //connect every points by line.
        //the first point is start point
        for (index,aPoint) in _manager.arrCGPoints.enumerated()
        {
            let newPoint = aPoint.newCoords(_manager)
            if index == 0 {
                self.move(to: newPoint)
            }
            else {
                self.addLine(to: newPoint)
            }
        }
    }
    
}

class DrawingView: UIView , CAAnimationDelegate {
    
    var drawColor = UIColor.red
    var lineWidth: CGFloat = 8
    
    private var lastPoint: CGPoint!
    private var bezierPath: UIBezierPath!
    private var arrPoints: [CGPoint] = []
    private var arrPointsLayer: [CAShapeLayer] = []
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initBezierPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initBezierPath()
    }
    
    func initBezierPath() {
        bezierPath = UIBezierPath()
        bezierPath.lineCapStyle = CGLineCap.round
        bezierPath.lineJoinStyle = CGLineJoin.round
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
    }
    
    func drawPath(_ manager: DrawPointManager) {
        self.bezierPath = UIBezierPath(_manager: manager)
        let layer = CAShapeLayer()
        layer.path = self.bezierPath.cgPath
        layer.lineWidth = self.lineWidth
        layer.strokeColor = self.drawColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(layer)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
            self.bezierPath.removeAllPoints()
        }
    }
    
    // MARK: - Touch handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isHidden = false
        let touch: AnyObject? = touches.first
        lastPoint = touch!.location(in: self)
        arrPoints.append(lastPoint)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject? = touches.first
        let newPoint = touch!.location(in: self)
        
        bezierPath.move(to: lastPoint)
        bezierPath.addLine(to: newPoint)
        lastPoint = newPoint
        arrPoints.append(lastPoint)
        
        setNeedsDisplay()
    }
    
    func addAnimatedLayer() {
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = self.drawColor.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.strokeStart = 0.8
        
        let startAnimation = CABasicAnimation(keyPath: "strokeStart")
        startAnimation.fromValue = 0
        startAnimation.toValue = 0.8
        
        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.fromValue = 0.2
        endAnimation.toValue = 1.0
        
        let animation = CAAnimationGroup()
        animation.animations = [startAnimation, endAnimation]
        animation.duration = 2
        shapeLayer.add(animation, forKey: "MyAnimation")
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 3.0, animations: {
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: {
                self.setNeedsDisplay()
                self.bezierPath.removeAllPoints()
            })
            self.layoutIfNeeded()
        }) { (completion) in
            let deviceResolution = UIScreen.main.bounds
            let scale: CGFloat = UIScreen.main.scale
            
            var parameter: Dictionary<String, Any>  = ["receiver_id": Payload.shared.streamerId!]
            
            var arrCoords: [Dictionary<String, String>] = []
            for point in self.arrPoints {
                let coord = ["x": "\(point.x*scale)", "y": "\(point.y*scale)"]
                arrCoords.append(coord)
            }
            
            parameter["coordinates"] = arrCoords
            parameter["device_height"] = "\(deviceResolution.height*scale)"
            parameter["device_width"] = "\(deviceResolution.width*scale)"
            parameter["device_type"] = "iOS"
            
            SocketIOManager.shared.sendRequest(key: SocketEvents.drawPosition, parameter: parameter)
            self.arrPoints.removeAll()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        touchesEnded(touches!, with: event)
    }
    
    // MARK: - Render
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        bezierPath.lineWidth = lineWidth
        drawColor.setFill()
        drawColor.setStroke()
        bezierPath.stroke()
    }
    
    // MARK: - Clearing
    
    func clear() {
        bezierPath.removeAllPoints()
        setNeedsDisplay()
    }
    
    // MARK: - Other
    
    func hasLines() -> Bool {
        return !bezierPath.isEmpty
    }
    
}
