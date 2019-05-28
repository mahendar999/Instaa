//
//  VCStreamerDial.swift
//  Instacam
//
//  Created by Apple on 23/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCPopupStreamerDial: UIViewController {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCountdown: UILabel!
    @IBOutlet weak var lblButtonLabel: UILabel!
    @IBOutlet weak var btnDialOutlet: UIButton!
    @IBOutlet weak var imgView: UIImageView!

    var timer: Timer!
    var duration = 300
    var objVMAPIs = VMAPIs()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initMainView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    func initMainView() {
        lblCountdown.alpha = 0
        
        let data = Payload.shared
        lblName.text = data.userName
            
        if let imageUrl = data.userProfile {
            imgView.setImageWithDownload(imageUrl.url())
        }
        
        
        let firstcall_timestamp = CallJoinData.shared.acceptedTimestamp
        let date = Date.init(millis: Int64(firstcall_timestamp!)!)
        self.duration = self.duration - Date().seconds(from: date)
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        }
    }
    
    @objc func timerRunning() {
        duration -= 1
        
        if duration == 0 {
            self.showAlert()
        }
        
        let minutesLeft = Int(duration) / 60 % 60
        let secondsLeft = Int(duration) % 60
        let minute = minutesLeft < 10 ? "0\(minutesLeft)" : "\(minutesLeft)"
        let second = secondsLeft < 10 ? "0\(secondsLeft)" : "\(secondsLeft)"
        
        lblCountdown.alpha = 1
        lblCountdown.text = "\(minute):\(second)"
    }
    
    func showAlert() {
        let alert = GPAlert(title: GConstant.AppName, message: "Stream automatically disconnected after 5 minute waiting for the Viewer")
        AlertManager.shared.show(alert, buttonsArray: ["Ok"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                self.updateStatus()
                break
            default:
                break
            }
        }
    }
    
    func updateStatus() {
        
        let requestModel = NotificationRequestModel()
        requestModel.user_id = GConstant.UserData.id
        requestModel.stream_id = CallJoinData.shared.streamId
        requestModel.status = StreamingStatus.notConnected.rawValue
        self.objVMAPIs.callupdateStreamStatusApi(requestModel) {
        }
        
        let param = [
            "user_id": CallJoinData.shared.viewerId!,
            "streamer_id": GConstant.UserData.id!,
            "stream_id": CallJoinData.shared.streamId!
        ]
        
        SocketIOManager.shared.sendRequest(key: SocketEvents.updateStreamStatus, parameter: param)

        // Later on Go to Earning Screen
        dismiss(animated: false) {
            GNavigation.shared.popToRoot(VCHome.self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer.invalidate()
    }
    
    @IBAction func btnDial(_ sender: UIButton) {
        dismiss(animated: false) {
            GNavigation.shared.pop(false)
        }
    }

}
