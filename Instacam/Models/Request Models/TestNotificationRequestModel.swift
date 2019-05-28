//
//  TestNotificationRequestModel.swift
//  Instacam
//
//  Created by Apple on 07/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import SwiftyJSON

class NotificationRequestModel: NSObject {
    
    var channel_name, uid : String!
    var message, device_token, collapse_key, type, streamer_id, stream_id, user_id, status, isAccepted, price, final_duration: String?
    
    override init() {
        super.init()
    }
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        
        channel_name            = json["channel_name"].stringValue
        message                 = json["message"].stringValue
        device_token            = json["device_token"].stringValue
        collapse_key            = json["collapse_key"].stringValue
        streamer_id             = json["streamer_id"].stringValue
        stream_id               = json["stream_id"].stringValue
        status                  = json["status"].stringValue
        user_id                 = json["user_id"].stringValue
        isAccepted              = json["isAccepted"].stringValue
        price                   = json["price"].stringValue
        final_duration          = json["final_duration"].stringValue
        uid                     = json["uid"].stringValue
        
    }
    
    func toDictionary() -> [String:Any]{
        var dictionary = [String:Any]()
        
        dictionary["channel_name"]          = channel_name
        dictionary["message"]               = message
        dictionary["device_token"]          = device_token
        dictionary["collapse_key"]          = collapse_key
        dictionary["streamer_id"]           = streamer_id
        dictionary["stream_id"]             = stream_id
        dictionary["status"]                = status
        dictionary["user_id"]               = user_id
        dictionary["isAccepted"]            = isAccepted
        dictionary["price"]                 = price
        dictionary["final_duration"]        = final_duration
        dictionary["uid"]                   = uid
        
        return dictionary
        
    }
    
}
