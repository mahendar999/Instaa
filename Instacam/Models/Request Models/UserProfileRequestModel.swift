//
//  UpdateRequestModel.swift
//  Instacam
//
//  Created by Apple on 29/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserProfileRequestModel: NSObject {
    
    var user_id                         : String?
    var phone_number                    : String?
    var country_code                    : String?
    var device_type                     : String?
    var device_token                    : String?
    var lat                             : String?
    var lng                             : String?
    var email                           : String?
    var token                           : String?
    var full_name                       : String?
    var address                         : String?
    var password                        : String?
    var old_password                    : String?
    var city                            : String?
    var state                           : String?
    var country                         : String?
    var postal_code                     : String?
    var user_type                       : String?
    var bio                             : String?
    var invite_code                     : String?
    var is_profile_created              : String?
    var languages                       : String?
    var notificaions                    : String?
    var voip_device_token               : String?
    var device                          : String?
    var default_card                    : String?
    
    override init() {
        super.init()
    }
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        
        user_id                 = json["user_id"].stringValue
        phone_number            = json["phone_number"].stringValue
        country_code            = json["country_code"].stringValue
        device_type             = json["device_type"].stringValue
        device_token            = json["device_token"].stringValue
        lat                     = json["lat"].stringValue
        lng                     = json["lng"].stringValue
        email                   = json["email"].stringValue
        token                   = json["token"].stringValue
        full_name               = json["full_name"].stringValue
        address                 = json["address"].stringValue
        password                = json["password"].stringValue
        old_password            = json["old_password"].stringValue
        city                    = json["city"].stringValue
        state                   = json["state"].stringValue
        country                 = json["country"].stringValue
        postal_code             = json["postal_code"].stringValue
        user_type               = json["user_type"].stringValue
        bio                     = json["bio"].stringValue
        invite_code             = json["invite_code"].stringValue
        is_profile_created      = json["is_profile_created"].stringValue
        languages               = json["languages"].stringValue
        notificaions            = json["notificaions"].stringValue
        voip_device_token       = json["voip_device_token"].stringValue
        device                  = json["device"].stringValue
        default_card            = json["default_card"].stringValue

    }
    
    func toDictionary() -> [String:Any]{
        var dictionary = [String:Any]()
        
        dictionary["user_id"]          = user_id
        dictionary["phone_number"]          = phone_number
        dictionary["country_code"]          = country_code
        dictionary["device_type"]           = device_type
        dictionary["device_token"]          = device_token
        dictionary["lat"]                   = lat
        dictionary["lng"]                   = lng
        dictionary["email"]                 = email
        dictionary["token"]                 = token
        dictionary["full_name"]             = full_name
        dictionary["address"]               = address
        dictionary["password"]              = password
        dictionary["old_password"]          = old_password
        dictionary["city"]                  = city
        dictionary["state"]                 = state
        dictionary["country"]               = country
        dictionary["postal_code"]           = postal_code
        dictionary["user_type"]             = user_type
        dictionary["bio"]                   = bio
        dictionary["invite_code"]           = invite_code
        dictionary["is_profile_created"]    = is_profile_created
        dictionary["languages"]             = languages
        dictionary["notificaions"]          = notificaions
        dictionary["voip_device_token"]     = voip_device_token
        dictionary["device"]                = device
        dictionary["default_card"]          = default_card

        return dictionary
        
    }
    
}

