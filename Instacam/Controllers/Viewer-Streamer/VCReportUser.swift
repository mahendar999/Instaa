//
//  VCReportUser.swift
//  Instacam
//
//  Created by Apple on 09/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCReportUser: UIViewController {
    
    @IBOutlet weak var tfComment: UITextView!
    var objVMAPIs = VMAPIs()
    var navTitle = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initMainView()
    }
    
    func initMainView() {
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navBackIcon, isLeftMenu: false), btnRight: nil, title: navTitle.localized())
        self.navigationController?.customize()
    }
    
    @objc func leftButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        
        if tfComment.text!.isEmpty {
            let alert = GPAlert(title: "Comment", message: "Please enter Comment")
            AlertManager.shared.show(alert)
        }else{
            let requestModel = ReportRequestModel()
            requestModel.user_id = GConstant.UserData.id
            requestModel.category = navTitle
            requestModel.user_type = GConstant.UserData.userType
            requestModel.reason = tfComment.text!
            
            if GConstant.UserData.userType == LoginUserType.viewer.rawValue {
                requestModel.stream_id = Payload.shared.streamId
                requestModel.reported_user_id = Payload.shared.streamerId
                requestModel.reported_user_type = LoginUserType.streamer.rawValue
            }else{
                requestModel.stream_id = CallJoinData.shared.streamId
                requestModel.reported_user_id = CallJoinData.shared.viewerId
                requestModel.reported_user_type = LoginUserType.viewer.rawValue
            }
            
            self.objVMAPIs.callReportUserApi(requestModel) {
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        
    }
    
}

