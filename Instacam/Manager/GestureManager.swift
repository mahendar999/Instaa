//
//  GestureManager.swift
//  Instacam
//
//  Created by Apple on 13/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

class GestureManager {
    static let shared = GestureManager()
    
    func addSwipeGesture(_ vw: UIView) {
        let _action = #selector(respondToSwipeGesture(_:))
        
        vw.isUserInteractionEnabled = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action: _action)
        swipeRight.direction = .right
        vw.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: _action)
        swipeDown.direction = .down
        vw.addGestureRecognizer(swipeDown)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: _action)
        swipeLeft.direction = .left
        vw.addGestureRecognizer(swipeLeft)
        
        let swipeTop = UISwipeGestureRecognizer(target: self, action: _action)
        swipeTop.direction = .up
        vw.addGestureRecognizer(swipeTop)
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            var direction: Directions!
            switch swipeGesture.direction {
            case .right:
                direction = Directions.right
                SocketIOManager.shared.sendRequest(key: SocketEvents.swipeRight, parameter: ["receiver_id": Payload.shared.streamerId!])
            case .down:
                direction = Directions.bottom
                SocketIOManager.shared.sendRequest(key: SocketEvents.swipeDown, parameter: ["receiver_id": Payload.shared.streamerId!])
            case .left:
                direction = Directions.left
                SocketIOManager.shared.sendRequest(key: SocketEvents.swipeLeft, parameter: ["receiver_id": Payload.shared.streamerId!])
            case .up:
                direction = Directions.top
                SocketIOManager.shared.sendRequest(key: SocketEvents.swipeUp, parameter: ["receiver_id": Payload.shared.streamerId!])
            default:
                break
            }
            
            NotificationCenter.default.post(name: Notification.Name("SwipeRecognizer"), object: direction)
        }
    }
    
    func addTapGesture(_ vw: UIView) {
        let _action = #selector(respondToTapGesture(_:))
        
        vw.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: _action)
        tapGesture.numberOfTapsRequired = 2
        vw.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func respondToTapGesture(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: gesture.view!)
        let deviceResolution = UIScreen.main.bounds
        
        let parameters = [
            "receiver_id": Payload.shared.streamerId!,
            "coordinateX": "\(point.x)",
            "coordinateY": "\(point.y)",
            "deviceHeight": "\(deviceResolution.height)",
            "deviceWidth": "\(deviceResolution.width)",
            "device_type": "iOS"
            ]
        
        SocketIOManager.shared.sendRequest(key: SocketEvents.dotPosition, parameter: parameters)
        NotificationCenter.default.post(name: Notification.Name("TapRecognizer"), object: point)
    }
    
}
