//
//  CellCardList.swift
//  Instacam
//
//  Created by Apple on 26/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit


class CellCardList: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgCheckbox: UIImageView!
    @IBOutlet weak var lblCardNumber: UILabel!
    
    @IBOutlet weak var btnAddCard: UIButton!
    @IBOutlet weak var btnDeleteCard: UIButton!
}
