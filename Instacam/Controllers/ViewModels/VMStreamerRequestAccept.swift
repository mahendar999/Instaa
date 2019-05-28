//
//  VMStreamerRequestAccept.swift
//  Instacam
//
//  Created by Apple on 26/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class VMStreamerRequestAccept: NSObject {
    
    typealias CompletionHandler = ()->Void
    var reloadMapCompletion: CompletionHandler? = nil
    
    func callAcceptRequest(_ requestModel: StreamRequestModel, completion: @escaping ()->Void) {
        
        /*
         Api name: acceptRequest
         Parameters: stream_id, streamer_id
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.acceptRequest(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! AcceptRequestResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    let alert = GPAlert(title: "", message: responseModel.message ?? "")
                    if statusCode == 200 {
                        CallJoinData.shared.handleData(responseModel.result!)
                        completion()
                    }else{
                        GNavigation.shared.dismiss(false) {
                            if self.reloadMapCompletion != nil {
                                self.reloadMapCompletion!()
                            }
                            AlertManager.shared.show(alert)
                        }
                    }
                }
            }
        }
        
    }
    
    func callDeclineRequest(_ requestModel: StreamRequestModel, completion: @escaping ()->Void) {
        
        /*
         Api name: rejectRequest
         Parameters: user_id, stream_id
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.streamRequest(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! RequestStreamResponseModel.init(data: data)
                let alert = GPAlert(title: "", message: responseModel.message ?? "")
                AlertManager.shared.showPopup(alert, forTime: 2.0)
                completion()
            }
            
        }
    
    }
    
}

class CallJoinData: NSObject{
    static let shared = CallJoinData()
    var viewerId, streamId, channel, acceptedTimestamp, uid: String!
    var totalDuration, status: Int!
    var viewerCoordinate: CLLocationCoordinate2D!
    var objStreamRequest: StreamRequestsResult? = nil
    
    func handleData(_ data: StreamRequestsResult) {
        objStreamRequest = data
        
        if let userID = data.userID {
            viewerId = userID.count > 0 ? userID[0] : ""
            channel = data.channelName!
            streamId = data.id
            
            let lat = (data.lat! as NSString).doubleValue
            let long = (data.lng! as NSString).doubleValue
            viewerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        self.status = data.status
        self.acceptedTimestamp = data.acceptedTimestamp!
        self.totalDuration = data.totalDuration!
        self.uid = data.uid
    }
    
}

