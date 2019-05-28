//
//  VMCompleteProfile.swift
//  Instacam
//
//  Created by Apple on 29/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import Photos

class VMCompleteProfile: NSObject {
    
    var mainImage = UIImage()
    var isProfileSelected = false
    
    func callCompleteProfileApi(_ requestModel: UserProfileRequestModel, isLoader: Bool = true, completion: @escaping (String)->Void) {
        
        /*
         Api name: updateProfile
         Parameters: "Required: user_id
         Optional: device_type, device_token
         full_name, address, email, lat, lng, city, state, country, postal_code, is_profile_created, password, device, languages(comma separated)"
         Method: POST
         */
        
        APICall.shared.POST(strURL: GAPIConstant.updateProfile(), parameter: requestModel.toDictionary(), withLoader: isLoader) { (responseData, statusCode) in
            
            if let data = responseData {
                let responseModel = try! UserResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        
                        if let loginResult = responseModel.result {
                            GFunction.shared.storeLoginData(loginResult)
                            
                            if let userType = loginResult.userType {
                                let identifier = userType == "S" ? GVCIdentifier.streamerHome : GVCIdentifier.viewerHome
                                if SocketIOManager.shared.socket.status != .connected {
                                    SocketIOManager.shared.establishConnection()
                                }
                                completion(identifier)
                            }
                        }
                        
                    }else{
                        AlertManager.shared.show(GPAlert(title: "", message: responseModel.message ?? ""))
                    }
                    
                }
                
            }
        }
    }
    
    func callUploadImageApi(_ requestModel: UserProfileRequestModel, imageData: Data, completion: @escaping ()->Void = { }) {
        
        /*
         Api name: updateProfileImage
         Parameters: user_id, image
         Method: POST
        */
        
        APICall.shared.Upload(strURL: GAPIConstant.updateProfileImage(), parameter: requestModel.toDictionary(), constructingBodyWithBlock: { (multiData) -> Void  in
            
            let timestamp = Int(Date.timeIntervalBetween1970AndReferenceDate)
            multiData?.append(imageData, withName: "image", fileName: "\(timestamp).jpeg", mimeType: "image/jpeg")
            
            var parameters = requestModel.toDictionary()
            parameters["lang"] = GConstant.prefferedLanguage
            for (key, value) in parameters {
                multiData?.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        
        }, withBlock: { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! UserResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        if let loginResult = responseModel.result {
                            GFunction.shared.storeLoginData(loginResult)
                            GConstant.UserData = loginResult
                            completion()
                        }
                    }else{
                        AlertManager.shared.show(GPAlert(title: "", message: responseModel.message ?? ""))
                    }
                }
            }
        })
        
    }
    
}
