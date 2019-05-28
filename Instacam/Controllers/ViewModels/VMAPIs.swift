//
//  VMAPIs.swift
//  Instacam
//
//  Created by Apple on 09/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation


class VMAPIs: NSObject {
    
    // MARK:- ******************************
    // MARK:- Forgot Password
    // MARK:- ******************************
    
    func callForgotPassApi(_ requestModel: UserProfileRequestModel, completion: @escaping ()->Void = { }) {
        
        /*
         Api name: forgotPassword
         Parameters: email
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.forgot(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! CommonResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    let alert = GPAlert(title: "", message: responseModel.message ?? "")
                    if statusCode == 200 {
                        AlertManager.shared.showPopup(alert, forTime: 2, completionBlock: { (INT) in
                            completion()
                        })
                    }else{
                        AlertManager.shared.show(alert)
                    }
                }
            }
        }
    }
    
    // MARK:- ******************************
    // MARK:- Change Password
    // MARK:- ******************************
    
    func callChangePassApi(_ requestModel: UserProfileRequestModel, completion: @escaping ()->Void = { }) {
        
        /*
         Api name: changePassword
         Parameters: user_id,old_password,password
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.changePassword(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! CommonResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    let alert = GPAlert(title: "", message: responseModel.message ?? "")
                    if statusCode == 200 {
                        AlertManager.shared.showPopup(alert, forTime: 2, completionBlock: { (INT) in
                            completion()
                        })
                    }else{
                        AlertManager.shared.show(alert)
                    }
                }
            }
        }
    }
    
    // MARK:- ******************************
    // MARK:- Report User
    // MARK:- ******************************
    
    func callReportUserApi(_ requestModel: ReportRequestModel, completion: @escaping ()->Void = {}) {
        
        /*
         Api name: reportUser
         Parameters: Required: user_id, stream_id, reported_user_id, category, user_type('V', 'S'), reported_user_type('V', 'S')
         Optional: reason
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.reportUser(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! CommonResponseModel.init(data: data)
                let alert = GPAlert(title: "", message: responseModel.message ?? "")
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        AlertManager.shared.showPopup(alert, forTime: 2.0, completionBlock: { (INT) in
                            completion()
                        })
                    }else{
                        AlertManager.shared.show(alert)
                    }
                }
            }
        }
    }
    
    // MARK:- ******************************
    // MARK:- Cancel Streaming
    // MARK:- ******************************
    
    func callupdateStreamStatusApi(_ requestModel: NotificationRequestModel, completion: @escaping ()->Void = {}) {
        
        /*
         Api name: updateStreamStatus
         Parameters: stream_id, status=0,1,2,3,4
         case pending = "0"
         case accepted = "1"
         case startMoving = "2"
         case cancel = "3"
         case complete = "4"
         case notConnected = "5"
         Method: POST
         */
        
        APICall.shared.POST(strURL: GAPIConstant.updateStreamStatus(), parameter: requestModel.toDictionary(), withLoader: false) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! CommonResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        completion()
                    }else{
                        AlertManager.shared.show(GPAlert(title: "", message: responseModel.message ?? ""))
                    }
                }
            }
        }
    }
    
    // MARK:- ******************************
    // MARK:- Get Rating
    // MARK:- ******************************
    
    func callGetRatingApi(_ requestModel: UserProfileRequestModel, completion: @escaping ()->Void = {}) {
        
        /*
         Api name: getRating
         Parameters: user_type, user_id
         Method: POST
         */
        
        APICall.shared.POST(strURL: GAPIConstant.getRating(), parameter: requestModel.toDictionary(), withLoader: false) { (responseData, statusCode) in
            if let data = responseData {
                
                let json = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
                let statusCode = json["success"] as! Int
                if statusCode == 200 {
                    let count = json["count"] as! Int
                    var rate = String()
                    if let rating = json["rating"] as? Int {
                        rate = "\(rating)"
                    }else{
                        rate = json["rating"] as! String
                    }
                    
                    var amount = String()
                    if let value = json["amount"] as? Int {
                        amount = "\(value)"
                    }else{
                        amount = json["amount"] as! String
                    }
                    
                    let data = RatingModel(rating: rate, count: count, amount: amount)
                    GConstant.UserRoleRating = data
                }
            }
        }
    }
    
    
    // MARK:- ******************************
    // MARK:- Get Profile
    // MARK:- ******************************
    
    func callGetProfileApi(_ requestModel: UserProfileRequestModel, isLoading: Bool = false, completion: @escaping ()->Void = { }) {
        
        /*
         Api name: forgotPassword
         Parameters: user_id, user_type
         Method: POST
         */
        
        APICall.shared.POST(strURL: GAPIConstant.getProfile(), parameter: requestModel.toDictionary(), withLoader: isLoading) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! UserResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        if let loginResult = responseModel.result {
                            GFunction.shared.storeLoginData(loginResult)
                        }
                    }else{
                        AlertManager.shared.show(GPAlert(title: "Error", message: responseModel.message ?? ""))
                    }
                }
            }
        }
    }
    
    // MARK:- ******************************
    // MARK:- Application Page Content
    // MARK:- ******************************
    
    func callGetAppPageContentApi(_ contentType: PageContentType, isLoading: Bool = false, completion: @escaping (String)->Void = { _ in }) {
        
        /*
         Api name: getAppPageContent
         Parameters: page_name
         "Pages: TNC, FAQ, PrivacyPolicy, CommunityGuidelines"
         Method: POST
         */
        
        var parameter = [String:String]()
        
        switch contentType {
        case .terms:
            parameter = ["page_name": "TNC"]
            break
        case .faq:
            parameter = ["page_name": "FAQ"]
            break
        case .privacy:
            parameter = ["page_name": "PrivacyPolicy"]
            break
        case .community:
            parameter = ["page_name": "CommunityGuidelines"]
            break
        }
        
        APICall.shared.POST(strURL: GAPIConstant.getAppPageContent(), parameter: parameter, withLoader: isLoading) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! CommonResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        if let result = responseModel.data {
                           completion(result)
                        }
                    }
                }
            }
        }
    }
    
}
