//
//  VCCredits.swift
//  Instacam
//
//  Created by Apple on 19/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import VeeContactPicker
import Contacts

class VCCredits: UIViewController {
    
    @IBOutlet weak var tfRefferalCode: UITextField!
    var objVMCredits = VMCredits()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initMainView()
        
    }
    
    func initMainView() {
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navMenuIcon), btnRight: nil, title: "Free Credits".localized())
        self.navigationController?.customize()
        
        tfRefferalCode.text = GConstant.UserData.inviteCode
        tfRefferalCode.isEnabled = false
    }
    
    @IBAction func btnShare(_ sender: UIButton) {
        let textShare = [ objVMCredits.shareText ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        GNavigation.shared.present(activityViewController, isAnimated: true)
    }
    
    @IBAction func btnInviteFriends(_ sender: UIButton) {
        requestAccess { (success) in
            if success {
                let veeContactPickerVC = VeeContactPickerViewController.init(defaultConfiguration: ())
                veeContactPickerVC.contactPickerDelegate = self
                veeContactPickerVC.multipleSelection = true
                self.present(veeContactPickerVC, animated: true, completion: nil)
            }
        }
        
    }
    
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
        case .denied:
            showSettingsAlert(completionHandler)
        case .restricted, .notDetermined:
            completionHandler(true)
        }
    }
    
    private func showSettingsAlert(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let alert = GConstant.Alert.contactPermission()
        AlertManager.shared.show(alert, buttonsArray: ["No","Yes"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                completionHandler(false)
                break
            case 1:
                //Ok clicked
                completionHandler(false)
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                break
            default:
                break
            }
        }
    }

}
