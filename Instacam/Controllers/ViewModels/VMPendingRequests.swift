//
//  VMPendingRequests.swift
//  Instacam
//
//  Created by Apple on 08/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

class VMPendingRequests: NSObject {
    
    var arrRequests: [StreamRequestsResult] = []
    
    func callPendingRequestsApi(_ requestModel: UserProfileRequestModel, isLoader: Bool, completion: @escaping (Bool)->Void = {_ in }) {
        
        /*
         Api name: getPendingStreamRequests
         Parameters: "user_id"
         Method: POST
         */
        
        APICall.shared.POST(strURL: GAPIConstant.getPendingStreamRequests(), parameter: requestModel.toDictionary(), withLoader: isLoader) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! StreamRequestsResponseModel.init(data: data)
                self.arrRequests = []
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        self.arrRequests = responseModel.result!
                        completion(true)
                    }else{
                        completion(false)
                    }
                }
            }
        }
    }
    
    
}

extension VCPendingRequest: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objVMPendingRequests.arrRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellPendingRequests
        let objAtIndex = self.objVMPendingRequests.arrRequests[indexPath.row]
        let serverTimeStamp = Int64(objAtIndex.created!)
        let date = Date(millis: serverTimeStamp!)
        let diifernce = Date().offset(from: date)
        
        cell.btnCancelOutlet.addTarget(self, action: #selector(btnTapOnCancel(_:)), for: .touchUpInside)
        cell.btnCancelOutlet.tag = indexPath.row
        
        cell.lblName.text = objAtIndex.location
        cell.lblDistance.text = diifernce
        
        return cell
    }
    
    @objc func btnTapOnCancel(_ sender: UIButton) {
        let objAtIndex = self.objVMPendingRequests.arrRequests[sender.tag]
        
        let alert = GPAlert(title: objAtIndex.location!, message: "Are you sure you want to cancel your Streaming?")
        AlertManager.shared.show(alert, buttonsArray: ["No","Yes"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                break
            case 1:
                GFunction.shared.addLoader(nil)
                let requestModel = NotificationRequestModel()
                requestModel.user_id = GConstant.UserData.id
                requestModel.stream_id = objAtIndex.id
                requestModel.status = StreamingStatus.cancel.rawValue
                self.objVMAPIs.callupdateStreamStatusApi(requestModel) {
                    GFunction.shared.removeLoader()
                    self.setupPendingRequest(withLoader: false)
                }
                break
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
