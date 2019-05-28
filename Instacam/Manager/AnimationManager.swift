//
//  AnimationManager.swift
//  Instacam
//
//  Created by Apple on 13/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

enum Directions {
    case left
    case right
    case top
    case bottom
}

enum UserType {
    case streamer
    case viewer
}

class AnimationManager {
    static let shared = AnimationManager()
    var arrEvents: [Directions] = []
    var arrLocalAnimations: [Directions] = []
}

extension UIImageView {
    
//    func completionHandler() {
//        let manager = AnimationManager.shared.arrEvents
//        if manager.count > 0 {
//            switch manager[0]{
//            case .bottom:
//                self.moveDown()
//                break
//            case .left:
//                self.moveLeft()
//                break
//            case .top:
//                self.moveUp()
//                break
//            case .right:
//                self.moveRight()
//                break
//            }
//        }
//    }
    
    func moveLeft(_ userType: UserType) {
        if userType == .streamer {
            guard (AnimationManager.shared.arrEvents.count == 0) else { return }
            AnimationManager.shared.arrEvents.append(.left)
        }else{
            guard (AnimationManager.shared.arrLocalAnimations.count == 0) else { return }
            AnimationManager.shared.arrLocalAnimations.append(.left)
        }
        
        self.image = userType == .streamer ? UIImage(named: "s_back") : UIImage(named: "ic_swipeLR")
        self.alpha = 1
        let xposition = (UIScreen.main.bounds.size.width/2 - self.frame.size.width/2)
        self.frame.origin.x = (UIScreen.main.bounds.size.width/2 - self.frame.size.width/2)
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseOut], animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: -xposition , y: 0)
            self.layoutIfNeeded()
        },  completion: {(_ finished: Bool) -> Void in
            self.setCurrentPosition(userType)
        })
    }
    
    func moveRight(_ userType: UserType) {
        if userType == .streamer {
            guard (AnimationManager.shared.arrEvents.count == 0) else { return }
            AnimationManager.shared.arrEvents.append(.right)
        }else{
            guard (AnimationManager.shared.arrLocalAnimations.count == 0) else { return }
            AnimationManager.shared.arrLocalAnimations.append(.right)
        }
        
        self.image = userType == .streamer ? UIImage(named: "s_next") : UIImage(named: "ic_swipeLR")
        self.alpha = 1
        let xposition = (UIScreen.main.bounds.size.width/2 - self.frame.size.width/2)
        self.frame.origin.x = (UIScreen.main.bounds.size.width/2 - self.frame.size.width/2)
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseOut], animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: xposition , y: 0)
            self.layoutIfNeeded()
        },  completion: {(_ finished: Bool) -> Void in
            self.setCurrentPosition(userType)
        })
    }
    
    func moveDown(_ userType: UserType) {
        if userType == .streamer {
            guard (AnimationManager.shared.arrEvents.count == 0) else { return }
            AnimationManager.shared.arrEvents.append(.bottom)
        }else{
            guard (AnimationManager.shared.arrLocalAnimations.count == 0) else { return }
            AnimationManager.shared.arrLocalAnimations.append(.bottom)
        }
        
        self.image = userType == .streamer ? UIImage(named: "s_down") : UIImage(named: "ic_swipeTD")
        self.alpha = 1
        let yPosition = (UIScreen.main.bounds.size.height/2 - self.frame.size.height/2)
        self.frame.origin.y = (UIScreen.main.bounds.size.height/2 - self.frame.size.height/2)
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseOut], animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0 , y: yPosition)
            self.layoutIfNeeded()
        },  completion: {(_ finished: Bool) -> Void in
            self.setCurrentPosition(userType)
        })
    }
    
    func moveUp(_ userType: UserType) {
        if userType == .streamer {
            guard (AnimationManager.shared.arrEvents.count == 0) else { return }
            AnimationManager.shared.arrEvents.append(.top)
        }else{
            guard (AnimationManager.shared.arrLocalAnimations.count == 0) else { return }
            AnimationManager.shared.arrLocalAnimations.append(.top)
        }
        
        
        self.image = userType == .streamer ? UIImage(named: "s_up") : UIImage(named: "ic_swipeTD")
        self.alpha = 1
        let yPosition = (UIScreen.main.bounds.size.height/2 - self.frame.size.height/2)
        self.frame.origin.y = (UIScreen.main.bounds.size.height/2 - self.frame.size.height/2)
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseOut], animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0 , y: -yPosition)
            self.layoutIfNeeded()
        },  completion: {(_ finished: Bool) -> Void in
            self.setCurrentPosition(userType)
        })
    }
    
    func setCurrentPosition(_ userType: UserType) {
        self.alpha = 0
        if userType == .streamer {
            if AnimationManager.shared.arrEvents.count > 0 {
                AnimationManager.shared.arrEvents.removeAll()
            }
        }else{
            if AnimationManager.shared.arrLocalAnimations.count > 0 {
                AnimationManager.shared.arrLocalAnimations.removeAll()
            }
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
            self.transform = CGAffineTransform(translationX: 0 , y: 0)
            self.layoutIfNeeded()
        },  completion: {(_ finished: Bool) -> Void in
        })
    }
    
}

extension UIView {
    func addPointer(_ point: CGPoint, deviceSize: CGSize, userType: UserType) {
        let imgView = UIImageView()
        if userType == .streamer {
            let scale = UIScreen.main.scale
            let calculatedWidth = deviceSize.width
            let calculatedHeight = deviceSize.height
            
            let currentDeviceSize = UIScreen.main.bounds.size
            let cx = (currentDeviceSize.width / calculatedWidth) * point.x
            let cy = (currentDeviceSize.height / calculatedHeight) * point.y
            
            imgView.frame = CGRect(x: cx-45, y: cy-45, width: 90, height: 90)
        }else{
            imgView.frame = CGRect(x: point.x-45, y: point.y-45, width: 90, height: 90)
        }
        
        imgView.image = UIImage(named: "pointer")
        self.addSubview(imgView)
        
        imgView.alpha = 1.0
        UIView.animate(withDuration: 3.0, animations: {
            imgView.alpha = 0
            imgView.layoutIfNeeded()
        })
    }
    
}

