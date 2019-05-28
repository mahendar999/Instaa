//
//  VCHistory.swift
//  Instacam
//
//  Created by Apple on 16/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCHistory: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    
    var objVMHistory = VMHistory()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initMainView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let requestModel = UserProfileRequestModel()
        requestModel.user_id = GConstant.UserData.id

        if GConstant.UserData.userType == LoginUserType.streamer.rawValue {
            objVMHistory.callStreamerHistoryApi(requestModel) {(success) -> Void in
                if success {
                    self.tblView.reloadData()
                }else{
                    self.objVMHistory.arrHistoryData = []
                    EmptyDataManager.shared.addView(on: self.tblView, title: "", message: "No history available!")
                    self.tblView.reloadData()
                }
            }
        }else{
            requestModel.user_type = GConstant.UserData.userType
            objVMHistory.callHistoryApi(requestModel) {(success) -> Void in
                if success {
                    self.tblView.reloadData()
                }else{
                    self.objVMHistory.arrHistoryData = []
                    EmptyDataManager.shared.addView(on: self.tblView, title: "", message: "No history available!")
                    self.tblView.reloadData()
                }
            }
        }
    }
    
    func initMainView() {
        let navTitle = GConstant.UserData.userType == LoginUserType.streamer.rawValue ? "Streamer History".localized() : "Viewer History".localized()
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navMenuIcon), btnRight: nil, title: navTitle)
        self.navigationController?.customize()
    }

    
}
