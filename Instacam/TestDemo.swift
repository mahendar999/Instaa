//
//  TestDemo.swift
//  Instacam
//
//  Created by Apple on 11/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

class EnviornmentManager {
    
    enum Enviornment: String {
        case debug
        case live
    }
    
    static let shared = EnviornmentManager()
    var enviornment: Enviornment = .live
    
}

enum LoginUserType: String {
    case viewer = "V"
    case streamer = "S"
}

enum StreamingStatus: String{
    case pending = "0"
    case accepted = "1"
    case startMoving = "2"
    case cancel = "3"
    case complete = "4"
    case notConnected = "5"
    case inCall = "6"
}
