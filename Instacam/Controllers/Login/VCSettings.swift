//
//  VCSettings.swift
//  Instacam
//
//  Created by Apple on 03/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCSettings: UIViewController {

    @IBOutlet weak var vwdeactivateOutlet: UIView!
    @IBOutlet weak var vwPasswordOutlet: UIView!
    @IBOutlet weak var btnSignoutOutlet: UIButton!
    
    var objVMSettings = VMSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMainView()
    }
    
    func initMainView() {
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navMenuIcon), btnRight: nil, title: "Settings".localized())
        self.navigationController?.customize()
        self.btnSignoutOutlet.roundedCorener()
    }
    
    @IBAction func btnFAQ(_ sender: UIButton) {
        let vcFaq = self.instantiateVC(with: GVCIdentifier.webview) as! VCWebView
        vcFaq.navTitle = "FAQ".localized()
        GNavigation.shared.push(vcFaq)
    }
    
    @IBAction func btnPrivacyPolicy(_ sender: UIButton) {
        let vcPolicy = self.instantiateVC(with: GVCIdentifier.webview) as! VCWebView
        vcPolicy.navTitle = "Privacy Policy".localized()
        GNavigation.shared.push(vcPolicy)
    }
    
    @IBAction func btnNotifications(_ sender: UIButton) {
        let alert = GPAlert(title: "Turn On Push Notifications", message: "These notifications are important for your experience and should be kept on. Go to your device settings for Instacam, tap Permissions, then turn on notifications")
        AlertManager.shared.showActionSheet(sender, alert: alert) {
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        }
    }
    
    @IBAction func btnCommmunity(_ sender: UIButton) {
        let vcCommunity = self.instantiateVC(with: GVCIdentifier.webview) as! VCWebView
        vcCommunity.navTitle = "Community Guidelines".localized()
        GNavigation.shared.push(vcCommunity)
    }
    
    @IBAction func btnLocation(_ sender: UIButton) {
        let alert = GPAlert(title: "Turn On Location Sharing", message: "Instacam requires device location to serve your requests. Go to your device settings for Instacam, tap Permissions, then turn on location access")
        AlertManager.shared.showActionSheet(sender, alert: alert) {
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        }
    }
    
    @IBAction func btnChangePass(_ sender: UIButton) {
        GNavigation.shared.pushWithoutData(GVCIdentifier.changePassword)
    }
    
    @IBAction func btnDeactivateAccount(_ sender: UIButton) {
        let alert = GPAlert(title: "Deactivate Account", message: "Are you sure you want to deactivate your account?")
        AlertManager.shared.show(alert, buttonsArray: ["No","Yes"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                break
            case 1:
                //ok clicked
                let requestModel = UserProfileRequestModel()
                requestModel.user_id = GConstant.UserData.id!
                self.objVMSettings.callDeactivateApi(requestModel)
                break
            default:
                break
            }
        }
    }
    
    @IBAction func btnSignout(_ sender: UIButton) {
        let alert = GPAlert(title: "Signout", message: "Are you sure you want to sign out?")
        AlertManager.shared.show(alert, buttonsArray: ["No","Yes"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                break
            case 1:
                //Ok clicked
                let requestModel = ProfileRequestModel()
                requestModel.user_id = GConstant.UserData.id!
                self.objVMSettings.callLogoutApi(requestModel)
                break
            default:
                break
            }
        }
    }
    
}
