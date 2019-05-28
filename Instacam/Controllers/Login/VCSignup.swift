//
//  VCSignup.swift
//  Instacam
//
//  Created by Apple on 29/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCSignup: UIViewController {
    
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfReferral: UITextField!
    @IBOutlet weak var btnNextOutlet: UIButton!
    
    var objVMSignup = VMSignup()
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
            objVMSignup.countryCode = countryCode.getCountryCallingCode(countryRegionCode: countryCode)
        }else{
            objVMSignup.countryCode = "1"
        }
        
        pickerLabel = UILabel(frame: countryPickerView.bounds)
        pickerLabel.text = "+\(objVMSignup.countryCode)"
        pickerLabel.font = UIFont(name: "Arial", size: 13)
        pickerLabel.textColor = .white
        pickerLabel.textAlignment = .center
        countryPickerView.addSubview(pickerLabel)
        
        countryList.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnCountryPicker))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        countryPickerView.addGestureRecognizer(tapGesture)
        
        self.btnNextOutlet.roundedCorener()
    }
    
    @objc func didTapOnCountryPicker() {
        let navController = UINavigationController(rootViewController: countryList)
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func leftButtonClicked() {
        GNavigation.shared.pop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.customize(isTransparent: true)
    }
    
    @IBAction func btnNext(_ sender: UIButton) {
        self.view.endEditing(true)
        if tfPhone.text!.isEmpty {
            AlertManager.shared.show(GPAlert(title: "Phone Number", message: "Please enter a Phone Number"))
        }else if Int(tfPhone.text!) == nil{
            AlertManager.shared.show(GPAlert(title: "Phone Number", message: "Please enter valid Phone Number"))
        }else{
            
            let requestModel = UserProfileRequestModel()
            requestModel.phone_number = self.tfPhone.text!
            requestModel.country_code = objVMSignup.countryCode
            self.objVMSignup.callVerifyPhoneAPi(requestModel) {
                self.objVMSignup.callSendVerification(self.tfPhone.text!)
            }
            
        }
    }
    
    @IBAction func btnAlreadyHaveAccount(_ sender: UIButton) {
        let navigation = GNavigation.shared.NavigationController.viewControllers
        for viewcontroller in navigation {
            if viewcontroller is VCLogin {
                GNavigation.shared.pop()
                return
            }
        }
        
        GNavigation.shared.pushWithoutData(GVCIdentifier.login)
    }
    
    
}
