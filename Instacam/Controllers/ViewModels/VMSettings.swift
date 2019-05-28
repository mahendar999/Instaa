//
//  VMSettings.swift
//  Instacam
//
//  Created by Apple on 03/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

class VMSettings: NSObject {
    
    func callLogoutApi(_ requestModel: ProfileRequestModel) {
        
        /*
         Api name: logout
         Parameters: user_id
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.logout(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            GFunction.shared.userLogOut(self.appDelegate.window)
            
            SocketIOManager.shared.closeConnection()
        }
        
    }
    
    func callDeactivateApi(_ requestModel: UserProfileRequestModel) {
        
        /*
         Api name: deleteAccount
         Parameters: user_id
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.deactivateAccount(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! CommonResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    let alert = GPAlert(title: "", message: responseModel.message ?? "")
                    if statusCode == 200 {
                        AlertManager.shared.showPopup(alert, forTime: 2, completionBlock: { (INT) in
                            GFunction.shared.userLogOut(self.appDelegate.window)
                            SocketIOManager.shared.closeConnection()
                        })
                    }else{
                        AlertManager.shared.show(alert)
                    }
                }
            }
        }
    }
    
    func callNotificationSettingApi(_ requestModel: UserProfileRequestModel) {
        
        /*
         Api name: setSettings
         Parameters: user_id, notificaions(0, 1)
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.setSettings(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            
            SocketIOManager.shared.closeConnection()
        }
    }
    
}
