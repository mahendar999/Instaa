//
//  RatingRequestModel.swift
//  Instacam
//
//  Created by Apple on 05/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import SwiftyJSON

class RatingRequestModel: NSObject {
    
//    "Required: stream_id, streamer_rating
//    Optional: streamer_compliment, streamer_complaint, streamer_tip"
//
//    "Required: stream_id, viewer_rating
//    Optional: viewer_compliment, viewer_complaint"
    
    var stream_id               : String!
    var streamer_rating         : String?
    var streamer_compliment     : String?
    var streamer_complaint      : String?
    var streamer_tip            : String?
    
    var type                    : String?
    
    var viewer_rating           : String?
    var viewer_compliment       : String?
    var viewer_complaint        : String?
    
    override init() {
        super.init()
    }
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        
        stream_id                   = json["stream_id"].stringValue
        if type == "viewer" {
            viewer_rating           = json["viewer_rating"].stringValue
            viewer_compliment       = json["viewer_compliment"].stringValue
            viewer_complaint        = json["viewer_complaint"].stringValue
        }else{
            streamer_rating         = json["streamer_rating"].stringValue
            streamer_compliment     = json["streamer_compliment"].stringValue
            streamer_complaint      = json["streamer_complaint"].stringValue
            streamer_tip            = json["streamer_tip"].stringValue
        }
        
    }
    
    func toDictionary() -> [String:Any]{
        var dictionary = [String:Any]()
        
        dictionary["stream_id"]                     = stream_id
        if type == "viewer" {
            dictionary["viewer_rating"]             = viewer_rating
            dictionary["viewer_compliment"]         = viewer_compliment
            dictionary["viewer_complaint"]          = viewer_complaint
        }else{
            dictionary["streamer_rating"]           = streamer_rating
            dictionary["streamer_compliment"]       = streamer_compliment
            dictionary["streamer_complaint"]        = streamer_complaint
            dictionary["streamer_tip"]              = streamer_tip
        }
        
        return dictionary
        
    }
    
}
