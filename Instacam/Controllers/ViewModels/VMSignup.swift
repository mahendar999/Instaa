//
//  VMSignup.swift
//  Instacam
//
//  Created by Apple on 03/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

class VMSignup: NSObject {
    var countryCode = "1"
    
    func callSendVerification(_ phoneNumber: String, completion: @escaping ()->Void = { }) {
        VerifyAPI.sendVerificationCode(self.countryCode, phoneNumber) { (success) in
            GFunction.shared.removeLoader()
            if success {
                DispatchQueue.main.async {
                    let vcVerification = self.instantiateVC(with: GVCIdentifier.verification) as! VCVerification
                    vcVerification.phoneNumber = phoneNumber
                    vcVerification.countryCode = self.countryCode
                    GNavigation.shared.push(vcVerification)
                }
            }
            
        }
    }
    
    func callVerifyPhoneAPi(_ requestModel: UserProfileRequestModel, completion: @escaping ()->Void = { }) {
        
        /*
         Api name: verifyPhoneNumber
         Parameters: "phone_number, country_code
         Optional: device_type, device_token, lat, lng, voip_device_token"
         Method: POST
         */
        
        GFunction.shared.addLoader(nil)
        APICall.shared.POST(strURL: GAPIConstant.verifyPhoneNumber(), parameter: requestModel.toDictionary(), withLoader: false) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! UserResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        GFunction.shared.removeLoader()
                        AlertManager.shared.show(GPAlert(title: "", message: "Number already registered please login."))
                    }else{
                        completion()
                    }
                }
            }else{
                GFunction.shared.removeLoader()
            }
        }
    }
    
}

extension VCSignup: CountryListDelegate {
    func selectedCountry(country: Country) {
        pickerLabel.text = "+\(country.phoneExtension)"
        self.objVMSignup.countryCode = country.phoneExtension
    }
}
