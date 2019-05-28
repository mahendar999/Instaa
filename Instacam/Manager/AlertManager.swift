//
//  AlertManager.swift
//  Trailer2You
//
//  Created by SIERRA on 4/6/18.
//  Copyright © 2018 GsBitLabs. All rights reserved.
//

import UIKit
import SIAlertView
import Toast_Swift

struct GPAlert {
    let title: String!
    let message: String!
}

let kColorGray74:Int    = 0xBDBDBD

class AlertManager: NSObject , UIAlertViewDelegate {
    static let shared : AlertManager = AlertManager()
    var completionBlock: ((_ selectedIndex: Int) -> Void)? = nil
    
    func addToast(_ onView: UIView, message: String, duration: TimeInterval = 3.0) {
        onView.makeToast(message.localized(), duration: duration, position: .bottom)
    }
    
    func show(_ alert: GPAlert
        , buttonsArray : [Any] = ["Ok"]
        , completionBlock : ((_ : Int) -> ())? = nil) {

        self.completionBlock = completionBlock
        
        let alertView = UIAlertController(title: alert.title.localized(), message: alert.message.localized(), preferredStyle: .alert)
        for i in 0..<buttonsArray.count {
            let buttonTitle: String = buttonsArray[i] as! String
            let btnAction = UIAlertAction(title: buttonTitle.localized(), style: .default) { (alertAction) in
                if self.completionBlock != nil {
                    self.completionBlock!(i)
                }
            }
            alertView.addAction(btnAction)
        }
        
        GNavigation.shared.present(alertView, isAnimated: true)
    }
    
    func showWithoutLocalize(_ alert: GPAlert
        , buttonsArray : [Any] = ["Ok"]
        , completionBlock : ((_ : Int) -> ())? = nil) {
        
        self.completionBlock = completionBlock
        
        let alertView = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        for i in 0..<buttonsArray.count {
            let buttonTitle: String = buttonsArray[i] as! String
            let btnAction = UIAlertAction(title: buttonTitle.localized(), style: .default) { (alertAction) in
                if self.completionBlock != nil {
                    self.completionBlock!(i)
                }
            }
            alertView.addAction(btnAction)
        }
        
        GNavigation.shared.present(alertView, isAnimated: true)
    }
    
    func showPopup(_ alert : GPAlert
        , forTime time : Double
        , completionBlock : ((_ : Int) -> ())? = nil) {
    
        self.completionBlock = completionBlock
        
        let alertView = UIAlertController(title: alert.title.localized(), message: alert.message.localized(), preferredStyle: .alert)
        GNavigation.shared.present(alertView, isAnimated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((ino64_t)(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            alertView.dismiss(animated: true)
            if completionBlock != nil {
                completionBlock!(0)
            }
        })
        
    }
    
    func showActionSheet(_ sender: UIView, alert: GPAlert, completion: @escaping ()->Void) {
        let alert = UIAlertController(title: alert.title.localized(), message: alert.message.localized(), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: { _ in
            completion()
        }))
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        self.appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
}
