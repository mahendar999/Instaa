//
//  VCLoginNumber.swift
//  Instacam
//
//  Created by Apple on 22/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCLoginNumber: UIViewController {

    @IBOutlet weak var tfPhone: UITextField!
    
    var objVMLoginNumber = VMLoginNumber()
    var countryList = CountryList()
    var pickerLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMainView()
    }
    
    func initMainView() {
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navBackIcon, isLeftMenu: false), btnRight: nil, title: "")
        
        let countryPickerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        tfPhone.leftView = countryPickerView
        tfPhone.leftViewMode = .always
        
        if let countryCode = NSLocale.current.regionCode {
            objVMLoginNumber.countryCode = countryCode.getCountryCallingCode(countryRegionCode: countryCode)
        }else{
            objVMLoginNumber.countryCode = "1"
        }
        
        pickerLabel = UILabel(frame: countryPickerView.bounds)
        pickerLabel.text = "+\(objVMLoginNumber.countryCode)"
        pickerLabel.font = UIFont(name: "Arial", size: 13)
        pickerLabel.textColor = .white
        pickerLabel.textAlignment = .center
        countryPickerView.addSubview(pickerLabel)
        
        countryList.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnCountryPicker))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        countryPickerView.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.customize(isTransparent: true)
    }
    
    
    @objc func didTapOnCountryPicker() {
        let navController = UINavigationController(rootViewController: countryList)
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func leftButtonClicked() {
        GNavigation.shared.pop()
    }
    
   
    @IBAction func btnLogin(_ sender: UIButton) {
        self.view.endEditing(true)
        let validationAlert = validateView()
        if validationAlert == nil {
            let requestModel = UserProfileRequestModel()
            requestModel.phone_number = self.tfPhone.text!
            requestModel.country_code = objVMLoginNumber.countryCode
            requestModel.device_type = "iOS"
            
            let objLocationManager = LocationManager.shared.currentLocation
            if objLocationManager != nil {
                requestModel.lat = "\(objLocationManager!.coordinate.latitude)"
                requestModel.lng = "\(objLocationManager!.coordinate.longitude)"
            }
            
            requestModel.voip_device_token = GFunction.shared.getDeviceToken(.voip)
            requestModel.device_token = GFunction.shared.getDeviceToken(.standard)
            
            self.objVMLoginNumber.callVerifyPhoneAPi(requestModel, completion: {
                self.objVMLoginNumber.callSendVerification(self.tfPhone.text!)
            })
            
        }else{
            AlertManager.shared.show(validationAlert!)
        }
    }
    
    // MARK:- API Call
    
    func callLoginApi(_ requestModel: LoginRequestModel) {
        
        /*
         Api name: login
         Parameters: (Required) = emailOrPhone, password, (Optional) = device_token, device_type('iOS', 'Android')", voip_device_token
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
        if tfPhone.text!.isEmpty {
            alert = GPAlert(title: "Phone Number", message: "Please enter a Phone Number")
        }
        return alert
    }

}

