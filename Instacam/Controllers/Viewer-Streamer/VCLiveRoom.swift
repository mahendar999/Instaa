//
//  VCLiveRoom.swift
//  Instacam
//
//  Created by Apple on 04/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit

protocol VCLiveRoomDelegate: NSObjectProtocol {
    func liveVCNeedClose(_ liveVC: VCLiveRoom)
}

class VCLiveRoom: UIViewController {

    @IBOutlet weak var remoteContainerView: UIView!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var videoPauseButton: UIButton!
    @IBOutlet weak var walkieTalkieButton: UIButton!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var vwDraw: DrawingView!
    @IBOutlet weak var lblCallStatus: UILabel!
    @IBOutlet weak var tfMessage: UITextField!
    @IBOutlet weak var tblView: UITableView!
    
    var roomUId: String!
    var roomName: String!
    var durationTimer: Timer? = nil
    var durationSeconds = 0
    var TotalPrice: Double = 1.00
    let viewLayouter = VideoViewLayouter()
    weak var delegate: VCLiveRoomDelegate?
    var clientRole = AgoraClientRole.audience
    var objVMLiveRoom = VMLiveRoom()
    
    //MARK: - engine & session view
    var rtcEngine: AgoraRtcEngineKit!
    
    var isBroadcaster: Bool {
        return clientRole == .broadcaster
    }
    
    var videoSessions = [VideoSession]() {
        didSet {
            guard remoteContainerView != nil else {
                return
            }
            updateInterface(withAnimation: true)
        }
    }
    
    var fullSession: VideoSession? {
        didSet {
            if fullSession != oldValue && remoteContainerView != nil {
                updateInterface(withAnimation: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        SocketIOManager.shared.socket.on(clientEvent: .connect) { (data, Ack) in
//            SocketIOManager.shared.joinChatRoom()
//            print("Join Connected")
//        }
        
        // Check and Add Tutorial screens
        if GFunction.shared.isShowVideoTutorial() && isUserTypeViewer(){
            let vc = self.instantiateVC(with: GVCIdentifier.tutorialVideo) as! VCVideoTutorials
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: false, completion: nil)
        }
        
        tblView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
        tblView.estimatedRowHeight = 57
        tblView.rowHeight = UITableView.automaticDimension
        
        NotificationManager.shared.isCallStarted = true
        lblCallStatus.textAlignment = .center
        lblPrice.text = "$1.00"
        lblTimer.text = "00:00"
        updateButtonsVisiablity()
        loadAgoraKit()
        
        if SocketIOManager.shared.socket.status != .connected {
            SocketIOManager.shared.socket.once(clientEvent: .connect) { (data, Ack) in
                SocketIOManager.shared.joinChatRoom()
                print("Join Connected")
            }
        }else{
            //if connected then join only
            SocketIOManager.shared.joinChatRoom()
            print("Join Connected")
        }
        
        tfMessage.attributedPlaceholder = NSAttributedString(string: "Say Something...".localized(),
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        tfMessage.returnKeyType = .send
        tfMessage.delegate = self
        
        self.setupSockets()
        self.imgView.alpha = 0
        
        if GConstant.UserData.userType != "S" {
            self.lblCallStatus.isHidden = true
            NotificationCenter.default.addObserver(self, selector: #selector(swipeGestureRecognizer(_:)), name: NSNotification.Name("SwipeRecognizer"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(tapGestureRecognizer(_:)), name: NSNotification.Name("TapRecognizer"), object: nil)
        }else{
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(self.appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setupSockets() {
        if GConstant.UserData.userType == LoginUserType.streamer.rawValue {
            SocketIOManager.shared.streamingPause {
                self.lblMessage.isHidden = false
                let msg = "STOP HERE".localized()
                self.lblMessage.text = "  \(msg)  "
                self.lblMessage.layer.cornerRadius = 25
                self.lblMessage.clipsToBounds = true
            }
            
            SocketIOManager.shared.streamingPlay {
                self.lblMessage.isHidden = true
            }
            
            SocketIOManager.shared.drawPoint { (manager) in
                self.vwDraw.isHidden = false
                self.vwDraw.drawPath(manager)
            }
            
            SocketIOManager.shared.callInit {
                if self.durationTimer == nil {
                    self.durationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
                }
            }
            
            if CallJoinData.shared.status == 1 {
                let vcAcceptedRequest = self.instantiateVC(with: "VCPopupStreamerDial") as! VCPopupStreamerDial
                vcAcceptedRequest.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                GNavigation.shared.present(vcAcceptedRequest, isAnimated: false)
            }
        }else{
            SocketIOManager.shared.sendRequest(key: SocketEvents.initCall, parameter: ["receiver_id": Payload.shared.streamerId!])
            
            if durationTimer == nil {
                durationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            }
        }
        
        SocketIOManager.shared.receiveMessage { (objMessage) -> Void in
            // Handle Message here for streamer view
            self.objVMLiveRoom.arrMessages.append(objMessage)
            self.objVMLiveRoom.loadMessageTable(self.tblView)
        }
        
    }
    
    @objc func appBecomeActive() {
        if SocketIOManager.shared.socket.status != .connected {
            SocketIOManager.shared.socket.once(clientEvent: .connect) { (data, Ack) in
                SocketIOManager.shared.joinChatRoom()
                print("Join Connected")
            }
        }else{
            //if connected then join only
            SocketIOManager.shared.joinChatRoom()
            print("Join Connected")
        }
    }
    
    @objc func swipeGestureRecognizer(_ notification: Notification) {
        if let direction = notification.object as? Directions {
            switch direction{
            case .bottom:
                self.imgView.moveDown(.viewer)
                break
            case .left:
                self.imgView.moveLeft(.viewer)
                break
            case .top:
                self.imgView.moveUp(.viewer)
                break
            case .right:
                self.imgView.moveRight(.viewer)
                break
            }
        }
    }
    
    @objc func tapGestureRecognizer(_ notification: Notification) {
        if let point = notification.object as? CGPoint {
            self.remoteContainerView.addPointer(point, deviceSize: UIScreen.main.bounds.size, userType: .viewer)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        if GConstant.UserData.userType == LoginUserType.streamer.rawValue {
            SocketIOManager.shared.socket.off(SocketEvents.initCall)
            SocketIOManager.shared.socket.off(SocketEvents.drawPosition)
            SocketIOManager.shared.socket.off(SocketEvents.play)
            SocketIOManager.shared.socket.off(SocketEvents.pause)
        }else{
            NotificationCenter.default.removeObserver(self)
        }
        
        if rtcEngine != nil {
            rtcEngine.leaveChannel(nil)
            setIdleTimerActive(true)
            
            for session in videoSessions {
                session.hostingView.removeFromSuperview()
            }
            
            videoSessions.removeAll()
            rtcEngine.setupLocalVideo(nil)
            
            durationTimer?.invalidate()
            rtcEngine = nil
        }
        
    }
    
    //MARK: - user action
    @IBAction func doSwitchCameraPressed(_ sender: UIButton) {
        rtcEngine?.switchCamera()
    }
    
    @IBAction func doLeavePressed(_ sender: UIButton) {
        rtcEngine.disableVideo()
        durationTimer?.invalidate()
        let time = lblTimer.text!.components(separatedBy: ":")
        let minutes = time.count > 0 ? time[0] : "00"
        let seconds = time.count > 1 ? time[1] : "00"
        let price = durationSeconds > 60 ? lblPrice.text! : "$1.00"
        
        var alert: GPAlert!
        if isBroadcaster && self.lblCallStatus.text == "Connecting...".localized() {
            alert = GPAlert(title: "Are you certain you want to cancel?".localized(), message: "You can wait for few minutes to join Viewer with you.".localized())
        }else if isBroadcaster && self.lblCallStatus.text == "Connected".localized() {
            let message = "You have spent".localized() + " \(minutes) " + "minutes".localized() + " \(seconds) " + "seconds".localized() + "."
            alert = GPAlert(title: "Are you certain you want to cancel?".localized(), message: message)
        }else{
            let message = "You have spent".localized() + " \(minutes) " + "minutes".localized() + " \(seconds) " + "seconds".localized() + " " + "your payable bill after ending this call is".localized() + " \(price)."
            alert = GPAlert(title: "Are you certain you want to cancel?".localized(), message: message)
        }
        
        AlertManager.shared.showWithoutLocalize(alert, buttonsArray: ["No","Yes"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                self.rtcEngine.enableVideo()
                self.durationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
                break
            case 1:
                if self.isBroadcaster && self.lblCallStatus.text == "Connecting...".localized() {
                    self.leaveChannel(self.isBroadcaster ? .broadcaster : .audience)
                    return
                }
                
                let requestModel = NotificationRequestModel()
                requestModel.user_id = GConstant.UserData.id
                requestModel.stream_id = Payload.shared.streamId == nil ? CallJoinData.shared.streamId : Payload.shared.streamId
                requestModel.price = price.replacingOccurrences(of: "$", with: "")
                requestModel.final_duration = self.lblTimer.text!
                requestModel.status = StreamingStatus.complete.rawValue
                
                if self.isUserTypeViewer() {
                    requestModel.uid = Payload.shared.uid
                }
                
                self.objVMLiveRoom.callUpdateStatusApi(requestModel, isLoader: true) {
                    self.leaveChannel(self.isBroadcaster ? .broadcaster : .audience)
                }
                
                break
            default:
                break
            }
        }
    }
    
    @IBAction func doFreezePressed(_ sender: UIButton) {
        if sender.tag == 1 {
            sender.tag = 0
            sender.isSelected = false
            SocketIOManager.shared.sendRequest(key: SocketEvents.play, parameter: ["receiver_id": Payload.shared.streamerId!])
        }else{
            sender.tag = 1
            sender.isSelected = true
            SocketIOManager.shared.sendRequest(key: SocketEvents.pause, parameter: ["receiver_id": Payload.shared.streamerId!])
        }
    }
    
    @IBAction func doWalkieTalkiePressed(_ sender: UIButton) {
        if sender.tag == 1 {
            sender.tag = 0
            sender.isSelected = false
            rtcEngine.muteLocalAudioStream(true)
        }else{
            sender.tag = 1
            sender.isSelected = true
            rtcEngine.muteLocalAudioStream(false)
        }
    }
    
    @IBAction func btnSendMessage(_ sender: UIButton) {
        sendMessage()
    }
    
    func sendMessage() {
        let message = tfMessage.text!.trimmingCharacters(in: .whitespaces)
        if message.isEmpty {
            AlertManager.shared.addToast(self.view, message: "Please enter message", duration: 2.0)
        }else{
            tfMessage.resignFirstResponder()
            
            let receiverId = GConstant.UserData.userType == LoginUserType.viewer.rawValue ? Payload.shared.streamerId! : CallJoinData.shared.viewerId!
            
            let date = Date().addingTimeInterval(15)
            let timestamp = "\(date.toMillis()!)"
            let parameters = [
                "receiver_id": receiverId,
                "sender_name": GConstant.UserData.fullName!,
                "sender_image": GConstant.UserData.profileImage!,
                "timestamp": timestamp,
                "message": tfMessage.text!
            ]
            
            SocketIOManager.shared.sendRequest(key: SocketEvents.sendMessage, parameter: parameters)
            
            let msgModel = MessageManager()
            msgModel.name = GConstant.UserData.fullName!
            msgModel.image = GConstant.UserData.profileImage!
            msgModel.timestamp = timestamp
            msgModel.message = tfMessage.text!
            msgModel.receiverID = receiverId
            self.objVMLiveRoom.arrMessages.append(msgModel)
            
            self.objVMLiveRoom.loadMessageTable(self.tblView)
            tfMessage.text = ""
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        videoPauseButton.isHidden = true
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.updateButtonsVisiablity()
    }
    
}

extension VCLiveRoom: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfMessage {
            self.sendMessage()
        }
        return false
    }
}

