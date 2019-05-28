//
//  GFunction.swift
//  Trailer2You
//
//  Created by SIERRA on 4/6/18.
//  Copyright © 2018 GsBitLabs. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import CoreLocation
import SWRevealViewController

enum TokenType {
    case voip
    case standard
}

class GFunction: NSObject  {
    
    static let shared   : GFunction = GFunction()
    
    var indicatorView   : UIActivityIndicatorView = UIActivityIndicatorView()
    var activityLoader = ActivityData(size: CGSize(width: 45, height: 45)
        , messageFont: UIFont.applyRegular(fontSize: 14.0)
        , type: NVActivityIndicatorType.ballPulse
        , color: UIColor.lightGray
        , textColor: UIColor.lightGray)

    //------------------------------------------------------
    //MARK:- Loader Method
    
    func addLoader(_ message : String?) {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(self.activityLoader, nil)
        if let _ = message {
            NVActivityIndicatorPresenter.sharedInstance.setMessage(message)
        }
    }
    
    func changeLoaderMessage(_ message : String) {
        NVActivityIndicatorPresenter.sharedInstance.setMessage(message)
    }
    
    func removeLoader() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
    }
    
    //------------------------------------------------------
    
    //MARK: - UIACtivityIndicator
    
    func addActivityIndicator(view : UIView) {
        
        removeActivityIndicator()
        
        indicatorView = UIActivityIndicatorView(style: .gray)
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.color = UIColor.white
        view.addSubview(indicatorView)
        
        let horizontalConstraint = NSLayoutConstraint(item: indicatorView,
                                                      attribute: .centerX,
                                                      relatedBy: .equal,
                                                      toItem: view,
                                                      attribute: .centerX,
                                                      multiplier: 1,
                                                      constant: 0)
        view.addConstraint(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint(item: indicatorView,
                                                    attribute: .centerY,
                                                    relatedBy: .equal,
                                                    toItem: view,
                                                    attribute: .centerY,
                                                    multiplier: 1,
                                                    constant: 0)
        view.addConstraint(verticalConstraint)
    }
    
    func checkForProfileCompletePresent() -> Bool {
        let isProfileCreated = (GConstant.UserData.isProfileCreated == "0") || (GConstant.UserData.isProfileCreated == "")

        if GConstant.UserData != nil && isProfileCreated {
            GNavigation.shared.NavigationController.dismiss(animated: false, completion: nil)
            let vc = self.instantiateVC(with: GVCIdentifier.completeProfile) as! VCCompleteProfile
            vc.isProfileCompleted = true
            GNavigation.shared.push(vc, isAnimated: true)
            GConstant.isCompleteProfilePresent = true
            return true
        }else{
            return false
        }
    }
    
    func checkForPaymentGatewayPresent() -> Bool {
        let isProfileCreated = GConstant.UserData != nil && (GConstant.UserData.stripeCustomerId == nil || GConstant.UserData.stripeCustomerId!.count == 0 || GConstant.UserData.stripeCustomerId! == "0")
        
        if  isProfileCreated {
            let vc = self.instantiateVC(with: GVCIdentifier.payment) as! VCPayments
            vc.isPaymentCompleted = true
            GNavigation.shared.push(vc, isAnimated: true)
            return true
        }else{
            return false
        }
    }
    
    func checkForStreamerPaymentGatewayPresent() -> Bool {
        let isProfileCreated = GConstant.UserData != nil && (GConstant.UserData.stripeAccountId == nil || GConstant.UserData.stripeAccountId!.count == 0 || GConstant.UserData.stripeAccountId! == "0")
        
        if  isProfileCreated {
            GNavigation.shared.NavigationController.dismiss(animated: false, completion: nil)
            let vc = self.instantiateVC(with: GVCIdentifier.streamerAddAccount) as! VCStreamerAddAcc
            vc.isPresent = true
            GNavigation.shared.push(vc, isAnimated: true)
            return true
        }else{
            return false
        }
    }
    
    func isShowVideoTutorial() -> Bool {
        if self.isUserTypeViewer() {
            if (UserDefaults.standard.bool(forKey: GConstant.UserDefaults.kViewerVideoTutorial) == false)  {
                return true
            }
        }else{
            if (UserDefaults.standard.bool(forKey: GConstant.UserDefaults.kStreamerVideoTutorial)  == false)  {
                return true
            }
        }
        
        return false
    }
    
    func isShowBeginingTutorial() -> Bool {
        if self.isUserTypeViewer() {
            if (UserDefaults.standard.bool(forKey: GConstant.UserDefaults.kViewerTutorial) == false)  {
                return true
            }
        }else{
            if (UserDefaults.standard.bool(forKey: GConstant.UserDefaults.kStreamerTutorial)  == false)  {
                return true
            }
        }
        
        return false
    }
    
    func removeActivityIndicator() {
        indicatorView.isHidden = true
        indicatorView.stopAnimating()
        indicatorView .removeFromSuperview()
    }
    
    // MARK:- Call Xib View
    
    func viewFromNibName(name: String) -> UIView? {
        let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        return views!.first as? UIView
    }
    
    //------------------------------------------------------
    
    //MARK:- UserDefaults
    
    //------------------------------------------------------
    
    func storeLoginData(_ data: UserResult) {
        GFunction.shared.removeUserDefaults(key: GConstant.UserDefaults.kUserData)
        let encodedData = try! JSONEncoder().encode(data)
        let userDefault = UserDefaults.standard
        userDefault.set(encodedData, forKey: GConstant.UserDefaults.kUserData)
        userDefault.synchronize()
        
        self.getUserDetailFromDefaults()
    }
    
    func getUserDetailFromDefaults() {
        let userDefault = UserDefaults.standard
        if let decodeData = userDefault.data(forKey: GConstant.UserDefaults.kUserData)  {
            GConstant.UserData =  try! UserResult.init(data: decodeData)
        }
    }
    
    func saveDataIntoUserDefault (object : AnyObject, key : String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(object, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    func removeUserDefaults (key : String) {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func getDeviceToken(_ tokenType: TokenType = .standard) -> String {
        let keyValue = tokenType == .standard ? GConstant.UserDefaults.kDeviceToken : GConstant.UserDefaults.kDeviceTokenVoip
        if (UserDefaults.standard.value(forKey: keyValue) != nil) {
            let deviceToken : String? = UserDefaults.standard.value(forKey: keyValue) as? String
            guard let
                letValue = deviceToken, !letValue.isEmpty else {
                    //print(":::::::::-Value Not Found-:::::::::::")
                    return "0"
            }
            return deviceToken!
        }
        return "0"
    }
    
    //------------------------------------------------------
    
    func convertToJSONString(arrayData : Any) -> String {
        
        do {
            //Convert to Data
            let jsonData = try JSONSerialization.data(withJSONObject: arrayData, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            //Convert back to string. Usually only do this for debugging
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                return JSONString
            }
        }
        catch {
            return ""
        }
        return ""
    }
    
    func userLogin(_ window : UIWindow!) {
        self.setHomePage(window)
    }
    
    func userLogOut(_ window : UIWindow!) {
        self.removeUserDefaults(key: GConstant.UserDefaults.kUserData)
        
        // Set root navigation setup here
        let initialViewController = self.instantiateVC(with: GVCIdentifier.login)
        let navigationController = UINavigationController(rootViewController: initialViewController)
        navigationController.customize()
        navigationController.isNavigationBarHidden = true
        GNavigation.shared.NavigationController = navigationController
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func setHomePage(_ window : UIWindow!) {
        getUserDetailFromDefaults()
        
        // Setup Front View Controller
        let identifier = GConstant.UserData.userType == "S" ? GVCIdentifier.streamerHome : GVCIdentifier.viewerHome
        let initialViewController = self.instantiateVC(with: identifier)  as! VCHome
        let frontNavigationController = UINavigationController(rootViewController: initialViewController)
        frontNavigationController.customize()
        frontNavigationController.isNavigationBarHidden = true
        GNavigation.shared.NavigationController = frontNavigationController
        
        window?.rootViewController = self.setupRevealController(frontNavigationController)
        window?.makeKeyAndVisible()
    }
    
    func setupRevealController(_ frontNavigationController: UINavigationController) -> SWRevealViewController{
        
        // Setup Rear View Controller
        let rearViewController = self.instantiateVC(with: GVCIdentifier.sideMenu)  as! VCSideMenu
        let revealController = SWRevealViewController()
        revealController.frontViewController = frontNavigationController
        revealController.rearViewController = rearViewController
        revealController.rearViewRevealWidth = UIScreen.main.bounds.width*0.7
        
        revealController.navigationController?.isNavigationBarHidden = true
        GNavigation.shared.revealController = revealController
        
        return revealController
    }
    
}


