//
//  ReportRequestModel.swift
//  Instacam
//
//  Created by Apple on 09/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import SwiftyJSON

class ReportRequestModel: NSObject {
    
//    Required: user_id, stream_id, reported_user_id, category, user_type('V', 'S'), reported_user_type('V', 'S')
//    Optional: reason
    
    var user_id                 : String!
    var stream_id               : String?
    var reported_user_id        : String?
    var category                : String?
    var user_type               : String?
    var reported_user_type      : String?
    var reason                  : String?
    
    override init() {
        super.init()
    }
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        
        user_id                     = json["user_id"].stringValue
        stream_id                   = json["stream_id"].stringValue
        reported_user_id            = json["reported_user_id"].stringValue
        category                    = json["category"].stringValue
        user_type                   = json["user_type"].stringValue
        reported_user_type          = json["reported_user_type"].stringValue
        reason                      = json["reason"].stringValue
        
    }
    
    func toDictionary() -> [String:Any]{
        var dictionary = [String:Any]()
        
        dictionary["user_id"]                       = user_id
        dictionary["stream_id"]                     = stream_id
        dictionary["reported_user_id"]              = reported_user_id
        dictionary["category"]                      = category
        dictionary["user_type"]                     = user_type
        dictionary["reported_user_type"]            = reported_user_type
        dictionary["reason"]                        = reason
        
        return dictionary
        
    }
    
}
