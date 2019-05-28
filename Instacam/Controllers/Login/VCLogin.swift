//
//  VCLogin.swift
//  Instacam
//
//  Created by Apple on 07/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCLogin: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainViewInit()
    }
    
    func mainViewInit() {
//         _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navBackIcon, isLeftMenu: false), btnRight: nil, title: "")
        self.navigationController?.isNavigationBarHidden = true
        loginButton.roundedCorener()
    }
    
    @objc func leftButtonClicked() {
        GNavigation.shared.pop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    @IBAction func btnForgotPassword(_ sender: UIButton) {
        GNavigation.shared.pushWithoutData(GVCIdentifier.forgotPassword)
    }
    
    @IBAction func btnLoginNumber(_ sender: UIButton) {
        GNavigation.shared.pushWithoutData(GVCIdentifier.loginNumber)
    }
    
    @IBAction func btnSignup(_ sender: UIButton) {
        GNavigation.shared.pushWithoutData(GVCIdentifier.signup)
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        self.view.endEditing(true)
        let validationAlert = validateView()
        if validationAlert == nil {
            let requestModel = LoginRequestModel()
            requestModel.email = tfEmail.text!
            requestModel.password = tfPassword.text!
            requestModel.device_type = "iOS"
            requestModel.device = UIDevice.modelName
            requestModel.device_token = GFunction.shared.getDeviceToken(.standard)
            requestModel.voip_device_token = GFunction.shared.getDeviceToken(.voip)
            
            self.callLoginApi(requestModel)
        }else{
            AlertManager.shared.show(validationAlert!)
        }
    }
    
    // MARK:- API Call
    
    func callLoginApi(_ requestModel: LoginRequestModel) {
        
        /*
         Api name: login
         Parameters: (Required) = emailOrPhone, device, password, (Optional) = device_token, device_type('iOS', 'Android')", voip_device_token
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.login(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! UserResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        
                        if let loginResult = responseModel.result {
                            GFunction.shared.storeLoginData(loginResult)
                            GFunction.shared.setHomePage(self.appDelegate.window)
                        }
                        
                        if SocketIOManager.shared.socket.status != .connected {
                            SocketIOManager.shared.establishConnection()
                        }
                        
                    }else{
                        AlertManager.shared.show(GPAlert(title: "Error", message: responseModel.message ?? ""))
                    }
                    
                }
            }
        }
    }
    
    func validateView() -> GPAlert?{
        var alert: GPAlert? = nil
        if tfEmail.text!.isEmpty {
            alert = GPAlert(title: "Email", message: "Please enter an Email")
        }else if tfPassword.text!.isEmpty {
            alert = GPAlert(title: "Password", message: "Please enter a Password")
        }
        return alert
    }

}
