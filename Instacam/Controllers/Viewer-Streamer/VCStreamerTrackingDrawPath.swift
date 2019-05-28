//
//  VCStreamerTrackingDrawPath.swift
//  Instacam
//
//  Created by Apple on 27/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import GoogleMaps
import AgoraRtcEngineKit

class VCStreamerTrackingDrawPath: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lblOrigin: UILabel!
    @IBOutlet weak var lblDestination: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    var objVMAPIs = VMAPIs()
    var UpdateLocationTimer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        let viewerCoordinates = CallJoinData.shared.viewerCoordinate!
        let streamerCoordinates = LocationManager.shared.currentLocation.coordinate
        
        // Setup Source/Destination Addresses
        
        self.lblOrigin.text = ""
        self.lblDestination.text = ""
        
        PlacePickerManager.shared.findPlace(streamerCoordinates) { (result) in
            self.lblOrigin.text = PlacePickerManager.shared.getLocation(result, type: .full)
            self.lblDestination.text = "To".localized() + " " + "\(CallJoinData.shared.objStreamRequest!.location!)"
        }
        
        DrawPathManager.shared.drawPath(mapView, viewerCoord: viewerCoordinates, streamerCoord: streamerCoordinates, isUpdating: false) { (mapData) in
            self.lblTime.text = mapData.time
            self.lblDistance.text = mapData.distance
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleShareLocationNotification(_:)), name: NSNotification.Name("ShareLocationNotification"), object: nil)
        
        if UpdateLocationTimer == nil {
            UpdateLocationTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateDrawPath), userInfo: nil, repeats: true)
        }
        
    }
    
    @objc func handleShareLocationNotification(_ notification: Notification) {
        let streamerCoordinates = LocationManager.shared.currentLocation.coordinate
        let param = [   "receiver_id": CallJoinData.shared.viewerId!,
                        "streamer_lat": "\(streamerCoordinates.latitude)",
                        "streamer_long": "\(streamerCoordinates.longitude)",
                        "timestamp": CallJoinData.shared.acceptedTimestamp!,
                        "message": "\(GConstant.UserData.fullName!) " + "is on his way to".localized() + " \(CallJoinData.shared.objStreamRequest!.location!)"
                    ]
        
        SocketIOManager.shared.sendRequest(key: SocketEvents.shareLocation, parameter: param)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationManager.shared.timer.invalidate()
        LocationManager.shared.timer = nil
        NotificationCenter.default.removeObserver(self)
        UpdateLocationTimer.invalidate()
    }
    
    @objc func updateDrawPath() {
        let viewerCoordinates = CallJoinData.shared.viewerCoordinate!
        let streamerCoordinates = LocationManager.shared.currentLocation.coordinate
        
        PlacePickerManager.shared.findPlace(streamerCoordinates) { (result) in
            self.lblOrigin.text = PlacePickerManager.shared.getLocation(result, type: .full)
            self.lblDestination.text = "To".localized() + " " + "\(CallJoinData.shared.objStreamRequest!.location!)"
        }
        
        DrawPathManager.shared.drawPath(mapView, viewerCoord: viewerCoordinates, streamerCoord: streamerCoordinates, isUpdating: true) { (mapData) in
            self.lblTime.text = mapData.time
            self.lblDistance.text = mapData.distance
        }
    }
    
    @IBAction func btnStartVideo(_ sender: UIButton) {
        
        if CallJoinData.shared.status == 1 && CallJoinData.shared.acceptedTimestamp != nil && CallJoinData.shared.acceptedTimestamp != "" {
            let firstcall_timestamp = CallJoinData.shared.acceptedTimestamp
            let date = Date.init(millis: Int64(firstcall_timestamp!)!)
            let duration = Date().seconds(from: date)

            if duration > 300 {
                self.showAlert()
            }else{
                self.initCallViaVoip()
            }
        }else{
            self.initCallViaVoip()
        }
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
        
        GNavigation.shared.popToRoot(VCHome.self)
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        GNavigation.shared.pop()
    }
    
    func initCallViaVoip() {
        let uid = CallJoinData.shared.uid != nil && CallJoinData.shared.uid != "" ? CallJoinData.shared.uid : "\(Int(Date().timeIntervalSince1970))"
        let data = ManagerClass.PassData(userId: CallJoinData.shared.viewerId, channel: CallJoinData.shared.channel, message: NotificationTypes.joinStream.rawValue, streamId: CallJoinData.shared.streamId, uid: uid)
        
        GFunction.shared.addLoader(nil)
        ManagerClass.shared.hitApi(data) { (deviceType) -> Void in
            GFunction.shared.removeLoader()
            let vcLiveRoom = self.instantiateVC(with: GVCIdentifier.liveRoom) as! VCLiveRoom
            vcLiveRoom.roomName = CallJoinData.shared.channel
            vcLiveRoom.roomUId = uid
            vcLiveRoom.clientRole = .broadcaster
            GNavigation.shared.push(vcLiveRoom)
        }
    }

}
