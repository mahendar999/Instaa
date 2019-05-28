//
//  ProfileRequestModel.swift
//  Instacam
//
//  Created by Apple on 07/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProfileRequestModel: NSObject {
    
//    "Required: user_id
//    Optional: device_type, device_token"
    
    var user_id                 : String!
    var device_type             : String? = "iOS"
    var device_token            : String?
    var user_type               : String?
    
    override init() {
        super.init()
    }
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        user_id                     = json["user_id"].stringValue
        device_type                 = json["device_type"].stringValue
        device_token                = json["device_token"].stringValue
        user_type                   = json["user_type"].stringValue
    }
    
    func toDictionary() -> [String:Any]{
        var dictionary = [String:Any]()
        
        dictionary["user_id"]               = user_id
        dictionary["device_type"]           = device_type
        dictionary["device_token"]          = device_token
        dictionary["user_type"]             = user_type

        return dictionary
    }
    
}
