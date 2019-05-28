//
//  VCPayments.swift
//  Instacam
//
//  Created by Apple on 08/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCPayments: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    var objVMViewerPayments = VMViewerPayments()
    var objVMAPIs = VMAPIs()
    var isPaymentCompleted = false
    override func viewDidLoad() {
        super.viewDidLoad()

        self.appDelegate.basicKeyBoardSetUp(false)
        initMainView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        objVMViewerPayments.tableView = self.tblView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.appDelegate.basicKeyBoardSetUp()
    }
    
    func initMainView() {
        
        if (self.isUserTypeViewer() && isPaymentCompleted){
            _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navBackIcon, isLeftMenu: false), btnRight: nil, title: "Payment Method".localized())
        }else{
            _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navMenuIcon), btnRight: nil, title: "Payment Method".localized())
        }

        self.navigationController?.customize()
        
        if self.isUserTypeViewer() {
            objVMViewerPayments.getAllCards() {
            }
            tblView.delegate = self
            tblView.dataSource = self
        }
        
    }
    
    @objc func leftButtonClicked() {
        GNavigation.shared.popToRoot(VCHome.self)
    }
    
}
