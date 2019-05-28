//
//  VCVerification.swift
//  Instacam
//
//  Created by Apple on 29/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import KWVerificationCodeView

class VCVerification: UIViewController {

    @IBOutlet weak var tfOTPCode: KWVerificationCodeView!
    @IBOutlet weak var btnResendCodeOutlet: UIButton!
    
    var isComingFromLoginNumber = false
    var phoneNumber = String()
    var countryCode = String()
    var verifyCodeTimer: Timer!
    var verifyDuration = 600
    
    var objVMVerification = VMVerification()
    var objVMSignup = VMSignup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMainView()
    }
    
    func initMainView() {
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navBackIcon, isLeftMenu: false), btnRight: nil, title: "")
        
        self.btnResendCodeOutlet.roundedCorener()
        self.tfOTPCode.underlineColor = .white
        self.tfOTPCode.underlineSelectedColor = .white
        self.tfOTPCode.textColor = .white
        self.tfOTPCode.textSize = 30
        self.tfOTPCode.textFieldTintColor = .white
        
        if verifyCodeTimer == nil {
            verifyCodeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkEnableResend), userInfo: nil, repeats: true)
        }
        
        btnResendCodeOutlet.setTitle("00:00", for: .normal)
        btnResendCodeOutlet.isEnabled = false
    }
    
    @objc func leftButtonClicked() {
        GNavigation.shared.pop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.customize(isTransparent: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        verifyCodeTimer.invalidate()
    }
    
    @IBAction func btnVerify(_ sender: UIButton) {
        self.view.endEditing(true)
        let verificationCode = tfOTPCode.getVerificationCode().replacingOccurrences(of: " ", with: "")
        if verificationCode.isEmpty {
            AlertManager.shared.show(GPAlert(title: "Verfication Code", message: "Please enter Verification Code"))
        }else{
            if tfOTPCode.getVerificationCode().count < 4 {
                AlertManager.shared.show(GPAlert(title: "Verification Code", message: "Please enter 4 digit Verification Code"))
            }else{
                GFunction.shared.addLoader(nil)
                
                VerifyAPI.validateVerificationCode(self.countryCode, self.phoneNumber, tfOTPCode.getVerificationCode()) { (result) in
                    if result.success {
                        DispatchQueue.main.async {
                            
                            if self.isComingFromLoginNumber {
                                GFunction.shared.removeLoader()
                                GFunction.shared.storeLoginData(GConstant.UserData)
                                GFunction.shared.setHomePage(self.appDelegate.window)
                            }else{
                                let requestModel = UserProfileRequestModel()
                                requestModel.phone_number = self.phoneNumber
                                requestModel.country_code = self.countryCode
                                requestModel.device_type = "iOS"
                                requestModel.voip_device_token = GFunction.shared.getDeviceToken(.voip)
                                requestModel.device_token = GFunction.shared.getDeviceToken(.standard)
                                
                                let vc = self.instantiateVC(with: GVCIdentifier.terms) as! VCTerms
                                vc.requestModel = requestModel
                                GNavigation.shared.push(vc)
                            }
                            
                        }
                    }else{
                        GFunction.shared.removeLoader()
                        AlertManager.shared.show(GPAlert(title: "", message: result.message))
                    }
                    
                }
            }
        }
    }
    
    @objc func checkEnableResend() {
        verifyDuration -= 1
        
        if verifyDuration == 0 {
            btnResendCodeOutlet.setTitle("Resend Code".localized(), for: .normal)
            btnResendCodeOutlet.isEnabled = true
        }
        
        let minutesLeft = Int(verifyDuration) / 60 % 60
        let secondsLeft = Int(verifyDuration) % 60
        let minute = minutesLeft < 10 ? "0\(minutesLeft)" : "\(minutesLeft)"
        let second = secondsLeft < 10 ? "0\(secondsLeft)" : "\(secondsLeft)"
        
        let timer = "\(minute):\(second)"
        
        btnResendCodeOutlet.setTitle(timer, for: .normal)
        
    }
    
    @IBAction func btnResend(_ sender: UIButton) {
        objVMSignup.countryCode = self.countryCode
        objVMSignup.callSendVerification(self.phoneNumber)
    }

}
