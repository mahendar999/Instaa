//
//  CellLanguagePicker.swift
//  Instacam
//
//  Created by Apple on 02/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

class CellLanguagePicker: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
    
}
