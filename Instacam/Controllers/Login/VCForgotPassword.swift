//
//  VCForgotPassword.swift
//  Instacam
//
//  Created by Apple on 29/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCForgotPassword: UIViewController {
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var btnSendOutlet: UIButton!
    
    var objVMAPIs = VMAPIs()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initMainView()
    }
    
    func initMainView() {
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navBackIcon, isLeftMenu: false), btnRight: nil, title: "")
        btnSendOutlet.roundedCorener()
    }
    
    @objc func leftButtonClicked() {
        GNavigation.shared.pop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.customize(isTransparent: true)
    }
    
    @IBAction func btnSend(_ sender: UIButton) {
        self.view.endEditing(true)
        let validationAlert = validateView()
        if validationAlert == nil {
            let requestModel = UserProfileRequestModel()
            requestModel.email = tfEmail.text!
            self.objVMAPIs.callForgotPassApi(requestModel) {
                GNavigation.shared.pop()
            }
        }else{
            AlertManager.shared.show(validationAlert!)
        }
    }
    
    func validateView() -> GPAlert?{
        var alert: GPAlert? = nil
        if tfEmail.text!.isEmpty {
            alert = GPAlert(title: "Phone number or Email", message: "Please enter Phone number or Email")
        }
        return alert
    }
    
}
