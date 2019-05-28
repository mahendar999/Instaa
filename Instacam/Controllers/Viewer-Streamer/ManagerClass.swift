//
//  ManagerClass.swift
//  Instacam
//
//  Created by Apple on 08/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import Alamofire

class ManagerClass{
    static let shared = ManagerClass()
    
    var userId: String!
    var channel: String!
    
    struct PassData {
        let userId: String!
        let channel: String!
        let message: String!
        let streamId: String!
        let uid: String!
    }
    
    func showAlert(_ alert: GPAlert) {
        AlertManager.shared.show(alert, buttonsArray: ["Ok"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                GNavigation.shared.popToRoot(VCHome.self)
                break
            default:
                break
            }
        }
    }
    
    func hitApi(_ data: PassData, isDeclined: Bool = false, completion: @escaping (String)->Void) {
        let requestModel = ProfileRequestModel()
        requestModel.user_id = data.userId
        requestModel.user_type = GConstant.UserData.userType
        ManagerClass.shared.callProfileApi(requestModel) { (deviceToken, deviceType) in
            
            let requestModel = NotificationRequestModel()
            requestModel.channel_name = data.channel
            requestModel.message = data.message
            requestModel.device_token = deviceToken
            requestModel.type = deviceType
            requestModel.stream_id = data.streamId
            requestModel.streamer_id = GConstant.UserData.id
            requestModel.uid = data.uid
            
            if deviceType == "android" {
                requestModel.collapse_key = "call"
                self.callNotificationApi(requestModel, apiUrl: GAPIConstant.testAndroidNotification(), completion: {
                    completion(deviceType)
                })
            }else{
                self.callNotificationApi(requestModel, apiUrl: GAPIConstant.testIosNotification(), completion: {
                    completion(deviceType)
                })
            }
        }
    }
    
    func callNotificationApi(_ requestModel: NotificationRequestModel, apiUrl: String, completion: @escaping ()->Void) {
        let headers: HTTPHeaders = ["content-type": "application/x-www-form-urlencoded"]
        APICall.shared.POST(strURL: apiUrl, parameter: requestModel.toDictionary(), withLoader: false, apiEncoding: URLEncoding(), apiHeaders: headers) { (responseData, statusCode) in
            GFunction.shared.removeLoader()
            if let data = responseData {
                let responseModel = try! NotificationResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    let alert = GPAlert(title: "", message: responseModel.message ?? "")
                    if statusCode == 200 {
                        CallJoinData.shared.acceptedTimestamp = responseModel.acceptedTimestamp
                        completion()
                    }else{
                        self.showAlert(alert)
                    }
                }
            }
        }
    }
    
    func callProfileApi(_ requestModel: ProfileRequestModel, completion: @escaping (String, String)->Void) {
        
        APICall.shared.POST(strURL: GAPIConstant.getProfile(), parameter: requestModel.toDictionary(), withLoader: false) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! UserResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        if let userResult = responseModel.result {
                            
                            Payload.shared.userName = userResult.fullName
                            Payload.shared.userProfile = userResult.profileImage
                            
                            if let deviceType = userResult.deviceType {
                                if deviceType.lowercased() == "android" {
                                    // Android Device
                                    if let deviceToken = userResult.deviceToken {
                                        if deviceToken == "" {
                                            GFunction.shared.removeLoader()
                                            self.showAlert(GPAlert(title: "Viewer not available", message: "Failed to initiate the call"))
                                        }else{
                                            completion(deviceToken, userResult.deviceType!.lowercased())
                                        }
                                    }
                                    
                                }else{
                                    // iOS Device
                                    if let deviceToken = userResult.voipDeviceToken {
                                        if deviceToken == "" {
                                            GFunction.shared.removeLoader()
                                            self.showAlert(GPAlert(title: "Viewer not available", message: "Failed to initiate the call"))
                                        }else{
                                            completion(deviceToken, userResult.deviceType!.lowercased())
                                        }
                                    }
                                    
                                }
                                
                            }
                        }
                    }else{
                        AlertManager.shared.show(GPAlert(title: "Error", message: responseModel.message ?? ""))
                    }
                    
                }
            }else{
                GFunction.shared.removeLoader()
            }
        }
    }
    
}

