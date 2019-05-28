//
//  VMLiveRoom.swift
//  Instacam
//
//  Created by Apple on 11/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import AgoraRtcEngineKit
import Alamofire

class VMLiveRoom: NSObject {
    
    var arrMessages: [MessageManager] = []
    var arrLocalMessages: [MessageManager] = []
    var tableView = UITableView()
    var timer: Timer? = nil
    
    func loadMessageTable(_ vwTable: UITableView) {
        self.tableView = vwTable
        self.arrLocalMessages = self.arrMessages
        self.arrLocalMessages.reverse()
        
        self.tableView.reloadData()
        
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkForMessageDisappear), userInfo: nil, repeats: true)
        }
    }
    
    @objc func checkForMessageDisappear() {
        let currentCount = self.arrMessages.count
        self.arrMessages = self.arrMessages.filter({ (objModel) -> Bool in
            let serverTimestamp = Int64(objModel.timestamp)
            let serverDate = Date(millis: serverTimestamp!)
            
            if Date() > serverDate {
                return false
            }else{
                return true
            }
        })
        
        if currentCount != self.arrMessages.count {
            self.arrLocalMessages = self.arrMessages
            self.arrLocalMessages.reverse()
            self.tableView.reloadData()
        }
    }
    
    func findIndex(data: MessageManager) -> Int {
        if let index = self.arrMessages.firstIndex(where: { (objModel) -> Bool in
            if objModel.timestamp == data.timestamp {
                return true
            }
            return false
        }){
            return index
        }
        
        return -1
    }

    func callUpdateStatusApi(_ requestModel: NotificationRequestModel, isLoader: Bool = false, completion: @escaping ()->Void) {
        
        /*
         Api name: updateStreamStatus
         Parameters: user_id, stream_id, status
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.updateStreamStatus(), parameter: requestModel.toDictionary(), withLoader: isLoader) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! UserResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        completion()
                    }else{
                        AlertManager.shared.show(GPAlert(title: "", message: responseModel.message ?? ""))
                    }
                }
            }
        }
    }
    
    func callStartrecordingApi(_ channelName: String) {
        
        /*
         Api name: http://35.180.39.41:3000/recorder/start
         Parameters: channel
         Method: POST
         */
        
        let url = "http://35.180.39.41:3000/recorder/start".url()
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        
        let request = NSMutableURLRequest(url: url)
        let parameters = ["channel" : channelName]
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let dataTask = defaultSession.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            else if let data = data {
                print(data)
            }
        }
        dataTask.resume()
        
    }
    
}

// MARK:- TableView methods

extension VCLiveRoom: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objVMLiveRoom.arrLocalMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellMessage", for: indexPath) as! CellMessage
        cell.alpha = 1
        
        cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        let objAtIndex = objVMLiveRoom.arrLocalMessages[indexPath.row]
        if let imageUrl = objAtIndex.image {
            cell.imgView.setImageWithDownload(imageUrl.url())
        }
        
        cell.lblMessage.text = objAtIndex.message
        cell.vwBackground.backgroundColor = .clear
        
        if objAtIndex.receiverID == GConstant.UserData.id {
            DispatchQueue.main.async {
                cell.vwBackground.backgroundColor = UIColor.init(red: 0/255, green: 133/255, blue: 246/255, alpha: 1.0)
            }
        }else{
            DispatchQueue.main.async {
                cell.vwBackground.backgroundColor = UIColor.init(red: 229/255, green: 247/255, blue: 255/255, alpha: 1.0)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

// MARK:- Custom methods

extension VCLiveRoom {
    
    func updateButtonsVisiablity() {
        self.lblMessage.isHidden = true
        if isBroadcaster {
            switchCameraButton.isHidden = false
            videoPauseButton.isHidden = true
            lblPrice.isHidden = false
            self.vwDraw.isUserInteractionEnabled = false
            walkieTalkieButton.isHidden = true
        }else{
            crossButton.isHidden = false
            switchCameraButton.isHidden = true
            videoPauseButton.isHidden = false
            lblPrice.isHidden = true
            walkieTalkieButton.isHidden = false
        }
    }
    
    func leaveChannel(_ role: AgoraClientRole) {
        
        rtcEngine.leaveChannel(nil)
        setIdleTimerActive(true)
        
        for session in videoSessions {
            session.hostingView.removeFromSuperview()
        }
        
        videoSessions.removeAll()
        rtcEngine.setupLocalVideo(nil)
        
        durationTimer?.invalidate()
        
//        if role == .audience {
//            SocketIOManager.shared.sendRequest(key: SocketEvents.updateUserStatus, parameter: ["user_id": GConstant.UserData.id!, "streamer_id": Payload.shared.streamerId, "in_call": "0"])
//        }
        
        if role == .broadcaster && self.lblCallStatus.text == "Connecting...".localized() {
            SocketIOManager.shared.sendRequest(key: SocketEvents.callDeclined, parameter: ["receiver_id": CallJoinData.shared.viewerId])
            GNavigation.shared.popToRoot(VCHome.self)
        }else{
            let identifier = role == .broadcaster ? GVCIdentifier.ratePopup : GVCIdentifier.viewerRating
            let vcRatePopup = self.instantiateVC(with: identifier)
            GNavigation.shared.push(vcRatePopup, isAnimated: false)
        }
        
        rtcEngine = nil
    }
    
    func setIdleTimerActive(_ active: Bool) {
        UIApplication.shared.isIdleTimerDisabled = !active
    }
    
    func alert(string: String) {
        guard !string.isEmpty else {
            return
        }
        
        let alert = UIAlertController(title: nil, message: string, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK:- Agora Custom Methods

extension VCLiveRoom {
    func updateInterface(withAnimation animation: Bool) {
        if animation {
            UIView.animate(withDuration: 0.3, animations: {
                self.updateInterface()
                self.view.layoutIfNeeded()
            })
        } else {
            updateInterface()
        }
    }
    
    func updateInterface() {
        var displaySessions = videoSessions
        if !isBroadcaster && !displaySessions.isEmpty {
            displaySessions.removeFirst()
        }else if isBroadcaster && !displaySessions.isEmpty{
            displaySessions.removeLast()
        }
        
        viewLayouter.layout(sessions: displaySessions, fullSession: fullSession, inContainer: remoteContainerView)
        setStreamType(forSessions: displaySessions, fullSession: fullSession)
    }
    
    func setStreamType(forSessions sessions: [VideoSession], fullSession: VideoSession?) {
        if let fullSession = fullSession {
            for session in sessions {
                rtcEngine.setRemoteVideoStream(UInt(session.uid), type: (session == fullSession ? .high : .low))
            }
        } else {
            for session in sessions {
                rtcEngine.setRemoteVideoStream(UInt(session.uid), type: .high)
            }
        }
    }
    
    func addLocalSession() {
        let localSession = VideoSession.localSession()
        videoSessions.append(localSession)
        rtcEngine.setupLocalVideo(localSession.canvas)
    }
    
    func fetchSession(ofUid uid: Int64) -> VideoSession? {
        for session in videoSessions {
            if session.uid == uid {
                return session
            }
        }
        
        return nil
    }
    
    func videoSession(ofUid uid: Int64) -> VideoSession {
        if let fetchedSession = fetchSession(ofUid: uid) {
            return fetchedSession
        } else {
            let newSession = VideoSession(uid: uid)
            videoSessions.append(newSession)
            return newSession
        }
    }
}

//MARK: - Agora Media SDK

extension VCLiveRoom {
    func loadAgoraKit() {
        rtcEngine = AgoraRtcEngineKit.sharedEngine(withAppId: KeyManager.agora, delegate: self)
        rtcEngine.delegate = self
        rtcEngine.enableVideo()
        rtcEngine.setChannelProfile(.communication)
        rtcEngine.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x480,
                                                                              frameRate: .fps15,
                                                                              bitrate: AgoraVideoBitrateStandard,
                                                                              orientationMode: .adaptative))
        
        addLocalSession()
        
        let code = rtcEngine.joinChannel(byToken: nil, channelId: roomName, info: nil, uid: UInt(roomUId)!, joinSuccess: nil)
        if code == 0 {
            setIdleTimerActive(false)
            rtcEngine.setEnableSpeakerphone(true)
            
            if !isBroadcaster {
                rtcEngine.muteLocalAudioStream(true)
            }else{
                rtcEngine.muteLocalAudioStream(false)
            }
        } else {
            DispatchQueue.main.async(execute: {
                self.alert(string: "Join channel failed: \(code)")
            })
        }
    }
    
}

// MARK:- Agora Delegates Methods

extension VCLiveRoom: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let userSession = videoSession(ofUid: Int64(uid))
        rtcEngine.setupRemoteVideo(userSession.canvas)
        
        if isBroadcaster{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.rtcEngine.switchCamera()
            }
            
            if CallJoinData.shared.status == 1{
                dismiss(animated: false, completion: {
                    // Check and Add Tutorial screens
                    if GFunction.shared.isShowVideoTutorial() {
                        let vc = self.instantiateVC(with: GVCIdentifier.tutorialVideo) as! VCVideoTutorials
                        vc.modalPresentationStyle = .overCurrentContext
                        self.present(vc, animated: false, completion: nil)
                    }
                })
            }
            
        }
        
        if !isBroadcaster{
            let requestModel = NotificationRequestModel()
            requestModel.user_id = GConstant.UserData.id
            requestModel.stream_id = Payload.shared.streamId
            requestModel.status = StreamingStatus.inCall.rawValue
            self.objVMLiveRoom.callUpdateStatusApi(requestModel, completion: {
            })
            
            self.objVMLiveRoom.callStartrecordingApi(self.roomName)
        }
        
        self.lblCallStatus.text = "Connected".localized()
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.lblCallStatus.isHidden = true
        }
    }
    
    @objc func updateTimer() {
        durationSeconds += 1
        self.lblTimer.timerString(TimeInterval(durationSeconds))
        
        if durationSeconds > 60 {
            self.TotalPrice = self.TotalPrice + 0.01
            self.lblPrice.text = String(format:"$%.2f", self.TotalPrice)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFrameWith size: CGSize, elapsed: Int) {
        if let _ = videoSessions.first {
            updateInterface(withAnimation: false)
        }
    }
    
    internal func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        if isBroadcaster && reason == .quit{
            durationTimer?.invalidate()
            let time = lblTimer.text!.components(separatedBy: ":")
            let minutes = time.count > 0 ? time[0] : "00"
            let seconds = time.count > 1 ? time[1] : "00"
            let price = durationSeconds > 60 ? lblPrice.text! : "$1.00"
            
            let message = "You have spent".localized() + " \(minutes) " + "minutes".localized() + " \(seconds) " + "seconds".localized() + " " + "your earning for this call is".localized() + " \(price)."
            let alert = GPAlert(title: "Call ended by Viewer".localized(), message: message)
            AlertManager.shared.showWithoutLocalize(alert, buttonsArray: ["Ok"]) { (buttonIndex : Int) in
                switch buttonIndex {
                case 0 :
                    self.leaveChannel(.broadcaster)
                    break
                default:
                    break
                }
            }
        }
        
        if !isBroadcaster && reason == .quit{
            durationTimer?.invalidate()
            let time = lblTimer.text!.components(separatedBy: ":")
            let minutes = time.count > 0 ? time[0] : "00"
            let seconds = time.count > 1 ? time[1] : "00"
            let price = durationSeconds > 60 ? lblPrice.text! : "$1.00"
            let message = "You have spent".localized() + " \(minutes) " + "minutes".localized() + " \(seconds) " + "seconds".localized() + " " + "your payable bill after ending this call is".localized() + " \(price)."
            let alert = GPAlert(title: "Call ended by Streamer".localized(), message: message)
            AlertManager.shared.showWithoutLocalize(alert, buttonsArray: ["Ok"]) { (buttonIndex : Int) in
                switch buttonIndex {
                case 0 :
                    self.leaveChannel(.audience)
                    break
                default:
                    break
                }
            }
        }
    }
    
    
    func rtcEngineConnectionDidLost(_ engine: AgoraRtcEngineKit) {
        
    }
    
    func rtcEngineConnectionDidInterrupted(_ engine: AgoraRtcEngineKit) {
        //        self.lblCallStatus.isHidden = false
        //        self.lblCallStatus.text = "Connecting..."
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didRejoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        
    }
    
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, lastmileQuality quality: AgoraNetworkQuality) {
        switch quality {
        case .excellent:
            print("Excellent")
        case .good:
            print("Good")
        case .poor:
            print("Poor")
        case .bad:
            print("Bad")
        case .vBad:
            print("Very Bad")
        case .down:
            print("Quality Down")
        default:
            print("Unknown")
        }
    }
    
    
}

