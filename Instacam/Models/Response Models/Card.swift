//
//  Card.swift
//  Dinning
//
//  Created by Ankit Kumar on 21/08/18.
//  Copyright © 2018 MH011. All rights reserved.
//

import UIKit
import SwiftyJSON

class Card: NSObject {
    var cardID = String()
    var cardCustomer = String()
    var cardLastFourDigit = String()
    var cardExpMonth = String()
    var cardExpYear = String()
    var cardBrand = String()
    var cardFingerPrint = String()
    override init() {
    }
   
    init(objData:JSON) {
        self.cardID   = objData["id"].stringValue
        self.cardCustomer   = objData["customer"].stringValue
        self.cardLastFourDigit   = objData["last4"].stringValue
        self.cardExpMonth   = objData["exp_month"].stringValue
        self.cardExpYear   = objData["exp_year"].stringValue
        self.cardBrand   = objData["brand"].stringValue
        self.cardFingerPrint   = objData["fingerprint"].stringValue
    }
}
