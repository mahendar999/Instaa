//
//  VMLoginNumber.swift
//  Instacam
//
//  Created by Apple on 22/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

class VMLoginNumber: NSObject {
    var countryCode = "1"
    
    func callVerifyPhoneAPi(_ requestModel: UserProfileRequestModel, completion: @escaping ()->Void) {
        
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
                        
                        if let loginResult = responseModel.result {
                            GConstant.UserData = loginResult
                            completion()
                        }
                        
                    }else{
                        GFunction.shared.removeLoader()
                        AlertManager.shared.show(GPAlert(title: "", message: responseModel.message ?? ""))
                    }
                }
            }
        }
    }
    
    func callSendVerification(_ phoneNumber: String, completion: @escaping ()->Void = { }) {
        
 
        VerifyAPI.sendVerificationCode(self.countryCode, phoneNumber) { (success) in
            if success {
                DispatchQueue.main.async {
                    GFunction.shared.removeLoader()
                    let vcVerification = self.instantiateVC(with: GVCIdentifier.verification) as! VCVerification
                    vcVerification.phoneNumber = phoneNumber
                    vcVerification.countryCode = self.countryCode
                    vcVerification.isComingFromLoginNumber = true
                    GNavigation.shared.push(vcVerification)
                }
            }
        }
    }
    
}

extension VCLoginNumber: CountryListDelegate {
    func selectedCountry(country: Country) {
        pickerLabel.text = "+\(country.phoneExtension)"
        self.objVMLoginNumber.countryCode = country.phoneExtension
    }
}
