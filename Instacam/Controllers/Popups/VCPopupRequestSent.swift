//
//  VCStreamerDial.swift
//  Instacam
//
//  Created by Apple on 23/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCPopupRequestSent: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMainView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    func initMainView() {
        
    }
   
    
    @IBAction func btnOk(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
}
