//
//  VMVerification.swift
//  Instacam
//
//  Created by Apple on 29/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

class VMVerification: NSObject {
    
    func callSignupApi(_ requestModel: UserProfileRequestModel, isLoader: Bool = false, completion: @escaping ()->Void) {
        
        /*
         Api name: signup
         Parameters: "Required: phone_number, country_code
         Optional: profile_image, device_token, device_type('iOS', 'Android'), lat, lng, email, full_name, address, password, city, state, country, postal_code, user_type('V', 'S'), bio, invite_code"
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.signup(), parameter: requestModel.toDictionary(), withLoader: isLoader) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! UserResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        if let loginResult = responseModel.result {
                            GConstant.UserData = loginResult
                            completion()
                        }
                    }else{
                        AlertManager.shared.show(GPAlert(title: "", message: responseModel.message ?? ""))
                    }
                    
                }
                
            }
        }
        
    }
    
}
