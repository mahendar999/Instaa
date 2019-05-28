//
//  VCPayments.swift
//  Instacam
//
//  Created by Apple on 08/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCStreamerPayments: UIViewController {
    
    @IBOutlet weak var lblAccStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMainView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let isProfileCreated = GConstant.UserData != nil && (GConstant.UserData.stripeAccountId == nil || GConstant.UserData.stripeAccountId!.count == 0 || GConstant.UserData.stripeAccountId! == "0")
        
        if !isProfileCreated {
            lblAccStatus.text = "Connected".localized()
        }else{
            lblAccStatus.text = ""
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func initMainView() {
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navMenuIcon), btnRight: nil, title: "Payment Method".localized())
    }
    
    @IBAction func btnAddAccount(_ sender: UIButton) {
        let isProfileCreated = GConstant.UserData != nil && (GConstant.UserData.stripeAccountId == nil || GConstant.UserData.stripeAccountId!.count == 0 || GConstant.UserData.stripeAccountId! == "0")
        guard isProfileCreated else { return }
        
        GNavigation.shared.pushWithoutData(GVCIdentifier.streamerAddAccount)
    }
}
