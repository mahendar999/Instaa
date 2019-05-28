//
//  VCRequest.swift
//  Instacam
//
//  Created by Apple on 08/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit

class VCRequest: UIViewController {
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    var timer: Timer!
    var timerDuration = 45
    var objVMAPIs = VMAPIs()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        lblMessage.text = Payload.shared.message == nil ? "Join Streaming".localized() : Payload.shared.message.localized()
        lblName.text = Payload.shared.streamerName
        imgView.setImageWithDownload(Payload.shared.streamerImage!.url())
        
        //self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkTimerStatus), userInfo: nil, repeats: true)
    }
    
    @objc func checkTimerStatus() {
        if timerDuration == 0 {
            self.timer.invalidate()
//            let requestModel = NotificationRequestModel()
//            requestModel.stream_id = Payload.shared.streamId
//            requestModel.status = StreamingStatus.cancel.rawValue
//            GFunction.shared.addLoader(nil)
//            self.objVMAPIs.callCancelRequestsApi(requestModel) {
//                GFunction.shared.removeLoader()
//            }
            
            GNavigation.shared.popToRoot(VCHome.self)
        }
        
        timerDuration -= 1
    }
    
    @IBAction func btnAccept(_ sender: UIButton) {
        let vcLiveRoom = self.storyboard?.instantiateViewController(withIdentifier: "VCLiveRoom") as! VCLiveRoom
        vcLiveRoom.roomName = Payload.shared.channel
        vcLiveRoom.clientRole = .audience
        vcLiveRoom.roomUId = "0"
        self.navigationController?.pushViewController(vcLiveRoom, animated: true)
    }
    
    @IBAction func btnDecline(_ sender: UIButton) {
        SocketIOManager.shared.sendRequest(key: SocketEvents.callDeclined, parameter: ["receiver_id": Payload.shared.streamerId])
        GNavigation.shared.popToRoot(VCHome.self)
    }
    
}
