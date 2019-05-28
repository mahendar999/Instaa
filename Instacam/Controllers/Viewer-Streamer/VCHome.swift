//
//  ViewController.swift
//  Instacam
//
//  Created by Apple on 04/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit
import GoogleMaps
import GooglePlaces

class VCHome: UIViewController {

    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var requestStreamView: RequestStreamView!
    @IBOutlet weak var nearbyRequestsView: NearbyRequestsView!
    @IBOutlet weak var featuredLocationsView: FeaturedLocationsView!
    @IBOutlet weak var constantYSwipeView: NSLayoutConstraint!
    @IBOutlet weak var constFeaturedYSwipeView: NSLayoutConstraint!
    @IBOutlet weak var constHeightRequestProgress: NSLayoutConstraint!
    @IBOutlet weak var vwRequestProgress: UIView!
    @IBOutlet weak var btnInProgressOutlet: UIButton!
    
    var requestMarker: GMSMarker? = nil
    var objVMHome = VMHome()
    var objVMAPIs = VMAPIs()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initMainView()
        
        // Check and Add Tutorial screens
        if GFunction.shared.isShowBeginingTutorial() {
            let vc = self.instantiateVC(with: GVCIdentifier.tutorial) as! VCTutorial
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: false, completion: nil)
        }
        
    }
    
    func initMainView() {
         NotificationCenter.default.addObserver(self, selector: #selector(handleNotifications(_:)), name: NSNotification.Name("ReceivedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationPopup(_:)), name: NSNotification.Name("TapOnNewStreamNotification"), object: nil)
        
        if SocketIOManager.shared.socket.status != .connected {
            SocketIOManager.shared.socket.once(clientEvent: .connect) { (data, Ack) in
                SocketIOManager.shared.joinChatRoom()
            }
        }else{
            //if connected then join only
            SocketIOManager.shared.joinChatRoom()
        }
        
        if isUserTypeViewer() {
            SocketIOManager.shared.shareLocation { (objModel) -> Void in
                let data = ["latitude": objModel.latitude, "longitude": objModel.longitude, "timestamp": objModel.timestamp, "message": objModel.message]
                let userdefault = UserDefaults.standard
                userdefault.set(data, forKey: GConstant.UserDefaults.kStreamTrackData)
                userdefault.synchronize()
            }
            
            SocketIOManager.shared.noShow {
                let alert = GPAlert(title: "Call Disconnected", message: "Call disconnected automatically due to your unresponsive behavior")
                AlertManager.shared.showPopup(alert, forTime: 3.0, completionBlock: { (INT) in
                    GNavigation.shared.popToRoot(VCHome.self)
                })
                
                self.setupForViewer()
            }
        }
        
        SocketIOManager.shared.callDeclined {
            if !self.isUserTypeViewer() {
                NotificationManager.shared.handleRedirections(NotificationTypes.declineCall.rawValue, vc: self)
            }else{
                NotificationManager.shared.handleRedirections(NotificationTypes.streamerExit.rawValue, vc: self)
            }
        }
        
    }
    
    @objc func handleNotifications(_ notification: Notification) {
        if let type = notification.object as? String {
            if let controller = self.navigationController?.topViewController {
                if (controller is VCLiveRoom) || (controller is VCRequest) {
                    return
                }
            }
            
            if NotificationManager.shared.isCallStarted {
                return
            }
            
            if NotificationTypes.requestPlaced.rawValue == type {
                if let controller = self.navigationController?.topViewController {
                    if (controller is VCHome) {
                        self.setupForStreamer()
                    }
                }
            }
            
            NotificationManager.shared.handleRedirections(type, vc: self)
        }
        
    }
    
    @objc func handleNotificationPopup(_ notification: Notification) {
        
        if Payload.shared.streamId != nil {
            
            let data = self.objVMHome.arrRequests.filter { (objResult) -> Bool in
                if objResult.id == Payload.shared.streamId {
                    return true
                }
                return false
            }
            
            if data.count > 0 {
                CallJoinData.shared.handleData(data[0])
                let vcAcceptedRequest = self.instantiateVC(with: "VCPopupStreamerAcceptRequest") as! VCPopupStreamerAcceptRequest
                vcAcceptedRequest.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                vcAcceptedRequest.objVMStreamerRequestAccept.reloadMapCompletion = {
                    self.setupForStreamer()
                }
                GNavigation.shared.present(vcAcceptedRequest, isAnimated: false)
            }
            
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationTypes.acceptCall.rawValue), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationManager.shared.isCallStarted = false
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.customize()
        self.revealViewController()?.navigationController?.isNavigationBarHidden = true
        
        // Get User Role Rating
        let requestModel = UserProfileRequestModel()
        requestModel.user_id = GConstant.UserData.id
        requestModel.user_type = GConstant.UserData.userType
        self.objVMAPIs.callGetRatingApi(requestModel)
        
        if GConstant.UserData.userType == "S" {
            self.setupForStreamer()
        }else{
            self.setupForViewer()
        }
        
    }
    
    
}

