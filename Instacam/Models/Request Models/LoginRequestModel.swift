//
//  LoginRequestModel.swift
//  Instacam
//
//  Created by Apple on 07/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import SwiftyJSON

class LoginRequestModel: NSObject {
    
    var email                   : String!
    var device                  : String!
    var password                : String!
    var device_type             : String?
    var device_token            : String?
    var voip_device_token       : String?
    
    override init() {
        super.init()
    }
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        email                   = json["emailOrPhone"].stringValue
        password                = json["password"].stringValue
        device_type             = json["device_type"].stringValue
        device_token            = json["device_token"].stringValue
        voip_device_token       = json["voip_device_token"].stringValue
        device                  = json["device"].stringValue

    }
    
    func toDictionary() -> [String:Any]{
        var dictionary = [String:Any]()
        
        dictionary["emailOrPhone"]          = email
        dictionary["password"]              = password
        dictionary["device_type"]           = device_type
        dictionary["device_token"]          = device_token
        dictionary["voip_device_token"]     = voip_device_token
        dictionary["device"]                = device

        return dictionary
        
    }
    
}


