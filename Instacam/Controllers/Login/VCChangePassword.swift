//
//  VCChangePassword.swift
//  Instacam
//
//  Created by Apple on 03/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCChangePassword: UIViewController {
    
    @IBOutlet weak var tfCurrentPassword: UITextField!
    @IBOutlet weak var tfNewPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var btnSaveOutlet: UIButton!
    
    var objVMAPIs = VMAPIs()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMainView()
    }
    
    func initMainView() {
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navBackIcon, isLeftMenu: false), btnRight: nil, title: "Change Password".localized())
        self.navigationController?.customize()
        self.btnSaveOutlet.roundedCorener()
    }
    
    @objc func leftButtonClicked() {
        GNavigation.shared.pop()
    }
    
    @IBAction func btnSave(_ sender: UIButton) {
        self.view.endEditing(true)
        let validationAlert = validateView()
        if validationAlert == nil {
            let requestModel = UserProfileRequestModel()
            requestModel.password = tfNewPassword.text!
            requestModel.old_password = tfCurrentPassword.text!
            requestModel.user_id = GConstant.UserData.id
            self.objVMAPIs.callChangePassApi(requestModel) {
                GNavigation.shared.pop()
            }
        }else{
            AlertManager.shared.show(validationAlert!)
        }
    }
    
    func validateView() -> GPAlert?{
        var alert: GPAlert? = nil
        if tfCurrentPassword.text!.isEmpty {
            alert = GPAlert(title: "Current Password", message: "Please enter Current Password")
        }else if tfCurrentPassword.text!.count < 8 {
            alert = GPAlert(title: "Current Password", message: "Password should be at least 8 characters")
        }else if tfNewPassword.text!.isEmpty {
            alert = GPAlert(title: "New Password", message: "Please enter a Password")
        }else if tfNewPassword.text!.count < 8 {
            alert = GPAlert(title: "New Password", message: "Password should be at least 8 characters")
        }else if tfConfirmPassword.text!.isEmpty {
            alert = GPAlert(title: "Confirm New Password", message: "Please enter a Password")
        }else if tfNewPassword.text! != tfConfirmPassword.text! {
            alert = GPAlert(title: "Password", message: "Password does not match")
        }
        
        return alert
    }


}
