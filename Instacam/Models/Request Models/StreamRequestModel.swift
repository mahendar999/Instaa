//
//  StreamRequestModel.swift
//  Instacam
//
//  Created by Apple on 26/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import SwiftyJSON

struct StreamRequestCodableModel: Codable {
    var location                : String!
    var lat                     : String!
    var lng                     : String!
    var desc                    : String!
    var selectedIndex           : Int!
    var placeName               : String!
    var placeAddress            : String!
}

class StreamRequestModel: NSObject {
    
    var status                  : String!
    var stream_id               : String!
    var streamer_id             : String!
    var user_id                 : String!
    var location                : String!
    var lat                     : String!
    var lng                     : String!
    var duration                : String!
    var desc                    : String!
    var price                   : String!
    var source_lat              : String!
    var source_lng              : String!
    var dest_lat                : String!
    var dest_lng                : String!
    var selectedIndex           : Int!
    var placeName               : String!
    var placeAddress            : String!
    
    override init() {
        super.init()
    }
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        status                      = json["status"].stringValue
        stream_id                   = json["stream_id"].stringValue
        streamer_id                 = json["streamer_id"].stringValue
        user_id                     = json["user_id"].stringValue
        location                    = json["location"].stringValue
        lat                         = json["lat"].stringValue
        lng                         = json["lng"].stringValue
        duration                    = json["duration"].stringValue
        desc                        = json["description"].stringValue
        price                       = json["price"].stringValue
        source_lat                  = json["source_lat"].stringValue
        source_lng                  = json["source_lng"].stringValue
        dest_lat                    = json["dest_lat"].stringValue
        dest_lng                    = json["dest_lng"].stringValue
    }
    
    func toDictionary() -> [String:Any]{
        var dictionary = [String:Any]()
        
        dictionary["status"]                = status
        dictionary["stream_id"]             = stream_id
        dictionary["streamer_id"]           = streamer_id
        dictionary["user_id"]               = user_id
        dictionary["location"]              = location
        dictionary["lat"]                   = lat
        dictionary["lng"]                   = lng
        dictionary["duration"]              = duration
        dictionary["description"]           = desc
        dictionary["price"]                 = price
        dictionary["source_lat"]            = source_lat
        dictionary["source_lng"]            = source_lng
        dictionary["dest_lat"]              = dest_lat
        dictionary["dest_lng"]              = dest_lng
        
        return dictionary
    }
    
}
