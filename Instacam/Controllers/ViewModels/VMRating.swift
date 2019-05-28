//
//  VMRating.swift
//  Instacam
//
//  Created by Apple on 05/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

class VMRating: NSObject {
    
    func callStreamerRatingApi(_ requestModel: RatingRequestModel, completion: @escaping ()->Void = {}) {
        
        /*
         Api name: callRatingForViewer
         Parameters: "Required: stream_id, viewer_rating
         Optional: viewer_compliment, viewer_complaint"
         Method: POST
         */
        
        APICall.shared.POST(strURL: GAPIConstant.callRatingForViewer(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! CommonResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    let alert = GPAlert(title: "", message: responseModel.message ?? "")
                    if statusCode == 200 {
                        completion()
                    }else{
                        AlertManager.shared.show(alert)
                    }
                }
            }
        }
        
    }
    
    func callViewerRatingApi(_ requestModel: RatingRequestModel, completion: @escaping ()->Void = {}) {
        
        /*
         Api name: callRatingForStreamer
         Parameters: "Required: stream_id, streamer_rating
         Optional: streamer_compliment, streamer_complaint, streamer_tip"
         Method: POST
         */
        
        APICall.shared.POST(strURL: GAPIConstant.callRatingForStreamer(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! CommonResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    let alert = GPAlert(title: "", message: responseModel.message ?? "")
                    if statusCode == 200 {
                        completion()
                    }else{
                        AlertManager.shared.show(alert)
                    }
                }
            }
        }
        
    }
    
}



